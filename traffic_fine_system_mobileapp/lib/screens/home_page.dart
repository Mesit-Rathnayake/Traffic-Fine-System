import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    });
  }

  String _formatCard(String v) {
    final digits = v.replaceAll(RegExp(r"\s+"), '');
    final groups = <String>[];
    for (var i = 0; i < digits.length; i += 4) {
      groups.add(digits.substring(i, i + 4 > digits.length ? digits.length : i + 4));
    }
    return groups.join(' ');
  }

  void _onCardChanged(String v) {
    final formatted = _formatCard(v);
    if (formatted != _card.text) {
      _card.value = TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
    }
  }

  void _onExpiryChanged(String v) {
    var digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    if (digits.length >= 3) {
      digits = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }
    if (digits != _expiry.text) {
      _expiry.value = TextEditingValue(text: digits, selection: TextSelection.collapsed(offset: digits.length));
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Payment processed successfully (mock). Receipt sent to email.'),
    ));

    _clear();
  }

  Widget _twoColumns(Widget a, Widget b, double width) {
    if (width >= 700) {
      return Row(children: [Expanded(child: a), const SizedBox(width: 12), Expanded(child: b)]);
    }
    return Column(children: [a, const SizedBox(height: 12), b]);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Traffic Fine System'),
        centerTitle: false,
        toolbarHeight: 72,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 6),
                  Text('Traffic Fine Payment', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text('Enter your fine details and payment information to complete the transaction', style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 18),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Fine Details
                        const SizedBox(height: 6),
                        Text('Fine Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                        const SizedBox(height: 12),
                        _twoColumns(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Fine Reference Number *'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _fineRef,
                                decoration: const InputDecoration(hintText: 'Enter reference number'),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Fine reference number is required' : null,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Fine Category *'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _category,
                                items: _categories.map((c) => DropdownMenuItem(value: c['value'], child: Text(c['label']!))).toList(),
                                onChanged: (v) => setState(() => _category = v),
                                decoration: const InputDecoration(),
                                validator: (v) => (v == null || v.isEmpty) ? 'Please select a fine category' : null,
                              ),
                            ],
                          ),
                          width,
                        ),

                        const SizedBox(height: 18),
                        // Personal Info
                        Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                        const SizedBox(height: 12),
                        _twoColumns(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Full Name *'),
                              const SizedBox(height: 6),
                              TextFormField(controller: _fullName, decoration: const InputDecoration(hintText: 'Enter your full name'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Email *'),
                              const SizedBox(height: 6),
                              TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Enter your email'), validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Email is required';
                                if (!v.contains('@')) return 'Enter a valid email';
                                return null;
                              }),
                            ],
                          ),
                          width,
                        ),

                        const SizedBox(height: 12),
                        _twoColumns(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Phone Number *'),
                              const SizedBox(height: 6),
                              TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Enter your phone number'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone number is required' : null),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('License Number'),
                              const SizedBox(height: 6),
                              TextFormField(controller: _license, decoration: const InputDecoration(hintText: 'Enter your license number')),
                            ],
                          ),
                          width,
                        ),

                        const SizedBox(height: 18),
                        // Payment Info
                        Text('Payment Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Fine Amount (LKR) *'),
                            const SizedBox(height: 6),
                            TextFormField(controller: _amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(hintText: 'Enter amount to pay'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Amount is required' : null),
                          ],
                        ),

                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('🔒 Your payment information is secure and encrypted', style: TextStyle(color: Colors.grey.shade700)),
                              const SizedBox(height: 12),
                              const Text('Card Number *'),
                              const SizedBox(height: 6),
                              TextFormField(controller: _card, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '1234 5678 9012 3456'), onChanged: _onCardChanged, validator: (v) => (v == null || v.replaceAll(' ', '').length < 12) ? 'Card number is required' : null),
                              const SizedBox(height: 12),
                              _twoColumns(
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Expiry Date *'), const SizedBox(height: 6), TextFormField(controller: _expiry, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'MM/YY'), onChanged: _onExpiryChanged, validator: (v) => (v == null || v.length < 4) ? 'Expiry is required' : null)]),
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('CVV *'), const SizedBox(height: 6), TextFormField(controller: _cvv, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '123'), validator: (v) => (v == null || v.length < 3) ? 'CVV is required' : null)]),
                                width,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                        Row(children: [
                          Expanded(
                            child: ElevatedButton(onPressed: _loading ? null : _submit, child: Text(_loading ? 'Processing...' : 'Pay Now')),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(onPressed: _clear, child: const Text('Clear'))
                        ]),

                        const SizedBox(height: 12),
                        Text('By clicking Pay Now, you agree to our terms and conditions. Your data is secured.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
