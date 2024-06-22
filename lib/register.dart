import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';  
import 'dart:math' as Math;

class BackgroundPainter extends CustomPainter {
  double degToRad(double deg) => deg * (Math.pi / 180.0);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Colors.grey.shade300, Colors.black],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path = Path();
    path.moveTo(size.width, 0);
    path.quadraticBezierTo(
        size.width * -0.25, size.height * -0.25, size.width * 0.0, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MirroredBackgroundPainter extends CustomPainter {
  double degToRad(double deg) => deg * (Math.pi / 180.0);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Colors.grey.shade300, Color.fromARGB(255, 98, 98, 98)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
        size.width * 1.20, size.height * 1.35, size.width, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class RegisterPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final Function(bool) toggleTheme;
  final Function(bool) setGameStarted;
  final bool isGameStarted;

  RegisterPage({
    required this.toggleTheme,
    required this.setGameStarted,
    required this.isGameStarted,
  });

  Future<void> _registerUser(BuildContext context) async {
    try {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Passwords do not match!'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

       
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': emailController.text.trim(),
        'username': usernameController.text.trim(),
        'isAdmin': false,  
        'difficultyLevel': 0,  
        'isDarkMode': false,  
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Registration successful!'),
        backgroundColor: Colors.green,
      ));

       
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            toggleTheme: toggleTheme,
            setGameStarted: setGameStarted,
            isGameStarted: isGameStarted,
          ),
        ),
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
      backgroundColor: Color.fromARGB(255, 245, 245, 238),
      body: CustomPaint(
        painter: BackgroundPainter(),
        child: CustomPaint(
          painter: MirroredBackgroundPainter(),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 250.0,
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey),
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: 280,
                        height: 50,
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'example@gmail.com',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
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
                        'Name',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey),
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: 280,
                        height: 50,
                        child: TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Enter your name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey),
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: 280,
                        height: 50,
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Enter your password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey),
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: 280,
                        height: 50,
                        child: TextField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Confirm your password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _registerUser(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 192, 204, 220),
                      minimumSize: Size(200, 55),
                    ),
                    child: Text(
                      'LOGIN',
                      style: TextStyle(
                        fontFamily: 'FranklinGothic-Bold',
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 8, 4, 52),
                        fontSize: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
