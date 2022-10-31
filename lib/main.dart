import 'package:chat/pages/loading_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.blue,
        textTheme: const TextTheme(
          headline6: TextStyle(
            color: Colors.white
          )
        )
      ),
      home: const LoadingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}