import 'package:flutter/material.dart';
import 'screens/loginpage.dart';
import 'screens/scannerpage.dart';



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xff0a0e21),
        scaffoldBackgroundColor: Color(0xff0a0e21),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => login(),
        '/scanner': (context) => InputPage(),
      },

    );
  }
}
