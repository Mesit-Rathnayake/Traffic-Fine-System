import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fines History'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.warning, color: Colors.red),
              title: Text('Speeding Fine'),
              subtitle: Text('Ref: FINE12345\nDate: 2026-06-10'),
              trailing: Text('LKR 5000'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.directions_car),
              title: Text('No Seatbelt'),
              subtitle: Text('Ref: FINE67890\nDate: 2026-06-08'),
              trailing: Text('LKR 3000'),
            ),
          ),
        ],
      ),
    );
  }
}