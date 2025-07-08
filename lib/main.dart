import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fyp_zakaty_app/auth/login_page.dart';
import 'package:fyp_zakaty_app/auth/register_page.dart';
import 'package:fyp_zakaty_app/auth/forgot_password_page.dart';
import 'package:fyp_zakaty_app/pages/first_page.dart';
import 'package:fyp_zakaty_app/pages/payment_history_page.dart';
import 'package:fyp_zakaty_app/pages/payment_success_page.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'pages/cases_page.dart';
import 'pages/zakat_calculator_page.dart';
import 'pages/pay_page.dart';
import 'pages/learn_page.dart';
import 'providers/case_provider.dart';
import 'providers/user_provider.dart';
import 'providers/admin_provider.dart';
import 'auth/admin_login_page.dart';
import 'pages/admin/admin_panel.dart';
import 'pages/admin/receipt_management_page.dart';
import 'firebase_options.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Stripe.publishableKey =
      'pk_test_51RdC7uGaSpItgJZmgzWOIoxbrK1ulSAqzqKTYy6FX94v8nDmHIrMTkpjieNaXrocAEi6Pvp6u2ggebbzBs0fBmuG00ZepxtW2I';
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CaseProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: ZakatApp(),
    ),
  );
}

class ZakatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZakatEase',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Colors.green.shade700,
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
      initialRoute: '/',
      routes: {
        '/main_navigation': (context) => MainNavigation(),
        '/home': (context) => HomePage(),
        '/zakat-calculator': (context) => const ZakatCalculatorPage(),
        '/pay-zakat': (context) => const PayZakatPage(),
        '/payment-history': (context) => PaymentHistoryPage(),
        '/payment-success': (context) => PaymentSuccessPage(),
        '/register': (context) => SignUpScreen(),
        '/login': (context) => LoginScreen(),
        '/': (context) => OnboardingScreen(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        // Admin routes
        '/admin-login': (context) => AdminLoginScreen(),
        '/admin-panel': (context) => AdminPanel(),
        '/admin/receipt-management': (context) => ReceiptManagementPage(),
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

bool isLoggedIn = false;

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    CasesPage(),
    PayZakatPage(),
    ZakatCalculatorPage(),
    LearnPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text('ZakatEase'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
                label: Text('1442 AH', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.green.shade800),
          ),
          CircleAvatar(
            backgroundColor: Colors.green.shade500,
            child: Text('MA', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(width: 10)
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Cases'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Pay'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calculate), label: 'Calculate'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Learn'),
        ],
      ),
    );
  }
}
