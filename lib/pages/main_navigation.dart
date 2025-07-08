import 'package:flutter/material.dart';
import 'package:fyp_zakaty_app/pages/settings_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'home_page.dart';
import 'cases_page.dart';
import 'zakat_calculator_page.dart';
import 'pay_page.dart';
import 'learn_page.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    CasesPage(),
    ZakatCalculatorPage(),
    PayZakatPage(),
    LearnPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green.shade700),
              child: Text(
                'Quick Links',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calculate),
              title: Text('Quick Calculate'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ZakatCalculatorPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Quick Pay'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PayZakatPage()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                // replace with your auth-logout logic
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),


      
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container( decoration: BoxDecoration(
        color: Colors.white, // Try a bold color to test visibility like Colors.red
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: GNav(
              selectedIndex: _selectedIndex,
              onTabChange: (index) => setState(() => _selectedIndex = index),
              gap: 8,
              color: Colors.black,                 // unselected icon/text color
              activeColor: Colors.yellow,         // selected icon/text color
              tabBackgroundColor: Colors.blue, // tab bubble color
              backgroundColor: Colors.transparent,   // avoid blocking parent color
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              tabs: const [
                GButton(icon: Icons.home, text: 'Home'),
                GButton(icon: Icons.favorite, text: 'Cases'),
                GButton(icon: Icons.calculate, text: 'Zakat'),
                GButton(icon: Icons.payment, text: 'Pay'),
                GButton(icon: Icons.menu_book, text: 'Learn'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
