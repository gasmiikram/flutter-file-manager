import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF7D4A3B),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: GNav(
          rippleColor: Colors.grey[800]!,
          hoverColor: Colors.grey[700]!,
          haptic: true,
          tabBorderRadius: 20,
          gap: 8,
          backgroundColor: const Color(0xFF7D4A3B),
          color: Colors.black54,
          activeColor: Colors.black,
          iconSize: 24,
          tabBackgroundColor: const Color.fromRGBO(255, 255, 255, 0.9),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          selectedIndex: selectedIndex,
          onTabChange: onTabChange,
          tabs: const [
            GButton(icon: LineIcons.home, text: ''),
            GButton(icon: LineIcons.calendar, text: ''),
            GButton(icon: LineIcons.comment, text: ''),
            GButton(icon: LineIcons.bell, text: ''),
          ],
        ),
      ),
    );
  }
}
