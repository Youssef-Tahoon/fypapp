import 'package:flutter/material.dart';

class AnimatedMenuBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  AnimatedMenuBar({required this.currentIndex, required this.onTap});

  final List<_MenuItem> _items = const [
    _MenuItem(icon: Icons.home, label: 'Home', color: Colors.blue),
    _MenuItem(icon: Icons.people, label: 'Cases', color: Colors.deepOrange),
    _MenuItem(icon: Icons.payment, label: 'Pay', color: Colors.purple),
    _MenuItem(icon: Icons.calculate, label: 'Calculate', color: Colors.teal),
    _MenuItem(icon: Icons.menu_book, label: 'Learn', color: Colors.indigo),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: _items[currentIndex].color,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      onTap: onTap,
      items: _items.map((item) {
        return BottomNavigationBarItem(
          icon: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: Icon(
              item.icon,
              key: ValueKey(item.icon),
              color: item.color,
            ),
          ),
          label: item.label,
        );
      }).toList(),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}
