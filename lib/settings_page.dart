import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For persistent settings

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  // Settings variables with default values
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';
  bool _isPreprocessingEnabled = true;
  bool _isNotificationEnabled = true;

  late AnimationController _controller;
  late Animation<Color?> _buttonColorAnimation;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<double> _scaleAnimation;

  // Particle List for touch effect
  List<Particle> particles = [];
  
  // Droplet List for mouse movement effect
  List<Droplet> droplets = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _buttonColorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.green,
    ).animate(_controller);

    _backgroundColorAnimation = ColorTween(
      begin: Colors.orange,
      end: Colors.pink,
    ).animate(_controller);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  // Load settings from shared preferences
  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _isPreprocessingEnabled = prefs.getBool('preprocessing') ?? true;
      _isNotificationEnabled = prefs.getBool('notifications') ?? true;
    });
  }

  // Save settings to shared preferences
  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('dark_mode', _isDarkMode);
    prefs.setString('language', _selectedLanguage);
    prefs.setBool('preprocessing', _isPreprocessingEnabled);
    prefs.setBool('notifications', _isNotificationEnabled);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addParticle(Offset position) {
    setState(() {
      particles.add(Particle(position: position, size: 5 + Random().nextInt(5).toDouble()));
    });
  }

  void _addDroplet(Offset position) {
    setState(() {
      droplets.add(Droplet(position: position, size: 5 + Random().nextInt(10).toDouble()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MouseRegion(
        onEnter: (_) {},
        onExit: (_) {},
        onHover: (details) {
          _addDroplet(details.localPosition); // Add droplet on mouse movement
        },
        child: GestureDetector(
          onTapUp: (details) {
            _addParticle(details.localPosition); // Add particle on tap
          },
          child: Stack(
            children: [
              // Animated Background
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _backgroundColorAnimation.value ?? Colors.orange,
                          _backgroundColorAnimation.value ?? Colors.pink,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  );
                },
              ),
              // Particles (Touch Effect)
              ...particles.map((particle) {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 2000),
                  left: particle.position.dx,
                  top: particle.position.dy,
                  child: Container(
                    width: particle.size,
                    height: particle.size,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }).toList(),
              // Droplets (Mouse Move Effect)
              ...droplets.map((droplet) {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 1500),
                  left: droplet.position.dx,
                  top: droplet.position.dy,
                  child: Container(
                    width: droplet.size,
                    height: droplet.size,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }).toList(),
              // Main Content
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Logo at the top
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset(
                          'assets/logo2.png', // Path to your logo
                          height: 100, // Adjust the size of the logo
                        ),
                      ),
                      const Text(
                        "Settings Page",
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 20),
                      // Dark Mode Toggle
                      SwitchListTile(
                        title: const Text("Enable Dark Mode"),
                        value: _isDarkMode,
                        onChanged: (bool value) {
                          setState(() {
                            _isDarkMode = value;
                          });
                          _saveSettings();
                        },
                      ),
                      const SizedBox(height: 20),
                      // OCR Preprocessing Options
                      SwitchListTile(
                        title: const Text("Enable OCR Preprocessing"),
                        value: _isPreprocessingEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _isPreprocessingEnabled = value;
                          });
                          _saveSettings();
                        },
                      ),
                      const SizedBox(height: 20),
                      // Notifications Toggle
                      SwitchListTile(
                        title: const Text("Enable Notifications"),
                        value: _isNotificationEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _isNotificationEnabled = value;
                          });
                          _saveSettings();
                        },
                      ),
                      const SizedBox(height: 20),
                      // "About" Button with Animation Effect
                      GestureDetector(
                        onTap: () {
                          _showAboutDialog(context);
                        },
                        child: AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _buttonColorAnimation.value ?? Colors.blue,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Text(
                              "About Textify",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/home'); // Navigating to home
        },
        child: const Icon(Icons.home),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Show the About Dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("About OCR App"),
          content: const Text(
            "This OCR app allows you to recognize text from images. "
            "You can adjust settings such as language, theme, and more.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}

class Particle {
  final Offset position;
  final double size;

  Particle({required this.position, required this.size});
}

class Droplet {
  final Offset position;
  final double size;

  Droplet({required this.position, required this.size});
}
