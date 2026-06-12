import 'package:flutter/material.dart';

class FineDetailsPage extends StatefulWidget {
  const FineDetailsPage({super.key});

  @override
  State<FineDetailsPage> createState() => _FineDetailsPageState();
}

class _FineDetailsPageState extends State<FineDetailsPage> {
  double _demeritPoints = 24;

  Color _demeritColor(double points) {
    if (points <= 0) return const Color(0xFFE24B4A);
    if (points <= 8) return const Color(0xFFE24B4A);
    if (points <= 16) return const Color(0xFFEF9F27);
    return const Color(0xFF1D9E75);
  }

  String _demeritMessage(double points) {
    if (points == 0) return 'Licence suspended. Contact DMT immediately.';
    if (points <= 8) return 'Danger zone — one more offence may cost your licence.';
    if (points <= 16) return 'Warning zone — drive carefully to preserve your points.';
    return 'Licence in good standing.';
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF123B73);
    final Color cardBg = Theme.of(context).cardColor;
    final Color surfaceBg = Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Traffic Fines Sri Lanka 2026',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero card ──────────────────────────────────────────
            _HeroCard(primaryBlue: primaryBlue),
            const SizedBox(height: 20),

            // ── Penalty types ──────────────────────────────────────
            _SectionLabel(label: 'TYPES OF PENALTIES'),
            const SizedBox(height: 8),
            _PenaltyTypesCard(cardBg: cardBg),
            const SizedBox(height: 20),

            // ── Common fines ───────────────────────────────────────
            _SectionLabel(label: 'COMMON FINES'),
            const SizedBox(height: 8),
            _FinesCard(cardBg: cardBg),
            const SizedBox(height: 20),

