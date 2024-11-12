import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MySimpleNoteApp());
}

class MySimpleNoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySimpleNote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: HomeScreen(),
    );
  }
}
