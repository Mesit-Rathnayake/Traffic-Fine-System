import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Palette ───────────────────────────────────────────────────────────────
class _Palette {
  static const bg         = Color(0xFFF4F6FB);
  static const surface    = Color(0xFFFFFFFF);
  static const navy       = Color(0xFF0F2A5E);
  static const navyLight  = Color(0xFF1A3E8C);
  static const accent     = Color(0xFFF97316);
  static const accentSoft = Color(0xFFFFF1E6);
  static const success    = Color(0xFF10B981);
  static const successSoft= Color(0xFFE8F7F2);
  static const danger     = Color(0xFFEF4444);
  static const dangerSoft = Color(0xFFFEEBEB);
  static const warning    = Color(0xFFF59E0B);
  static const textPrimary   = Color(0xFF0F2A5E);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted     = Color(0xFFB0BDCE);
}

// ─── Data models ────────────────────────────────────────────────────────────
class _ActionItem {
  const _ActionItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.color,
    required this.bgColor,
  });
  final String label;
  final IconData icon;
  final String route;
  final Color color;
  final Color bgColor;
}

class _RecentFine {
  const _RecentFine({
    required this.id,
    required this.offence,
    required this.date,
    required this.amount,
    required this.status,
  });
  final String id;
  final String offence;
  final String date;
  final String amount;
  final _FineStatus status;
}

enum _FineStatus { pending, paid, overdue }

