import 'package:flutter/material.dart';
import 'fine_details_page.dart';
import 'personal_info_page.dart';
import 'payment_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<_MenuItem> _items = [
    _MenuItem(label: 'Pay Fine', icon: Icons.payments, onTap: null),
    _MenuItem(label: 'My Fines', icon: Icons.receipt_long, onTap: null),
    _MenuItem(label: 'History', icon: Icons.history, onTap: null),
    _MenuItem(label: 'Profile', icon: Icons.person, onTap: null),
  ];

  void _onTapItem(_MenuItem it) {
    switch (it.label) {
      case 'Pay Fine':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentPage()),
        );
        return;
      case 'My Fines':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FineDetailsPage()),
        );
        return;
      case 'Profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PersonalInfoPage()),
        );
        return;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open "${it.label}" — implement screen.')),
        );
    }
  }

  Widget _buildAddTile() => GestureDetector(
    onTap: () {},
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.add, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text('Add'),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: const Color(0xFF123B73),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _items.length + 1,
                itemBuilder: (context, i) {
                  if (i == _items.length) return _buildAddTile();
                  final it = _items[i];
                  return GestureDetector(
                    onTap: () => _onTapItem(it),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              child: Icon(
                                it.icon,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(it.label, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  _MenuItem({required this.label, required this.icon, this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
}
