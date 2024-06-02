import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart'; // Import the login page

class RegisterPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> _registerUser(BuildContext context) async {
  try {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Passwords do not match!'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    // Add user data to Firestore collection with isAdmin set to false
    await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
      'email': emailController.text.trim(),
      'username': usernameController.text.trim(),
      'isAdmin': false, // Set isAdmin to false for new users
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Registration successful!'),
      backgroundColor: Colors.green,
    ));

    // Redirect to the login page upon successful registration
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error registering user: $e'),
      backgroundColor: Colors.red,
    ));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 250,
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Username',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 250,
                    child: TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your username',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 250,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm Password',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 250,
                    child: TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirm your password',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _registerUser(context),
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
