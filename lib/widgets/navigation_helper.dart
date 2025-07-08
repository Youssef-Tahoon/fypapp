import 'package:flutter/material.dart';

class NavigationHelper extends StatefulWidget {
  final String destination;
  final int delayMilliseconds;

  NavigationHelper({
    required this.destination,
    this.delayMilliseconds = 200,
  });

  @override
  _NavigationHelperState createState() => _NavigationHelperState();
}

class _NavigationHelperState extends State<NavigationHelper> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Small delay to ensure the widget tree is built before navigation
    await Future.delayed(Duration(milliseconds: widget.delayMilliseconds));
    if (!mounted) return;

    // First navigate to root to reset the app state
    await Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);

    // Then navigate to the destination with the proper theme
    if (!mounted) return;

    // Add a small delay to ensure the root page is fully loaded
    await Future.delayed(Duration(milliseconds: 100));
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, widget.destination);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.green.shade700,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Color(0xFFF8FAFC),
        colorScheme: ColorScheme.light(
          primary: Colors.green.shade700,
          secondary: Colors.green.shade600,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green.shade700,
          unselectedItemColor: Colors.grey.shade600,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.green.shade700,
                strokeWidth: 4,
              ),
              SizedBox(height: 24),
              Text(
                'Returning to home...',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