// ─── Page ───────────────────────────────────────────────────────────────────
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  Animation<double>? _fade;

  final List<_ActionItem> _actions = const [
    _ActionItem(
      label: 'Pay Fine',
      icon: Icons.credit_card_rounded,
      route: '/payment-home',
      color: _Palette.navyLight,
      bgColor: Color(0xFFE8EFFC),
    ),
    _ActionItem(
      label: 'My Fines',
      icon: Icons.receipt_long_rounded,
      route: '/fines',
      color: _Palette.accent,
      bgColor: _Palette.accentSoft,
    ),
    _ActionItem(
      label: 'History',
      icon: Icons.history_rounded,
      route: '/history',
      color: Color(0xFF8B5CF6),
      bgColor: Color(0xFFF3EEFF),
    ),
    _ActionItem(
      label: 'Dispute',
      icon: Icons.gavel_rounded,
      route: '/dispute',
      color: _Palette.danger,
      bgColor: _Palette.dangerSoft,
    ),
    _ActionItem(
      label: 'Vehicles',
      icon: Icons.directions_car_rounded,
      route: '/vehicles',
      color: _Palette.success,
      bgColor: _Palette.successSoft,
    ),
    _ActionItem(
      label: 'Support',
      icon: Icons.headset_mic_rounded,
      route: '/support',
      color: _Palette.warning,
      bgColor: Color(0xFFFFF8E6),
    ),
  ];

  final List<_RecentFine> _fines = const [
    _RecentFine(
      id: 'TF-2024-0391',
      offence: 'Speeding — 72 in 60 zone',
      date: '18 May 2025',
      amount: 'LKR 5,000',
      status: _FineStatus.pending,
    ),
    _RecentFine(
      id: 'TF-2024-0284',
      offence: 'No-parking zone violation',
      date: '9 Apr 2025',
      amount: 'LKR 2,500',
      status: _FineStatus.paid,
    ),
    _RecentFine(
      id: 'TF-2024-0177',
      offence: 'Expired vehicle licence',
      date: '22 Feb 2025',
      amount: 'LKR 8,000',
      status: _FineStatus.overdue,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap(_ActionItem item) {
    if (item.route == '/payment-home') {
      Navigator.pushNamed(context, item.route);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _Palette.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          '${item.label} — route ${item.route} not yet implemented.',
          style: GoogleFonts.dmSans(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.bg,
      body: FadeTransition(
        opacity: _fade ?? AlwaysStoppedAnimation(1.0),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ── Stats ────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildStats(),
              ),
            ),

            // ── Quick Actions ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: _sectionHeader('Quick Actions'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: _actions.length,
                itemBuilder: (_, i) => _ActionCard(item: _actions[i], onTap: _onTap),
              ),
            ),

            // ── Recent Fines ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionHeader('Recent Fines'),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'View all',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: _Palette.navyLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              sliver: SliverList.separated(
                itemCount: _fines.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _FineCard(fine: _fines[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1F4E), Color(0xFF1A3E8C)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  Image.asset('assets/logo.png', width: 32, height: 32,
                      errorBuilder: (_, __, ___) => const Icon(
                            Icons.shield_rounded,
                            color: _Palette.accent,
                            size: 32,
                          )),
                  const SizedBox(width: 10),
                  Text(
                    'AutoPenalty',
                    style: GoogleFonts.syne(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const Spacer(),
                  // Notification bell
                  _HeaderIconButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () {},
                    badge: '2',
                  ),
                  const SizedBox(width: 10),
                  // Profile avatar
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30, width: 1.5),
                        color: Colors.white12,
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Greeting
              Text(
                'Good morning,',
                style: GoogleFonts.dmSans(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Sachintha Madumal 👋',
                style: GoogleFonts.syne(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.directions_car_rounded,
                      color: Colors.white54, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    'WP CAB-4820  •  WP CEJ-1133',
                    style: GoogleFonts.dmSans(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────
  Widget _buildStats() {
    return Row(
      children: [
        _StatCard(
          label: 'Outstanding',
          value: 'LKR 13,000',
          icon: Icons.warning_amber_rounded,
          color: _Palette.danger,
          bgColor: _Palette.dangerSoft,
          flex: 2,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Paid',
          value: 'LKR 2,500',
          icon: Icons.check_circle_outline_rounded,
          color: _Palette.success,
          bgColor: _Palette.successSoft,
          flex: 1,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Active',
          value: '3',
          icon: Icons.receipt_rounded,
          color: _Palette.navyLight,
          bgColor: const Color(0xFFE8EFFC),
          flex: 1,
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.syne(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _Palette.textPrimary,
        letterSpacing: 0.2,
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.badge,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 1.5),
              color: Colors.white12,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          if (badge != null)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: _Palette.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge!,
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.flex,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _Palette.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.syne(
                fontSize: flex == 2 ? 15 : 17,
                fontWeight: FontWeight.w700,
                color: _Palette.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: _Palette.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.item, required this.onTap});
  final _ActionItem item;
  final void Function(_ActionItem) onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _Palette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => onTap(item),
        borderRadius: BorderRadius.circular(16),
        splashColor: item.color.withOpacity(0.08),
        highlightColor: item.color.withOpacity(0.04),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: item.bgColor,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _Palette.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FineCard extends StatelessWidget {
  const _FineCard({required this.fine});
  final _RecentFine fine;

  Color get _statusColor => switch (fine.status) {
        _FineStatus.paid    => _Palette.success,
        _FineStatus.overdue => _Palette.danger,
        _FineStatus.pending => _Palette.warning,
      };

  Color get _statusBg => switch (fine.status) {
        _FineStatus.paid    => _Palette.successSoft,
        _FineStatus.overdue => _Palette.dangerSoft,
        _FineStatus.pending => const Color(0xFFFFF8E6),
      };

  String get _statusLabel => switch (fine.status) {
        _FineStatus.paid    => 'Paid',
        _FineStatus.overdue => 'Overdue',
        _FineStatus.pending => 'Pending',
      };

  IconData get _statusIcon => switch (fine.status) {
        _FineStatus.paid    => Icons.check_circle_rounded,
        _FineStatus.overdue => Icons.error_rounded,
        _FineStatus.pending => Icons.schedule_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _Palette.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _statusBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_statusIcon, color: _statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fine.offence,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _Palette.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      fine.id,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: _Palette.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '  •  ${fine.date}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: _Palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Right side
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fine.amount,
                style: GoogleFonts.syne(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _Palette.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}