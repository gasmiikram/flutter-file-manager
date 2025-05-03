import 'package:flutter/material.dart';
import 'package:classfy/widgets/custom_nav_bar.dart';
import 'package:classfy/screens/home.dart';
import 'package:classfy/screens/comment_page.dart';
import 'package:classfy/screens/calendar_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _selectedIndex = 3; // 👈 Notifications page is index 3

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigation logic:
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else if (index == 1) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const CalendarPage()));
    } else if (index == 2) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const CommentPage()));
    } else if (index == 3) {
      // Already on Notifications page, do nothing
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF7D4A3B),
      ),
      body: const Center(
        child: Text(
          'This is the Notifications page!',
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
