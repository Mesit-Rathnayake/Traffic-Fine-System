import 'package:flutter/material.dart';
import 'fine_details_page.dart';
import 'personal_info_page.dart';
import 'payment_page.dart';
import 'history.dart';
import 'package:traffic_fine_system_mobileapp/services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ── palette ──────────────────────────────────────────────────────────────
  static const _navy      = Color(0xFF0D2B55);
  static const _blue      = Color(0xFF1A6FD4);
  static const _amber     = Color(0xFFF5A623);
  static const _slate     = Color(0xFFF0F4FA);
  static const _textDark  = Color(0xFF0D2B55);
  static const _textMid   = Color(0xFF6B7A99);

  String _getGreeting() {
    final hour = DateTime.now().hour; // Gets the current hour (0-23)

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // ── menu items (logic unchanged) ────────────────────────────────────────
  final List<_MenuItem> _items = [
    _MenuItem(
      label: 'Pay Fine',
      subtitle: 'Settle outstanding fines',
      icon: Icons.payments_rounded,
      onTap: null,
    ),
    _MenuItem(
      label: 'My Fines',
      subtitle: 'View fine history',
      icon: Icons.receipt_long_rounded,
      onTap: null,
    ),
    _MenuItem(
      label: 'Fine Details',
      subtitle: 'Inspect a specific fine',
      icon: Icons.manage_search_rounded,
      onTap: null,
    ),
    _MenuItem(
      label: 'Profile',
      subtitle: 'Manage your account',
      icon: Icons.person_rounded,
      onTap: null,
    ),
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
          MaterialPageRoute(builder: (_) => const HistoryPage()),
        );
        return;
      case 'Profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PersonalInfoPage()),
        );
        return;
      case 'Fine Details':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FineDetailsPage()),
        );
        return;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open "${it.label}" — implement screen.')),
        );
    }
  }

  // ── header widget ────────────────────────────────────────────────────────
  Widget _buildHeader(String name) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_navy, Color(0xFF1A4080)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // top row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.local_police_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'TrafficFine',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // greeting
              Text(
                _getGreeting(),
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              // outstanding fines banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _amber.withOpacity(0.4), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _amber.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded,
                          color: _amber, size: 16),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        '2 outstanding fines pending payment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: Colors.white54, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── action card ──────────────────────────────────────────────────────────
  Widget _buildActionCard(_MenuItem it) {
    return GestureDetector(
      onTap: () => _onTapItem(it),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _navy.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(it.icon, color: _blue, size: 22),
              ),
              const Spacer(),
              // label
              Text(
                it.label,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                it.subtitle,
                style: const TextStyle(
                  color: _textMid,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── add tile ─────────────────────────────────────────────────────────────
  Widget _buildAddTile() => GestureDetector(
    onTap: () {},
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD8E2F0),
          width: 1.5,
          // dashed border approximation via solid with low opacity
        ),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _slate,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add_rounded, color: _textMid, size: 22),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add',
            style: TextStyle(
              color: _textMid,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );

  // ── build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    String userName = ApiService.currentUser?['name'] ?? 'User';
    return Scaffold(
      backgroundColor: _slate,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: _navy,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(userName),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      color: _textDark,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'What would you like to do today?',
                    style: TextStyle(
                      color: _textMid,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: _items.length + 1,
                    itemBuilder: (context, i) {
                      if (i == _items.length) return _buildAddTile();
                      return _buildActionCard(_items[i]);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── data class ───────────────────────────────────────────────────────────────
class _MenuItem {
  _MenuItem({
    required this.label,
    this.subtitle = '',
    required this.icon,
    this.onTap,
  });
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
}