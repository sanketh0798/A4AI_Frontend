import 'package:a4ai_ui/screen/loginScreen.dart';
import 'package:a4ai_ui/screen/signUpScreen.dart';
import 'package:a4ai_ui/screen/HomePageScreen.dart';
import 'package:flutter/material.dart';


int main() {
  runApp(const MyApp());
  return 0;
}

class MyApp extends StatelessWidget {
  // ignore: non_constant_identifier_names
  const MyApp({Key? Key}) : super(key: Key);
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: HomePageScreen(),
      routes: {
        '/signup': (context) => SignUpScreen(),
        '/login': (context) => LoginScreen(),
        'homepage': (context) => HomePageScreen(),
        // other routes can be added here
      },
    );

  }
}