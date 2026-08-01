import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_dashboard.dart';
import 'store_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

TextStyle _jakarta({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = Colors.black,
}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

 final List<Widget> _pages = [
    const UserDashboard(),
    const StorePage(),
    const HistoryPage(),
    const ProfilePage(), // 2. GANTI PLACEHOLDER TERAKHIR DENGAN PAGE PROFILE BARU
  ];

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItemData(Icons.home_outlined, 'Beranda'),
      _NavItemData(Icons.card_giftcard_outlined, 'Store'),
      _NavItemData(Icons.history, 'Riwayat'),
      _NavItemData(Icons.person_outline, 'Profile'),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Color(0xFF1B3A1B)),
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(items[0], 0),
                _navItem(items[1], 1),
                const SizedBox(width: 56), 
                _navItem(items[2], 2),
                _navItem(items[3], 3),
              ],
            ),
            Positioned(
              top: -26,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(_NavItemData data, int index) {
    final selected = _currentIndex == index;
    final color = selected ? Colors.white : Colors.white54;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, color: color, size: 22),
          const SizedBox(height: 3),
          Text(data.label, style: _jakarta(color: color, fontSize: 10.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData(this.icon, this.label);
}