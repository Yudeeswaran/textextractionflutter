import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ml_text_recognition/image_preview.dart';
import 'package:file_picker/file_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextRecognizer textRecognizer;
  late ImagePicker imagePicker;

  String? pickedImagePath;
  String recognizedText = "";

  bool isRecognizing = false;

  @override
  void initState() {
    super.initState();

    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    imagePicker = ImagePicker();
  }

  void _pickImageAndProcess({ImageSource? source}) async {
    String? path;

    if (source != null) {
      // Mobile image selection (camera or gallery)
      final pickedImage = await imagePicker.pickImage(source: source);

      if (pickedImage == null) return;
      path = pickedImage.path;
    } else {
      // Desktop file selection
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

  void _chooseImageSourceModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageAndProcess(source: ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a picture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageAndProcess(source: ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Pick from PC'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageAndProcess(source: null); // Desktop file picker
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _copyTextToClipboard() async {
    if (recognizedText.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: recognizedText));
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text copied to clipboard'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Text Recognition'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ImagePreview(imagePath: pickedImagePath),
            ),
            ElevatedButton(
              onPressed: isRecognizing ? null : _chooseImageSourceModal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pick an image'),
                  if (isRecognizing) ...[
                    const SizedBox(width: 20),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recognized Text",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.copy,
                      size: 16,
                    ),
                    onPressed: _copyTextToClipboard,
                  ),
                ],
              ),
            ),
            if (!isRecognizing) ...[
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Flexible(
                          child: SelectableText(
                            recognizedText.isEmpty
                                ? "No text recognized"
                                : recognizedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
