import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo (Replace with your logo widget)
            Image.asset(
              'assets/images/logo.png',
              width: 150,
            ),
            SizedBox(height: 20),
            Container(
              width: 250,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 250,
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement login functionality
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
