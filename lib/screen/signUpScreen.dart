import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('A4AI', style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to the Sign Up page',
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child:TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            )
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: passwordController,
              obscureText: true, // hides the input text
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            )
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: confirmPasswordController,
              obscureText: true, // hides the input text
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            )
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: displayNameController,
              decoration: InputDecoration(
                labelText: 'Enter Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: roleController,
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          ElevatedButton(
            onPressed: () {
              String email = emailController.text;
              String password = passwordController.text;
              String confirmPassword = confirmPasswordController.text;
              if (password == confirmPassword){
                final newuser = {
                  "email": email,
                  "password": password,
                  "displayName": displayNameController.text,
                  "role": roleController.text,
                };
                print('Sign Up button pressed with email: $email and password: $password');
                signUpUsers(context, newuser); //passing both context and newuser
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: Colors.red,
                  )
                );
                print('Passwords do not match');
              }
              
            },
            child: Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white )),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

  void signUpUsers(BuildContext context, newuser) async {
    print('Sign Up button pressed');
    const url01 = 'http://10.0.2.2:8000/api/v1/auth/signup'; //when running on an emulator, localhost
    //points to the emulator itself, not your computer.
    //Android Emulator: Use 10.0.2.2 instead of localhost
    final uri01 = Uri.parse(url01);

    // Convert users to JSON string
    final jsonString01 = jsonEncode(newuser);
    final response01 = await http.post(
      uri01,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonString01,
    );

    // Debugging output
    print('response: ${response01}');
    print('Response status: ${response01.statusCode}');
    print('Response body: ${response01.body}');
    
    // Handle the response
    final responseBody = jsonDecode(response01.body);
    if (response01.statusCode == 200){
      print('Sign Up successful: ${responseBody}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign Up successful!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamed(context, '/login'); // Navigate to login page after successful sign up
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign Up failed. Please try again. Error: ${responseBody['msg']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }