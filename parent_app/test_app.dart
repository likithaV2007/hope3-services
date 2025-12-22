import 'package:flutter/material.dart';
import 'lib/constants/app_colors.dart';
import 'lib/screens/dashboard_screen.dart';
import 'lib/screens/history_screen.dart';
import 'lib/providers/tracking_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrackingProvider()),
      ],
      child: MaterialApp(
        title: 'School Bus Tracker Test',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            surface: AppColors.cardBackground,
            onSurface: AppColors.textPrimary,
          ),
          scaffoldBackgroundColor: AppColors.darkBackground,
        ),
        home: TestNavigation(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class TestNavigation extends StatefulWidget {
  @override
  State<TestNavigation> createState() => _TestNavigationState();
}

class _TestNavigationState extends State<TestNavigation> {
  int _currentIndex = 0;
  final String testParentId = 'test_parent_123';

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(parentId: testParentId),
      HistoryScreen(parentId: testParentId),
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}