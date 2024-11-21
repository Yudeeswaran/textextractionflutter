import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TextRecognizer textRecognizer;
  late ImagePicker imagePicker;

  String? pickedImagePath;
  String recognizedText = "";

  bool isRecognizing = false;

  late AnimationController _controller;
  late Animation<Color?> _buttonColorAnimation;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    imagePicker = ImagePicker();

    // Initialize Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    // Define color animations for the button background
    _buttonColorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.green,
    ).animate(_controller);

    // Define color animations for the background
    _backgroundColorAnimation = ColorTween(
      begin: Colors.orange,
      end: Colors.pink,
    ).animate(_controller);

    // Define scaling animation for the button
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

  void _pickImageAndProcess({ImageSource? source}) async {
    String? path;

    if (source != null) {
      final pickedImage = await imagePicker.pickImage(source: source);

      if (pickedImage == null) return;
      path = pickedImage.path;
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        dialogTitle: "Select an Image",
      );

      if (result == null) return;
      path = result.files.single.path;
    }

    setState(() {
      pickedImagePath = path;
      isRecognizing = true;
    });

    try {
      if (path != null) {
        final inputImage = InputImage.fromFilePath(path);
        final RecognizedText recognisedText =
            await textRecognizer.processImage(inputImage);

        recognizedText = "";

        for (TextBlock block in recognisedText.blocks) {
          for (TextLine line in block.lines) {
            recognizedText += "${line.text}\n";
          }
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error recognizing text: $e'),
        ),
      );
    } finally {
      setState(() {
        isRecognizing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Animated Gradient Background
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
          // Foreground Content
          SafeArea(
            child: Column(
              children: <Widget>[
                // Logo Section (No text)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    'assets/logo2.png', // Path to your logo image
                    height: 100, // Adjust height of logo
                    fit: BoxFit.contain,
                  ),
                ),
                // Image Preview Section
                Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[200],
                    ),
                    child: pickedImagePath == null
                        ? const Center(
                            child: Text(
                              "No image selected",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(pickedImagePath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                // Animated Button to pick an image
                GestureDetector(
                  onTap: isRecognizing ? null : () => _pickImageAndProcess(),
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
                            "Pick an Image",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                // Recognized Text Section
                Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Recognized Text",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        SingleChildScrollView(
                          child: SelectableText(
                            recognizedText.isEmpty
                                ? "No text recognized yet."
                                : recognizedText,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
