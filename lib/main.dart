import 'package:flutter/material.dart';
import 'dart:math';
import '/Frontend/transaction_screen.dart';
import '/Frontend/new_transaction_screen.dart';
import '/Backend/database_helper.dart';

void main() {
  runApp(const MyApp());
}

// Generate random transaction
Future<void> generateRandomTransaction(BuildContext context) async {
  final types = ['in', 'out']; // cash in or cash out
  final random = Random();

  final transaction = {
    'name': 'Client ${random.nextInt(1000)}',
    'number': '09${random.nextInt(900000000) + 100000000}', // fake 11-digit number
    'type': types[random.nextInt(2)],
    'amount': (random.nextDouble() * 1000).toStringAsFixed(2), // random amount up to 1000
    'reference': 'REF${random.nextInt(1000000)}',
    'status': 'pending',
    'date': DateTime.now().toString(),
    'claim_time': null,
    'created_at': DateTime.now().toString(),
  };

  await DatabaseHelper.instance.insertTransaction(transaction);

  // Show a SnackBar
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Random transaction added!')),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'GCash Transactions'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransactionsScreen()), // no const
                );
              },
              child: const Text('View Transactions'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await generateRandomTransaction(context);
              },
              child: const Text('Generate Random Transaction'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
            onPressed: (){
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewTransactionScreen()),
            );
            },
            child: const Text("New Transaction")),
            
          
          ],
        ),
      ),
    );
  }
}