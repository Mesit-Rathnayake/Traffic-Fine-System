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
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.local_police, color: Theme.of(context).colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Traffic Fine System', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            Text('Pay fines quickly', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ])
        ]),
        centerTitle: false,
        toolbarHeight: 72,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.receipt_long, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Traffic Fine Payment', style: Theme.of(context).textTheme.headlineSmall),
                        Text('Enter your fine details and payment information', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                      ])
                    ]),
                    const SizedBox(height: 18),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(children: [Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text('Fine Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary))]),
                          const SizedBox(height: 12),

                          _twoColumns(
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Fine Reference Number *'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _fineRef,
                                decoration: InputDecoration(
                                  hintText: 'Enter reference number',
                                  prefixIcon: const Icon(Icons.confirmation_number),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Fine reference number is required' : null,
                              ),
                            ]),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Fine Category *'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _category,
                                items: _categories.map((c) => DropdownMenuItem(value: c['value'], child: Text(c['label']!))).toList(),
                                onChanged: (v) => setState(() => _category = v),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.category),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Please select a fine category' : null,
                              ),
                            ]),
                            width,
                          ),

                          const SizedBox(height: 18),
                          Row(children: [Icon(Icons.person, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary))]),
                          const SizedBox(height: 12),
                          _twoColumns(
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Full Name *'),
                              const SizedBox(height: 6),
                              TextFormField(controller: _fullName, decoration: InputDecoration(hintText: 'Enter your full name', prefixIcon: const Icon(Icons.person_outline), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null),
                            ]),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Email *'),
                              const SizedBox(height: 6),
                              TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(hintText: 'Enter your email', prefixIcon: const Icon(Icons.email), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Email is required';
                                if (!v.contains('@')) return 'Enter a valid email';
                                return null;
                              }),
                            ]),
                            width,
                          ),

                          const SizedBox(height: 12),
                          _twoColumns(
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Phone Number *'),
                              const SizedBox(height: 6),
                              TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: 'Enter your phone number', prefixIcon: const Icon(Icons.phone_android), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone number is required' : null),
                            ]),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('License Number'),
                              const SizedBox(height: 6),
                              TextFormField(controller: _license, decoration: InputDecoration(hintText: 'Enter your license number', prefixIcon: const Icon(Icons.badge), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
                            ]),
                            width,
                          ),

                          const SizedBox(height: 18),
                          Row(children: [Icon(Icons.payment, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text('Payment Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary))]),
                          const SizedBox(height: 12),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Fine Amount (LKR) *'),
                            const SizedBox(height: 6),
                            TextFormField(controller: _amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(hintText: 'Enter amount to pay', prefixIcon: const Icon(Icons.attach_money), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), validator: (v) => (v == null || v.trim().isEmpty) ? 'Amount is required' : null),
                          ]),

                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(10)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('🔒 Your payment information is secure and encrypted', style: TextStyle(color: Colors.grey.shade700)),
                              const SizedBox(height: 12),
                              const Text('Card Number *'),
                              const SizedBox(height: 6),
                              TextFormField(controller: _card, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: '1234 5678 9012 3456', prefixIcon: const Icon(Icons.credit_card), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), onChanged: _onCardChanged, validator: (v) => (v == null || v.replaceAll(' ', '').length < 12) ? 'Card number is required' : null),
                              const SizedBox(height: 12),
                              _twoColumns(
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  const Text('Expiry Date *'),
                                  const SizedBox(height: 6),
                                  TextFormField(controller: _expiry, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: 'MM/YY', prefixIcon: const Icon(Icons.calendar_month), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), onChanged: _onExpiryChanged, validator: (v) => (v == null || v.length < 4) ? 'Expiry is required' : null),
                                ]),
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  const Text('CVV *'),
                                  const SizedBox(height: 6),
                                  TextFormField(controller: _cvv, obscureText: true, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: '123', prefixIcon: const Icon(Icons.lock), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), validator: (v) => (v == null || v.length < 3) ? 'CVV is required' : null),
                                ]),
                                width,
                              ),
                            ]),
                          ),

                          const SizedBox(height: 18),
                          Row(children: [
                            Expanded(child: ElevatedButton.icon(onPressed: _loading ? null : _submit, icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.payments), label: Text(_loading ? 'Processing...' : 'Pay Now'))),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(onPressed: _clear, icon: const Icon(Icons.clear), label: const Text('Clear'))
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
      ),
    );
  }
}
