import 'package:flutter/material.dart';
import '../Backend/database_helper.dart';

class TransactionsScreen extends StatefulWidget {
  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();

}


class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    final data = await DatabaseHelper.instance.getTransactions();
    setState(() {
      transactions = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transactions')),
      body: transactions.isEmpty
          ? Center(child: Text('No transactions yet'))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Icon(
                      tx['type'] == 'in' ? Icons.arrow_downward : Icons.arrow_upward,
                      color: tx['type'] == 'in' ? Colors.green : Colors.red,
                    ),
                    title: Text('${tx['client_name']} (${tx['client_number']})'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Amount: ₱${tx['amount']}'),
                        Text('Reference: ${tx['reference']}'),
                        Text('Status: ${tx['status']}'),
                        if (tx['claim_time'] != null) Text('Claimed at: ${tx['claim_time']}'),
                        if (tx['note'] != null) Text('Note: ${tx['note']}'),
                      ],
                    ),
                    trailing: Text(tx['date']),
                  ),
                );
              },
            ),
    );
  }
}