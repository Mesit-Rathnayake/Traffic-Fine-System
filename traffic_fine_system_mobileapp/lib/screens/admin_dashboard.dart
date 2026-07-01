import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  Map<String, dynamic> _data = const {
    'totalCollections': 0,
    'districtCollections': [],
    'categoryBreakdown': [],
    'users': [],
    'fines': [],
    'payments': [],
    'accessMessage': '',
  };
  String _referenceNumber = '';
  bool _lookupLoading = false;
  String? _lookupError;
  Map<String, dynamic>? _lookupFine;

  bool get _isAdmin =>
      ApiService.currentUser?['role']?.toString().toUpperCase() == 'ADMIN';

  List<dynamic> get _districtCollections =>
      (_data['districtCollections'] as List?) ?? const [];

  List<dynamic> get _categoryBreakdown =>
      (_data['categoryBreakdown'] as List?) ?? const [];

  List<dynamic> get _users => (_data['users'] as List?) ?? const [];

  List<dynamic> get _fines => (_data['fines'] as List?) ?? const [];

  List<dynamic> get _payments => (_data['payments'] as List?) ?? const [];

  double get _districtCollectionsTotal {
    return _districtCollections.fold<double>(
      0,
      (sum, item) => sum + _asNumber(item is Map ? item['total'] : null),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard({bool refresh = false}) async {
    if (!mounted) return;

    setState(() {
      _error = null;
      _lookupError = null;
      if (refresh) {
        _refreshing = true;
      } else {
        _loading = true;
      }
    });

    if (!_isAdmin) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _refreshing = false;
        _error = 'Admin access is required to view this dashboard.';
      });
      return;
    }

    try {
      final results = await Future.wait([
        _safeFetchMap(
          'totalCollections',
          ApiService.dio.get('/admin/total-collections'),
        ),
        _safeFetchList(
          'districtCollections',
          ApiService.dio.get('/admin/district-collections'),
        ),
        _safeFetchList(
          'categoryBreakdown',
          ApiService.dio.get('/admin/category-breakdown'),
        ),
        _safeFetchList('users', ApiService.dio.get('/admin/users')),
        _safeFetchList('fines', ApiService.dio.get('/admin/fines')),
        _safeFetchList('payments', ApiService.dio.get('/admin/payments')),
        _safeFetchMessage(ApiService.checkAdminAccess()),
      ]);

      if (!mounted) return;

      final failures = <String>[];
      final nextData = <String, dynamic>{
        'totalCollections': 0,
        'districtCollections': [],
        'categoryBreakdown': [],
        'users': [],
        'fines': [],
        'payments': [],
        'accessMessage': 'Admin route access confirmed.',
      };

      for (final result in results) {
        if (result.ok) {
          nextData[result.key] = result.value;
        } else if (result.error != null) {
          failures.add(result.error!);
        }
      }

      setState(() {
        _data = nextData;
        _error = failures.isEmpty
            ? null
            : failures.length == 1
            ? failures.first
            : '${failures.length} admin requests failed. ${failures.first}';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _refreshing = false;
      });
    }
  }

  Future<void> _searchFine() async {
    final reference = _referenceNumber.trim();

    if (reference.isEmpty) {
      setState(() {
        _lookupError = 'Enter a fine reference number first.';
        _lookupFine = null;
      });
      return;
    }

    setState(() {
      _lookupLoading = true;
      _lookupError = null;
    });

    try {
      final fine = await ApiService.fetchFine(reference);
      if (!mounted) return;
      setState(() {
        _lookupFine = fine;
        _lookupError = fine == null
            ? 'No fine found for that reference number.'
            : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _lookupFine = null;
        _lookupError = _normalizeError(error);
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _lookupLoading = false;
      });
    }
  }

  String _normalizeError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<_FetchResult> _safeFetchMap(
    String key,
    Future<dynamic> request,
  ) async {
    try {
      final response = await request;
      final data = response?.data;
      final value = data is Map<String, dynamic>
          ? data
          : {'total': _asNumber(data)};
      return _FetchResult(key: key, value: value, ok: true);
    } catch (error) {
      return _FetchResult(key: key, ok: false, error: _normalizeError(error));
    }
  }

  Future<_FetchResult> _safeFetchList(
    String key,
    Future<dynamic> request,
  ) async {
    try {
      final response = await request;
      final data = response?.data;
      final value = data is List ? data : <dynamic>[];
      return _FetchResult(key: key, value: value, ok: true);
    } catch (error) {
      return _FetchResult(key: key, ok: false, error: _normalizeError(error));
    }
  }

  Future<_FetchResult> _safeFetchMessage(
    Future<Map<String, dynamic>> request,
  ) async {
    try {
      final data = await request;
      return _FetchResult(
        key: 'accessMessage',
        value: data['message']?.toString() ?? 'Admin route access confirmed.',
        ok: true,
      );
    } catch (error) {
      return _FetchResult(
        key: 'accessMessage',
        ok: false,
        error: _normalizeError(error),
      );
    }
  }

  double _asNumber(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatAmount(dynamic value) {
    final amount = _asNumber(value);
    final decimals = amount == amount.roundToDouble() ? 0 : 2;
    final parts = amount.toStringAsFixed(decimals).split('.');
    parts[0] = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return 'LKR ${parts.join('.')}';
  }

  String _formatInteger(dynamic value) {
    return _asNumber(value).toInt().toString();
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'N/A';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final hour = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
    final minute = parsed.minute.toString().padLeft(2, '0');
    final suffix = parsed.hour >= 12 ? 'PM' : 'AM';

    return '${parsed.day.toString().padLeft(2, '0')} ${months[parsed.month - 1]} ${parsed.year}, $hour:$minute $suffix';
  }

  String _capitalizeWords(dynamic value) {
    return (value?.toString() ?? 'Unknown')
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  Color _statusColor(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'SUCCESS':
      case 'PAID':
        return const Color(0xFF1A8C55);
      case 'PENDING':
        return const Color(0xFFE0A800);
      default:
        return const Color(0xFFD93025);
    }
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String hint,
    Color accent = const Color(0xFF0D2B55),
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, accent.withOpacity(0.88)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hint,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String eyebrow,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D2B55).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFF5A623),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0D2B55),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionPlaceholder(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4EAF2)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 13),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2B55), Color(0xFF1A4080)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Administrative Control Center',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Monitor collections, list users, inspect fines, and review payment activity.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.verified_user_rounded,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _data['accessMessage']?.toString().isNotEmpty == true
                      ? _data['accessMessage'].toString()
                      : 'Admin route access confirmed.',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              IconButton(
                onPressed: _refreshing
                    ? null
                    : () => _loadDashboard(refresh: true),
                icon: _refreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics() {
    final totalCollections = _formatAmount(_data['totalCollections']);
    final districtCount = _formatInteger(_districtCollections.length);
    final userCount = _formatInteger(_users.length);
    final paymentCount = _formatInteger(_payments.length);
    final paidFineCount = _formatInteger(
      _fines
          .where(
            (fine) =>
                fine is Map &&
                fine['status']?.toString().toUpperCase() == 'PAID',
          )
          .length,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;
        final cardWidth = wide
            ? (constraints.maxWidth - 36) / 4
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                label: 'Collections',
                value: totalCollections,
                hint: 'Successful payment total from the backend.',
                accent: const Color(0xFF0D2B55),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                label: 'Districts tracked',
                value: districtCount,
                hint:
                    '${_formatAmount(_districtCollectionsTotal)} across districts.',
                accent: const Color(0xFF1A6FD4),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                label: 'Users listed',
                value: userCount,
                hint: 'Latest users from the admin list endpoint.',
                accent: const Color(0xFFF5A623),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                label: 'Payments listed',
                value: paymentCount,
                hint: '$paidFineCount paid fines in the current slice.',
                accent: const Color(0xFF1A8C55),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDistrictCollections() {
    return _buildSectionCard(
      eyebrow: 'District collections',
      title: 'Where the money is collected',
      child: _districtCollections.isEmpty
          ? _buildSectionPlaceholder(
              'No district-level collection data is available yet.',
            )
          : Column(
              children: _districtCollections.map((item) {
                final map = item as Map;
                final district = map['district']?.toString() ?? 'UNKNOWN';
                final total = _asNumber(map['total']);
                final totalCollections = _asNumber(_data['totalCollections']);
                final share = totalCollections <= 0
                    ? 0
                    : (total / totalCollections) * 100;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                district,
                                style: const TextStyle(
                                  color: Color(0xFF0D2B55),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              _formatAmount(total),
                              style: const TextStyle(
                                color: Color(0xFF0D2B55),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${share.toStringAsFixed(1)}% of total collections',
                          style: const TextStyle(
                            color: Color(0xFF6B7A99),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: (share / 100).clamp(0.05, 1.0).toDouble(),
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE4EAF2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFF5A623),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final highestCount = _categoryBreakdown.fold<double>(0, (maxCount, item) {
      if (item is Map) {
        final count = _asNumber(item['count']);
        return count > maxCount ? count : maxCount;
      }
      return maxCount;
    });

    return _buildSectionCard(
      eyebrow: 'Fine categories',
      title: 'Category breakdown',
      child: _categoryBreakdown.isEmpty
          ? _buildSectionPlaceholder(
              'No category breakdown data is available yet.',
            )
          : Column(
              children: _categoryBreakdown.map((item) {
                final map = item as Map;
                final category = map['category']?.toString() ?? 'Unknown';
                final count = _asNumber(map['count']);
                final progress = highestCount <= 0 ? 0 : count / highestCount;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _capitalizeWords(category),
                              style: const TextStyle(
                                color: Color(0xFF0D2B55),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            _formatInteger(count),
                            style: const TextStyle(
                              color: Color(0xFF0D2B55),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.05, 1.0).toDouble(),
                          minHeight: 8,
                          backgroundColor: const Color(0xFFE4EAF2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF1A6FD4),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildLookupCard() {
    return _buildSectionCard(
      eyebrow: 'Fine lookup',
      title: 'Inspect a single fine reference',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (value) => _referenceNumber = value,
            decoration: const InputDecoration(
              labelText: 'Fine reference number',
              hintText: 'Enter reference number',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.search,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _lookupLoading ? null : _searchFine,
              child: _lookupLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Search fine'),
            ),
          ),
          if (_lookupError != null) ...[
            const SizedBox(height: 12),
            _buildStatusMessage(
              title: 'Lookup issue',
              message: _lookupError!,
              background: const Color(0xFFFFF1F2),
              foreground: const Color(0xFFB42318),
            ),
          ],
          if (_lookupFine != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4EAF2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _lookupFine!['referenceNumber']?.toString() ??
                              'UNKNOWN',
                          style: const TextStyle(
                            color: Color(0xFF0D2B55),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _buildStatusChip(
                        _lookupFine!['status']?.toString() ?? 'UNKNOWN',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Category: ${_capitalizeWords(_lookupFine!['category'])}',
                  ),
                  Text('Amount: ${_formatAmount(_lookupFine!['amount'])}'),
                  Text(
                    'District: ${_lookupFine!['district']?.toString() ?? 'N/A'}',
                  ),
                  Text(
                    'Driver: ${_lookupFine!['driverName']?.toString() ?? 'N/A'}',
                  ),
                  Text(
                    'Vehicle: ${_lookupFine!['vehicleNumber']?.toString() ?? 'N/A'}',
                  ),
                  Text(
                    'Offense date: ${_formatDate(_lookupFine!['offenseDate'])}',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUsersSection() {
    return _buildSectionCard(
      eyebrow: 'Users',
      title: 'Latest users from admin list',
      child: _users.isEmpty
          ? _buildSectionPlaceholder('No users available yet.')
          : Column(
              children: _users.map((item) {
                final map = item as Map;
                final name = map['name']?.toString() ?? 'Unknown user';
                final email = map['email']?.toString() ?? 'N/A';
                final role = map['role']?.toString() ?? 'Unknown';
                final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    tileColor: const Color(0xFFF7F9FC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF0D2B55),
                      child: Text(
                        initials,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(email),
                    trailing: _buildStatusChip(role),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildFinesSection() {
    return _buildSectionCard(
      eyebrow: 'Fines',
      title: 'Recent fines from the admin list',
      child: _fines.isEmpty
          ? _buildSectionPlaceholder('No fines available yet.')
          : Column(
              children: _fines.map((item) {
                final map = item as Map;
                final reference =
                    map['referenceNumber']?.toString() ?? 'UNKNOWN';
                final category = _capitalizeWords(map['category']);
                final status = map['status']?.toString() ?? 'UNKNOWN';
                final amount = _formatAmount(map['amount']);
                final driverName =
                    map['driverName']?.toString() ?? 'Driver unavailable';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                reference,
                                style: const TextStyle(
                                  color: Color(0xFF0D2B55),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            _buildStatusChip(status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('$category • $amount'),
                        Text(driverName),
                        Text(
                          'District: ${map['district']?.toString() ?? 'N/A'}',
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildPaymentsSection() {
    return _buildSectionCard(
      eyebrow: 'Payments',
      title: 'Recent payment activity',
      child: _payments.isEmpty
          ? _buildSectionPlaceholder('No payments available yet.')
          : Column(
              children: _payments.map((item) {
                final map = item as Map;
                final fine = map['fine'] as Map?;
                final reference =
                    fine?['referenceNumber']?.toString() ?? 'UNKNOWN';
                final amount = _formatAmount(map['amount']);
                final status = map['status']?.toString() ?? 'UNKNOWN';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reference,
                                style: const TextStyle(
                                  color: Color(0xFF0D2B55),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_capitalizeWords(fine?['category'])} • ${fine?['district']?.toString() ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Color(0xFF6B7A99),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(map['createdAt']),
                                style: const TextStyle(
                                  color: Color(0xFF6B7A99),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              amount,
                              style: const TextStyle(
                                color: Color(0xFF0D2B55),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildStatusChip(status),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildStatusMessage({
    required String title,
    required String message,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: foreground.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: foreground,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(color: foreground, fontSize: 12, height: 1.45),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: _refreshing ? null : () => _loadDashboard(refresh: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadDashboard(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _buildHero(),
            const SizedBox(height: 16),
            if (_error != null)
              _buildStatusMessage(
                title: 'Dashboard issue',
                message: _error!,
                background: const Color(0xFFFFF1F2),
                foreground: const Color(0xFFB42318),
              ),
            if (_error != null) const SizedBox(height: 16),
            if (!_isAdmin)
              _buildStatusMessage(
                title: 'Admin access required',
                message:
                    'The backend only allows this dashboard for users signed in with the ADMIN role.',
                background: const Color(0xFFFFF8E6),
                foreground: const Color(0xFF8A5C00),
              ),
            if (!_isAdmin) const SizedBox(height: 16),
            _buildMetrics(),
            const SizedBox(height: 16),
            _buildDistrictCollections(),
            const SizedBox(height: 16),
            _buildCategoryBreakdown(),
            const SizedBox(height: 16),
            _buildLookupCard(),
            const SizedBox(height: 16),
            _buildUsersSection(),
            const SizedBox(height: 16),
            _buildFinesSection(),
            const SizedBox(height: 16),
            _buildPaymentsSection(),
          ],
        ),
      ),
    );
  }
}

class _FetchResult {
  const _FetchResult({
    required this.key,
    this.value,
    this.error,
    required this.ok,
  });

  final String key;
  final dynamic value;
  final String? error;
  final bool ok;
}
