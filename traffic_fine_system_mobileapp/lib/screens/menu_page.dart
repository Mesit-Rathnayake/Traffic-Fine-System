import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final List<_MenuItem> _items = [
    _MenuItem(label: 'Pay Fine', icon: Icons.payments, route: '/payment-home'),
    _MenuItem(label: 'My Fines', icon: Icons.receipt_long, route: '/fines'),
    _MenuItem(label: 'History', icon: Icons.history, route: '/history'),
    _MenuItem(label: 'Profile', icon: Icons.person, route: '/profile'),
  ];

  void _addItem() async {
    final result = await showDialog<_MenuItem?>(
      context: context,
      builder: (context) {
        final labelCtrl = TextEditingController();
        final routeCtrl = TextEditingController();
        IconData selected = Icons.extension;
        return AlertDialog(
          title: const Text('Add Menu Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(labelText: 'Label'),
              ),
              TextField(
                controller: routeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Route (e.g. /my-page)',
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _iconChoice(
                    Icons.extension,
                    selected == Icons.extension,
                    () => selected = Icons.extension,
                  ),
                  _iconChoice(
                    Icons.map,
                    selected == Icons.map,
                    () => selected = Icons.map,
                  ),
                  _iconChoice(
                    Icons.settings,
                    selected == Icons.settings,
                    () => selected = Icons.settings,
                  ),
                  _iconChoice(
                    Icons.list_alt,
                    selected == Icons.list_alt,
                    () => selected = Icons.list_alt,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final label = labelCtrl.text.trim();
                final route = routeCtrl.text.trim();
                if (label.isEmpty || route.isEmpty) return;
                Navigator.of(
                  context,
                ).pop(_MenuItem(label: label, icon: selected, route: route));
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() => _items.add(result));
    }
  }

  Widget _iconChoice(IconData icon, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active ? Colors.blue.shade100 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20),
        ),
      );

  void _onTapItem(_MenuItem it) {
    if (Navigator.of(context).canPop() &&
        it.route == ModalRoute.of(context)?.settings.name)
      return;
    if (it.route == '/payment-home') {
      Navigator.pushNamed(context, it.route);
      return;
    }
    // Default behaviour: show placeholder snackbar if route not registered
    final hasRoute =
        Navigator.canPop(context) || ModalRoute.of(context) != null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Open "${it.label}" (${it.route}) — implement route.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
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
                  if (i == _items.length) {
                    return _buildAddTile();
                  }
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

  Widget _buildAddTile() => GestureDetector(
    onTap: _addItem,
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
}

class _MenuItem {
  _MenuItem({required this.label, required this.icon, required this.route});
  final String label;
  final IconData icon;
  final String route;
}
