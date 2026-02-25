import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Backend/text_decoder.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class NewTransactionScreen extends StatefulWidget {
  @override
  _NewTransactionScreenState createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  String extractedText = ''; // Holds the scanned text
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController senderController = TextEditingController();
  final TextEditingController receiverController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  
    Future<void> captureAndScanImage() async {
    final picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    final inputImage = InputImage.fromFile(File(image.path));
    final textRecognizer =
        TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
    await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    final rawText = recognizedText.text;
    final referenceNumber = extractReference(rawText);
    final parties = extractTransferParties(rawText);
    final dateTime = extractDateTime(rawText);
    final amount = extractAmount(rawText);
    setState(() {
      extractedText = rawText;
      senderController.text = parties?['sender'] ?? '';
      receiverController.text = parties?['receiver'] ?? '';
      referenceController.text = referenceNumber ?? '';
      dateTimeController.text = dateTime ?? '';
      amountController.text = amount ?? '';
    });
    print('----- OCR RAW TEXT START -----');
    print(rawText);
    print('----- OCR RAW TEXT END -----');
  }
  Future<void> pickAndScanImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    final inputImage = InputImage.fromFile(File(image.path));
    final textRecognizer =
        TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
    await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    final rawText = recognizedText.text;
    final referenceNumber = extractReference(rawText);
    final parties = extractTransferParties(rawText);
    final dateTime = extractDateTime(rawText);
    final amount = extractAmount(rawText);
    setState(() {
      extractedText = rawText;
      senderController.text = parties?['sender'] ?? '';
      receiverController.text = parties?['receiver'] ?? '';
      referenceController.text = referenceNumber ?? '';
      dateTimeController.text = dateTime ?? '';
      amountController.text = amount ?? '';
    });
    print('----- OCR RAW TEXT START -----');
    print(rawText);
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
            controller: senderController,
            decoration: const InputDecoration(
            labelText: 'Received From:',
            border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: receiverController,
            decoration: const InputDecoration(
            labelText: 'Received By:',
            border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(
            labelText: 'Amount',
            border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: dateTimeController,
            decoration: const InputDecoration(
            labelText: 'Date & Time',
            border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: referenceController,
            decoration: const InputDecoration(
            labelText: 'Reference Number',
            border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}