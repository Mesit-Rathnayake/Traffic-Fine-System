import 'package:flutter/material.dart';
import 'package:traffic_fine_system_mobileapp/services/api_service.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _fineRef = TextEditingController();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _license = TextEditingController();
  final _amount = TextEditingController();
  final _card = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();

  String? _category;
  bool _loading = false;
  bool _lookupLoading = false;
  String? _lookupMessage;
  bool _lookupIsError = false;
  Map<String, dynamic>? _loadedFine;

  final List<Map<String, String>> _categories = [
    {'value': 'SPEEDING', 'label': 'Speeding'},
    {'value': 'RED_LIGHT', 'label': 'Running Red Light'},
    {'value': 'NO_SEAT_BELT', 'label': 'Not Wearing Seat Belt'},
    {'value': 'PARKING', 'label': 'Illegal Parking'},
    {'value': 'DOCUMENTARY', 'label': 'Documentary Offense'},
    {'value': 'OTHER', 'label': 'Other'},
  ];

  @override
  void dispose() {
    _fineRef.dispose();
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _license.dispose();
    _amount.dispose();
    _card.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  void _clear() {
    setState(() {
      _fineRef.clear();
      _fullName.clear();
      _email.clear();
      _phone.clear();
      _license.clear();
      _amount.clear();
      _card.clear();
      _expiry.clear();
      _cvv.clear();
      _category = null;
      _lookupMessage = null;
      _lookupIsError = false;
      _loadedFine = null;
    });
  }

  String _formatDate(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return value?.toString() ?? 'N/A';
    return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
  }

  String _formatAmount(dynamic value) {
    final amount = double.tryParse(value?.toString() ?? '') ?? 0;
    final decimals = amount == amount.roundToDouble() ? 0 : 2;
    return amount.toStringAsFixed(decimals);
  }

  Future<void> _lookupFine() async {
    final reference = _fineRef.text.trim();

    if (reference.isEmpty) {
      setState(() {
        _lookupMessage = 'Enter a fine reference number first.';
        _lookupIsError = true;
        _loadedFine = null;
      });
      return;
    }

    setState(() {
      _lookupLoading = true;
      _lookupMessage = null;
      _lookupIsError = false;
    });

    try {
      final fine = await ApiService.fetchFine(reference);
      if (!mounted) return;

      if (fine == null) {
        setState(() {
          _loadedFine = null;
          _lookupMessage = 'No fine found for that reference number.';
          _lookupIsError = true;
        });
        return;
      }

      final normalizedCategory = fine['category']?.toString().toUpperCase();
      setState(() {
        _loadedFine = fine;
        _lookupMessage = 'Fine loaded. Review the details before paying.';
        _lookupIsError = false;
        _category = _categories.any((cat) => cat['value'] == normalizedCategory)
            ? normalizedCategory
            : _category;
        _amount.text = _formatAmount(fine['amount']);
        _fullName.text = fine['driverName']?.toString() ?? _fullName.text;
        _license.text = fine['driverLicense']?.toString() ?? _license.text;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadedFine = null;
        _lookupMessage = error.toString().replaceFirst('Exception: ', '');
        _lookupIsError = true;
      });
    } finally {
      if (!mounted) return;
      setState(() => _lookupLoading = false);
    }
  }

  String _formatCard(String v) {
    final digits = v.replaceAll(RegExp(r'\s+'), '');
    final groups = <String>[];
    for (var i = 0; i < digits.length; i += 4) {
      groups.add(
        digits.substring(i, i + 4 > digits.length ? digits.length : i + 4),
      );
    }
    return groups.join(' ');
  }

  void _onCardChanged(String v) {
    final formatted = _formatCard(v);
    if (formatted != _card.text) {
      _card.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _onExpiryChanged(String v) {
    var digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    if (digits.length >= 3) {
      digits = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }
    if (digits != _expiry.text) {
      _expiry.value = TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    try {
      final amount = double.tryParse(_amount.text.trim()) ?? 0;
      final success = await ApiService.payFine({
        'referenceNumber': _fineRef.text.trim(),
        'amount': amount,
      });

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment processed successfully.')),
        );
        _clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment failed. Check the reference number and try again.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to connect to the payment service.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  InputDecoration _inputDec({
    required String hint,
    required IconData icon,
    String? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
      suffixText: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE53935)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 18, color: primary),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Divider(height: 20, thickness: 1, color: Colors.grey.shade100),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
          children: required
              ? [
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Color(0xFFE53935)),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  Widget _gap([double h = 14]) => SizedBox(height: h);

  Widget _buildLookupSummary() {
    if (_loadedFine == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7E3F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Loaded fine',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF123B73),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _loadedFine!['referenceNumber']?.toString() ?? 'N/A',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D2B55),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(
                'Driver',
                _loadedFine!['driverName']?.toString() ?? 'N/A',
              ),
              _infoChip(
                'License',
                _loadedFine!['driverLicense']?.toString() ?? 'N/A',
              ),
              _infoChip(
                'Vehicle',
                _loadedFine!['vehicleNumber']?.toString() ?? 'N/A',
              ),
              _infoChip(
                'Amount',
                'LKR ${_formatAmount(_loadedFine!['amount'])}',
              ),
              _infoChip('Status', _loadedFine!['status']?.toString() ?? 'N/A'),
              _infoChip('Date', _formatDate(_loadedFine!['offenseDate'])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF123B73),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: const BackButton(),
        title: const Text(
          'Traffic Fine Payment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _clear,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Clear form',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF123B73), primary],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure payment journey',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Complete your traffic fine payment in a few simple steps.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Fine Details',
              icon: Icons.confirmation_number_outlined,
              children: [
                _label('Reference Number'),
                TextFormField(
                  controller: _fineRef,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (_) => _lookupFine(),
                  decoration:
                      _inputDec(
                        hint: 'e.g. TF-2024-00123',
                        icon: Icons.tag,
                        suffix: null,
                      ).copyWith(
                        suffixIcon: IconButton(
                          onPressed: _lookupLoading ? null : _lookupFine,
                          icon: _lookupLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.search_rounded),
                          tooltip: 'Load fine data',
                        ),
                      ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Fine reference number is required'
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  _lookupLoading
                      ? 'Loading fine data...'
                      : 'Tap the search icon or press Enter to load the fine.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (_lookupMessage != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _lookupIsError
                          ? const Color(0xFFFFE6E6)
                          : const Color(0xFFE8F8EF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _lookupIsError
                            ? const Color(0xFFE3A7A7)
                            : const Color(0xFFB5E3C8),
                      ),
                    ),
                    child: Text(
                      _lookupMessage!,
                      style: TextStyle(
                        color: _lookupIsError
                            ? const Color(0xFF8A1F1F)
                            : const Color(0xFF1E6B3D),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                _buildLookupSummary(),
                _gap(),
                _label('Fine Category'),
                DropdownButtonFormField<String>(
                  value: _category,
                  isExpanded: true,
                  items: _categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c['value'],
                          child: Text(
                            c['label']!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _category = v),
                  decoration: _inputDec(
                    hint: 'Select violation type',
                    icon: Icons.category_outlined,
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Please select a fine category'
                      : null,
                ),
              ],
            ),
            _sectionCard(
              title: 'Personal Information',
              icon: Icons.person_outline,
              children: [
                _label('Full Name'),
                TextFormField(
                  controller: _fullName,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDec(
                    hint: 'As on your NIC',
                    icon: Icons.badge_outlined,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Full name is required'
                      : null,
                ),
                _gap(),
                _label('Email Address'),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDec(
                    hint: 'Receipt will be sent here',
                    icon: Icons.mail_outline,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                _gap(),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Phone Number'),
                          TextFormField(
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDec(
                              hint: '07X XXX XXXX',
                              icon: Icons.phone_outlined,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Phone number is required'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('License No.', required: false),
                          TextFormField(
                            controller: _license,
                            decoration: _inputDec(
                              hint: 'Optional',
                              icon: Icons.drive_file_rename_outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _sectionCard(
              title: 'Payment',
              icon: Icons.credit_card_outlined,
              children: [
                _label('Fine Amount'),
                TextFormField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDec(
                    hint: '0.00',
                    icon: Icons.payments_outlined,
                    suffix: 'LKR',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Amount is required'
                      : null,
                ),
                _gap(16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock, size: 14, color: Color(0xFF2E7D32)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Your card details are encrypted and secure',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _gap(14),
                _label('Card Number'),
                TextFormField(
                  controller: _card,
                  keyboardType: TextInputType.number,
                  decoration: _inputDec(
                    hint: '1234  5678  9012  3456',
                    icon: Icons.credit_card,
                  ),
                  onChanged: _onCardChanged,
                  validator: (v) =>
                      (v == null || v.replaceAll(' ', '').length < 12)
                      ? 'Card number is required'
                      : null,
                ),
                _gap(),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Expiry Date'),
                          TextFormField(
                            controller: _expiry,
                            keyboardType: TextInputType.number,
                            decoration: _inputDec(
                              hint: 'MM/YY',
                              icon: Icons.calendar_today_outlined,
                            ),
                            onChanged: _onExpiryChanged,
                            validator: (v) =>
                                (v == null || v.length < 4) ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('CVV'),
                          TextFormField(
                            controller: _cvv,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            decoration: _inputDec(
                              hint: '•••',
                              icon: Icons.shield_outlined,
                            ),
                            validator: (v) =>
                                (v == null || v.length < 3) ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'By tapping "Pay Now" you agree to our Terms & Conditions.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF123B73),
              foregroundColor: Colors.white,
              disabledBackgroundColor: primary.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
