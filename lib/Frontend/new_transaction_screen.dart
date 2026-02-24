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
  final TextEditingController referenceController = TextEditingController();
  
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
    
      String extractReferenceNumber(String text) {
        final regex = RegExp(
          r'Ref\.?\s*No\.?\s*([0-9 ]+)',
          caseSensitive: false,
        );

        final match = regex.firstMatch(text);

        if (match == null) return '';

        // Normalize: remove spaces
        return match.group(1)!.replaceAll(' ', '').trim();
      }
    final reference = extractReferenceNumber(recognizedText.text);

    setState(() {
      referenceController.text = reference;
    });
    print('----- OCR RAW TEXT START -----');
    print(recognizedText.text);
    print('----- OCR RAW TEXT END -----');
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
      String extractReferenceNumber(String text) {
        final regex = RegExp(
          r'Ref\.?\s*No\.?\s*([0-9 ]+)',
          caseSensitive: false,
        );

        final match = regex.firstMatch(text);

        if (match == null) return '';

        // Normalize: remove spaces
        return match.group(1)!.replaceAll(' ', '').trim();
      }
    final reference = extractReferenceNumber(recognizedText.text);

    setState(() {
      referenceController.text = reference;
    });
    print('----- OCR RAW TEXT START -----');
    print(recognizedText.text);
    print('----- OCR RAW TEXT END -----');
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
            TextField(
            controller: referenceController,
            decoration: const InputDecoration(
            labelText: 'Reference Number',
            border: OutlineInputBorder(),
            ),
          ),
          ],
        ),
      ),
    );
  }
}