import 'package:flutter/material.dart';
import 'collector_nearby_tab.dart';
import 'collector_tasks_tab.dart';
import 'collector_profile_tab.dart';
import 'collector_wallet_tab.dart';

class CollectorHomeScreen extends StatefulWidget {
  const CollectorHomeScreen({super.key});

  @override
  State<CollectorHomeScreen> createState() => _CollectorHomeScreenState();
}

class _CollectorHomeScreenState extends State<CollectorHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const CollectorNearbyTab(),
    const CollectorTasksTab(),
    const CollectorWalletTab(),
    const CollectorProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Pesanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_rounded),
            label: 'Tugas',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Dompet',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
