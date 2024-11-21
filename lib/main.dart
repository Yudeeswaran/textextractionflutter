import 'package:flutter/material.dart';
import 'home_page.dart';
import 'text_recognition_page.dart';
import 'settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Textify',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/recognition': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
