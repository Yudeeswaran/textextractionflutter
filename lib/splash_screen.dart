import 'package:flutter/material.dart';
import 'home_page.dart'; // Your home screen
import 'settings_page.dart'; // Your settings page
import 'text_recognition_page.dart'; // Your text recognition page

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
          seconds:
              3), // You can adjust this if you want a different animation duration
      vsync: this,
    );

    // Define the falling animation for the logo
    _animation = Tween<Offset>(begin: Offset(0, -1), end: Offset(0, 0)).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();

    // Navigate to the HomeScreen after 10 seconds
    Future.delayed(Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage()), // Navigate to HomeScreen
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Center(
        child: SlideTransition(
          position: _animation,
          child: GestureDetector(
            onTap: () {
              // You can navigate to any page when the splash screen is tapped
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage()), // Default navigation
              );
            },
            child: Image.asset(
              'assets/logo2.png', // Path to your logo
              height: 100, // Logo height
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false, // Remove debug banner
    initialRoute: '/splash', // Set initial route
    routes: {
      '/splash': (context) => SplashScreen(), // Splash screen route
      '/home': (context) => HomePage(), // Home screen route
      '/settings': (context) => SettingsPage(), // Settings page route
      '/recognition': (context) => HomeScreen(), // Text recognition page route
    },
  ));
}
