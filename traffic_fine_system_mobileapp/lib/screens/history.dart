import 'package:flutter/material.dart';

// ── Data model ───────────────────────────────────────────────────────────────
enum FineStatus { unpaid, paid }

class _Fine {
  const _Fine({
    required this.title,
    required this.ref,
    required this.date,
    required this.amount,
    required this.status,
    required this.icon,
  });
  final String title;
  final String ref;
  final String date;
  final int amount;
  final FineStatus status;
  final IconData icon;
}

// ── Page ─────────────────────────────────────────────────────────────────────
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  // ── palette (matches HomePage) ──────────────────────────────────────────
  static const _navy     = Color(0xFF0D2B55);
  static const _blue     = Color(0xFF1A6FD4);
  static const _amber    = Color(0xFFF5A623);
  static const _slate    = Color(0xFFF0F4FA);
  static const _red      = Color(0xFFD93025);
  static const _green    = Color(0xFF1A8C55);
  static const _textDark = Color(0xFF0D2B55);
  static const _textMid  = Color(0xFF6B7A99);

  // ── sample data ──────────────────────────────────────────────────────────
  static const _fines = [
    _Fine(
      title: 'Speeding',
      ref: 'FINE12345',
      date: '10 Jun 2026',
      amount: 5000,
      status: FineStatus.unpaid,
      icon: Icons.speed_rounded,
    ),
    _Fine(
      title: 'No Seatbelt',
      ref: 'FINE67890',
      date: '08 Jun 2026',
      amount: 3000,
      status: FineStatus.unpaid,
      icon: Icons.airline_seat_recline_normal_rounded,
    ),
    _Fine(
      title: 'Signal Violation',
      ref: 'FINE11223',
      date: '01 Jun 2026',
      amount: 4500,
      status: FineStatus.paid,
      icon: Icons.traffic_rounded,
    ),
    _Fine(
      title: 'Illegal Parking',
      ref: 'FINE44556',
      date: '22 May 2026',
      amount: 2000,
      status: FineStatus.paid,
      icon: Icons.local_parking_rounded,
    ),
  ];

  // ── helpers ──────────────────────────────────────────────────────────────
  int get _totalUnpaid => _fines
      .where((f) => f.status == FineStatus.unpaid)
      .fold(0, (sum, f) => sum + f.amount);

  int get _unpaidCount =>
      _fines.where((f) => f.status == FineStatus.unpaid).length;

  Color _statusColor(FineStatus s) =>
      s == FineStatus.unpaid ? _red : _green;

  Color _statusBg(FineStatus s) =>
      s == FineStatus.unpaid
          ? _red.withOpacity(0.08)
          : _green.withOpacity(0.08);

  String _statusLabel(FineStatus s) =>
      s == FineStatus.unpaid ? 'Unpaid' : 'Paid';

  // ── summary strip ────────────────────────────────────────────────────────
  Widget _buildSummary() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, Color(0xFF1A4080)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Outstanding',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'LKR ${_totalUnpaid.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_unpaidCount fine${_unpaidCount == 1 ? '' : 's'} pending payment',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _amber,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Pay Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── section header ───────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _textDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: _blue,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── fine card ────────────────────────────────────────────────────────────
  Widget _buildFineCard(_Fine fine) {
    final color = _statusColor(fine.status);
    final bg    = _statusBg(fine.status);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(fine.icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            // details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fine.title,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Ref: ${fine.ref}',
                    style: const TextStyle(
                      color: _textMid,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 10, color: _textMid),
                      const SizedBox(width: 4),
                      Text(
                        fine.date,
                        style: const TextStyle(
                          color: _textMid,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // right side
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'LKR ${fine.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _statusLabel(fine.status),
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final unpaid = _fines.where((f) => f.status == FineStatus.unpaid).toList();
    final paid   = _fines.where((f) => f.status == FineStatus.paid).toList();

    return Scaffold(
      backgroundColor: _slate,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Fines',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSummary(),
          if (unpaid.isNotEmpty) ...[
            _buildSectionHeader('Pending Payment', unpaid.length),
            ...unpaid.map(_buildFineCard),
          ],
          if (paid.isNotEmpty) ...[
            _buildSectionHeader('Paid', paid.length),
            ...paid.map(_buildFineCard),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}