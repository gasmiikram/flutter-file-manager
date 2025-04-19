import 'package:classfy/screens/add_task_page.dart';
import 'package:flutter/material.dart';
import 'package:classfy/screens/welcome_screen.dart';
import 'package:classfy/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightMode,
      home: const WelcomeScreen(),
      routes: {'/addTask': (context) => const AddTaskPage()},
    );
  }
}