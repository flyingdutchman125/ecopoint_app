import 'package:flutter/material.dart';
import 'admin_dashboard_tab.dart';
import 'admin_orders_tab.dart';
import 'admin_users_tab.dart';
import 'admin_settings_tab.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  String _selectedUserRole = 'all';

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 2) _selectedUserRole = 'all';
    });
  }

  void _showUsers(String role) {
    setState(() {
      _currentIndex = 2;
      _selectedUserRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      AdminDashboardTab(
        onNavigateToTab: _onTabSelected,
        onNavigateToUsers: _showUsers,
      ),
      const AdminOrdersTab(),
      AdminUsersTab(selectedRole: _selectedUserRole),
      const AdminSettingsTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        elevation: 3,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: Colors.teal),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt_rounded, color: Colors.teal),
            label: 'Pesanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded, color: Colors.teal),
            label: 'Pengguna',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded, color: Colors.teal),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
