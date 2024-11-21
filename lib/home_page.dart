import 'dart:math';
import 'package:flutter/material.dart';
import 'text_recognition_page.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBackgroundButtons(), // Using the Animated Background Button widget
      ),
    );
  }
}

class AnimatedBackgroundButtons extends StatefulWidget {
  @override
  _AnimatedBackgroundButtonsState createState() =>
      _AnimatedBackgroundButtonsState();
}

class _AnimatedBackgroundButtonsState extends State<AnimatedBackgroundButtons>
    with SingleTickerProviderStateMixin {
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
    return Listener(
      onPointerMove: (details) {
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
            // Buttons on top of the animated background
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center, // Ensure buttons and text are centered
                  children: [
                    // Add the logo image at the top
                    Image.asset(
                      'assets/logo2.png', // Path to the logo image
                      height: 150, // Set the height of the logo
                      width: 150, // Set the width of the logo
                    ),
                    const SizedBox(height: 20), // Add space after the logo
                    const Text(
                      "Welcome to the Textify!",
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    // Start Recognizing Text Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/recognition');
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "Start Recognizing Text",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Settings Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/settings');
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.settings, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "Settings",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false, // Removes the debug banner
    initialRoute: '/home',
    routes: {
      '/home': (context) => HomePage(),
      '/recognition': (context) => HomeScreen(),
      '/settings': (context) => SettingsPage(),
    },
  ));
}