            // ── How to pay ─────────────────────────────────────────
            _SectionLabel(label: 'HOW TO PAY'),
            const SizedBox(height: 8),
            _PaymentGrid(surfaceBg: surfaceBg),
            const SizedBox(height: 6),
            Text(
              'Payment updates your record automatically.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),

            // ── Demerit tracker ────────────────────────────────────
            _SectionLabel(label: 'DEMERIT POINTS TRACKER'),
            const SizedBox(height: 8),
            _DemeritCard(
              cardBg: cardBg,
              points: _demeritPoints,
              demeritColor: _demeritColor(_demeritPoints),
              message: _demeritMessage(_demeritPoints),
              onChanged: (v) => setState(() => _demeritPoints = v),
            ),
            const SizedBox(height: 20),

            // ── Key rules ──────────────────────────────────────────
            _SectionLabel(label: 'KEY RULES'),
            const SizedBox(height: 8),
            _RulesCard(cardBg: cardBg),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.9,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Base card wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _BaseCard extends StatelessWidget {
  final Widget child;
  final Color? color;

  const _BaseCard({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero card
// ─────────────────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final Color primaryBlue;
  const _HeroCard({required this.primaryBlue});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryBlue.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.gavel_rounded, color: primaryBlue, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete fine guide',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on the Motor Traffic Act (Chapter 203). Enforcement includes spot fines, court fines, and demerit points.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Penalty types card
// ─────────────────────────────────────────────────────────────────────────────
class _PenaltyTypesCard extends StatelessWidget {
  final Color cardBg;
  const _PenaltyTypesCard({required this.cardBg});

  @override
  Widget build(BuildContext context) {
    final penalties = [
      _PenaltyData(
        icon: Icons.receipt_long_rounded,
        iconBg: const Color(0xFFFAEEDA),
        iconColor: const Color(0xFFBA7517),
        title: 'Spot fines',
        subtitle: 'Paid on the spot or later via GovPay.',
      ),
      _PenaltyData(
        icon: Icons.account_balance_rounded,
        iconBg: const Color(0xFFFCEBEB),
        iconColor: const Color(0xFFA32D2D),
        title: 'Court fines',
        subtitle: 'Serious offences decided by court.',
      ),
      _PenaltyData(
        icon: Icons.stars_rounded,
        iconBg: const Color(0xFFE6F1FB),
        iconColor: const Color(0xFF185FA5),
        title: 'Demerit points',
        subtitle: 'Start with 24 points — lose points per offence.',
      ),
    ];

    return _BaseCard(
      child: Column(
        children: List.generate(penalties.length, (i) {
          final p = penalties[i];
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: p.iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(p.icon, color: p.iconColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.55),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (i < penalties.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    height: 0.5,
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _PenaltyData {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  const _PenaltyData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Fines card
// ─────────────────────────────────────────────────────────────────────────────
class _FinesCard extends StatelessWidget {
  final Color cardBg;
  const _FinesCard({required this.cardBg});

  @override
  Widget build(BuildContext context) {
    const dangerRed = Color(0xFFE24B4A);
    const fines = [
      ('Speeding', Icons.speed_rounded, 'Rs. 3,000 – 5,000+', false),
      ('No licence', Icons.badge_rounded, 'Rs. 25,000 – 50,000', false),
      ('Reckless driving', Icons.warning_amber_rounded, 'Rs. 10,000 – 40,000+', false),
      ('Red light violation', Icons.traffic_rounded, 'Rs. 5,000 – 25,000', false),
      ('Railway crossing', Icons.train_rounded, 'Rs. 25,000 – 40,000', false),
      ('No insurance', Icons.shield_outlined, 'Rs. 25,000 – 50,000', false),
      ('Drink driving', Icons.local_bar_rounded, 'Rs. 100,000+', true),
    ];

    return _BaseCard(
      child: Column(
        children: List.generate(fines.length, (i) {
          final (name, icon, amount, hasJail) = fines[i];
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: i == 0 ? 0 : 0,
                  bottom: 0,
                ),
                child: Row(
                  children: [
                    Icon(icon,
                        size: 18,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontSize: 13),
                          ),
                          if (hasJail) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: dangerRed.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '+ jail',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: dangerRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: dangerRed,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < fines.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Divider(
                    height: 0.5,
                    color: Theme.of(context).dividerColor.withOpacity(0.25),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment grid
// ─────────────────────────────────────────────────────────────────────────────
class _PaymentGrid extends StatelessWidget {
  final Color surfaceBg;
  const _PaymentGrid({required this.surfaceBg});

  @override
  Widget build(BuildContext context) {
    const infoBlue = Color(0xFF185FA5);
    const methods = [
      (Icons.smartphone_rounded, 'GovPay / bank apps'),
      (Icons.local_post_office_rounded, 'Post office'),
    ];

    return Column(
      children: [
        Row(
          children: methods
              .map(
                (m) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                        right: m == methods.first ? 8 : 0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(m.$1, color: infoBlue, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          m.$2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.account_balance_rounded,
                  color: infoBlue, size: 24),
              SizedBox(width: 10),
              Text(
                'Police station',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Demerit tracker card
// ─────────────────────────────────────────────────────────────────────────────
class _DemeritCard extends StatelessWidget {
  final Color cardBg;
  final double points;
  final Color demeritColor;
  final String message;
  final ValueChanged<double> onChanged;

  const _DemeritCard({
    required this.cardBg,
    required this.points,
    required this.demeritColor,
    required this.message,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot grid
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: List.generate(24, (i) {
              final filled = i < points.round();
              return Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: filled
                      ? demeritColor
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // Legend
          Row(
            children: [
              _LegendDot(color: const Color(0xFF1D9E75), label: 'Safe (17–24)'),
              const SizedBox(width: 14),
              _LegendDot(color: const Color(0xFFEF9F27), label: 'Warning (9–16)'),
              const SizedBox(width: 14),
              _LegendDot(color: const Color(0xFFE24B4A), label: 'Danger (1–8)'),
            ],
          ),
          const SizedBox(height: 16),

          // Slider
          Row(
            children: [
              Text(
                'Remaining points',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.55),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: demeritColor,
                    inactiveTrackColor:
                        demeritColor.withOpacity(0.18),
                    thumbColor: demeritColor,
                    overlayColor: demeritColor.withOpacity(0.12),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: points,
                    min: 0,
                    max: 24,
                    divisions: 24,
                    onChanged: onChanged,
                  ),
                ),
              ),
              SizedBox(
                width: 26,
                child: Text(
                  points.round().toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Status message
          Text(
            message,
            style: TextStyle(
                fontSize: 12, color: demeritColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rules card
// ─────────────────────────────────────────────────────────────────────────────
class _RulesCard extends StatelessWidget {
  final Color cardBg;
  const _RulesCard({required this.cardBg});

  @override
  Widget build(BuildContext context) {
    const infoBlue = Color(0xFF185FA5);
    const infoBg = Color(0xFFE6F1FB);
    const rules = [
      (Icons.badge_rounded, 'Carry your licence at all times while driving.'),
      (Icons.airline_seat_recline_normal_rounded,
          'Seatbelt required for driver and all passengers.'),
      (Icons.mobile_off_rounded, 'No mobile phone use while driving.'),
      (Icons.verified_user_rounded,
          'Vehicle insurance must be valid and in force.'),
      (Icons.local_police_rounded,
          'Police officers may issue spot fines on the road.'),
    ];

    return _BaseCard(
      child: Column(
        children: List.generate(rules.length, (i) {
          final (icon, text) = rules[i];
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: infoBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: infoBlue, size: 17),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        text,
                        style: const TextStyle(fontSize: 13, height: 1.45),
                      ),
                    ),
                  ),
                ],
              ),
              if (i < rules.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Divider(
                    height: 0.5,
                    color: Theme.of(context).dividerColor.withOpacity(0.25),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}