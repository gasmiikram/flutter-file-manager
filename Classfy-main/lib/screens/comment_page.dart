import 'package:flutter/material.dart';
import 'package:classfy/screens/home.dart';
import 'package:classfy/screens/notification_page.dart';
import 'package:classfy/screens/calendar_page.dart';
import 'package:classfy/widgets/custom_nav_bar.dart';  // ✅ Import your new widget

class CommentPage extends StatefulWidget {
  const CommentPage({super.key});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  int _selectedIndex = 2; // Comments page

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else if (index == 1) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const CalendarPage()));
    } else if (index == 2) {
      // Same page
    } else if (index == 3) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const NotificationPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: const Color(0xFF7D4A3B),
      ),
      body: const Center(
        child: Text(
          'This is the Comments page!',
          style: TextStyle(fontSize: 20),
        ),
      ),
      bottomNavigationBar: CustomNavBar(  // ✅ Using the global widget
        selectedIndex: _selectedIndex,
        onTabChange: _onItemTapped,
      ),
    );
  }
}
