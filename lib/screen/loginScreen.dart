import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
final storage = FlutterSecureStorage();
class _LoginScreenState extends State<LoginScreen> {
  //const users = []; // This will hold user data if needed
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  


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
                  'Welcome to the Login Screen',
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
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    String email = emailController.text;
                    String password = passwordController.text;
                    final users = {"email": email, "password": password};
                    print('Login button pressed with email: $email and password: $password');
                    sendLoginRequest(context, users);
                  },
                  child: Text('Login', style: TextStyle(fontSize: 18, color: Colors.white )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                    
                ElevatedButton(
                  onPressed: () {
                    print('Sign Up button pressed');
                    Navigator.pushNamed(context, '/signup');
                    },
                  child: Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                
            
              ],
            ),
          ),
        ],
      ),
    );
  }
}
  
void sendLoginRequest(BuildContext context, users) async {
  const url02 = 'http://10.0.2.2:8000/api/v1/auth/login';//when running on an emulator, localhost
  //points to the emulator itself, not your computer.
  //Android Emulator: Use 10.0.2.2 instead of localhost

  final uri02 = Uri.parse(url02);
  
  // Convert users to JSON string
  final jsonString02 = jsonEncode(users);

  print('Sending login request...');
  
  // Send POST request
  final response = await http.post(
    uri02,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonString02,
  );

  // Debugging output
  print('response: ${response}');
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  // Handle the response
  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    print('Login successful: ${responseBody}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login successful!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushNamed(context, '/homepage'); // Navigate to home page after successful login
  } else {
    final errorBody = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${errorBody['msg']}'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // Store user data securely
  final LoginResponsejsonString = jsonEncode(response);
  await storage.write(key: 'user', value: LoginResponsejsonString);
  if (!LoginResponsejsonString.isEmpty) {
    final Map<String, dynamic> userdata = jsonDecode(LoginResponsejsonString);
    
  }

}