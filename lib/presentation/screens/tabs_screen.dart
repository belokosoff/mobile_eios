import 'package:flutter/material.dart';
import 'package:eios/presentation/screens/attendance_code_screen.dart';
import 'package:eios/presentation/screens/discipline_screen.dart';
import 'package:eios/presentation/screens/timetable_screen.dart';
import 'profile_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _currentIndex = 0;
  static const int _scannerTabIndex = 3;

  final Map<int, Widget> _loadedPages = {};

  @override
  void initState() {
    super.initState();
    _loadPage(0);
  }

  void _loadPage(int index) {
    if (!_loadedPages.containsKey(index)) {
      switch (index) {
        case 0:
          _loadedPages[0] = const TimeTableScreen();
          break;
        case 1:
          _loadedPages[1] = const ProfileScreen();
          break;
        case 2:
          _loadedPages[2] = const DisciplineListScreen();
          break;
        case 3:
          _loadedPages[3] = AttendanceCodeScreen(
            isActive: _currentIndex == _scannerTabIndex,
          );
          break;
      }
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _loadPage(index); // Инициализируем страницу при переходе
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      // Используем IndexedStack, но заполняем его заглушками,
      // пока реальная страница не будет выбрана пользователем
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(4, (index) {
          return _loadedPages[index] ??
              const Center(child: CircularProgressIndicator());
        }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Расписание',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
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
