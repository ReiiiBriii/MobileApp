import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class NewTransactionScreen extends StatefulWidget {
  @override
  _NewTransactionScreenState createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  String extractedText = ''; // Holds the scanned text

  Future<void> captureAndScanImage()async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera);

    if (image == null) return;

    final inputImage = InputImage.fromFile(File(image.path));
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText = 
    await textRecognizer.processImage(inputImage);

    await textRecognizer.close();
    
    setState(() {
      extractedText = recognizedText.text;
    });
  }
  Future<void> pickAndScanImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final inputImage = InputImage.fromFile(File(image.path));
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    await textRecognizer.close();

    setState(() {
      extractedText = recognizedText.text; // Update the displayed text
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCR Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Column(
              children: [
                ElevatedButton(
                  onPressed: pickAndScanImage,
                  child: const Text('Pick Image from Gallery'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: captureAndScanImage,
                  child: const Text('Capture Photo'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Display the scanned text inside a scrollable box
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    extractedText.isEmpty
                        ? 'Scanned text will appear here'
                        : extractedText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}