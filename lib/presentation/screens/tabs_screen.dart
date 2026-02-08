import 'package:eios/presentation/screens/attendance_code_screen.dart';
import 'package:eios/presentation/screens/discipline_screen.dart';
import 'package:eios/presentation/screens/timetable_screen.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _currentIndex = 0;

  static const int _scannerTabIndex = 3;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const TimeTableScreen(),
          const ProfileScreen(),
          const DisciplineListScreen(),
          AttendanceCodeScreen(isActive: _currentIndex == _scannerTabIndex),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Расписание',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Успеваемость',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Посещаемость',
          ),
        ],
      ),
    );
  }
}