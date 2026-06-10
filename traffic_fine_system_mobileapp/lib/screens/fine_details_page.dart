import 'package:flutter/material.dart';

class FineDetailsPage extends StatelessWidget {
  const FineDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traffic Fines Sri Lanka 2026'),
        backgroundColor: const Color(0xFF123B73),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [

            Text(
              '🚦 Traffic Fines in Sri Lanka (2026 Full Guide)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 12),

            Text(
              'Traffic fines in Sri Lanka are based on the Motor Traffic Act (Chapter 203). '
              'In 2026, enforcement includes spot fines, court fines, and demerit points.',
            ),

            SizedBox(height: 20),

            Text(
              '🚓 Types of Penalties',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            Text(
              '1) Spot Fines - Paid on the spot or later via GovPay\n'
              '2) Court Fines - Serious offences decided by court\n'
              '3) Demerit Points - Start with 24 points, lose points per offence',
            ),

            SizedBox(height: 20),

            Text(
              '⚠️ Common Fines',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            Text(
              'Speeding: Rs. 3,000 – 5,000+\n'
              'No licence: Rs. 25,000 – 50,000\n'
              'Reckless driving: Rs. 10,000 – 40,000+\n'
              'Red light violation: Rs. 5,000 – 25,000\n'
              'Railway crossing: Rs. 25,000 – 40,000\n'
              'No insurance: Rs. 25,000 – 50,000\n'
              'Drink driving: Rs. 100,000+ + jail',
            ),

            SizedBox(height: 20),

            Text(
              '📱 How to Pay',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            Text(
              '- GovPay / bank apps\n'
              '- Post office\n'
              '- Police station\n\n'
              'Payment updates your record automatically.',
            ),

            SizedBox(height: 20),

            Text(
              '📊 Demerit System',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            Text(
              '- Start with 24 points\n'
              '- Points reduced for offences\n'
              '- 0 points = licence suspension',
            ),

            SizedBox(height: 20),

            Text(
              '🚔 Important Rules',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            Text(
              '- Carry licence always\n'
              '- Seatbelt required\n'
              '- No mobile use while driving\n'
              '- Insurance must be valid\n'
              '- Police can issue spot fines',
            ),
          ],
        ),
      ),
    );
  }
}