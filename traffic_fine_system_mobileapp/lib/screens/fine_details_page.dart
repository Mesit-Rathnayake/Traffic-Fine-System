import 'package:flutter/material.dart';

class FineDetailsPage extends StatefulWidget {
  const FineDetailsPage({super.key});

  @override
  State<FineDetailsPage> createState() => _FineDetailsPageState();
}

class _FineDetailsPageState extends State<FineDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _fineRef = TextEditingController();
  String? _category;

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
    super.dispose();
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _label(String text, {bool required = true}) => Padding(
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

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fine Details'),
        backgroundColor: const Color(0xFF123B73),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Reference Number'),
              TextFormField(
                controller: _fineRef,
                decoration: _inputDec(
                  hint: 'e.g. TF-2024-00123',
                  icon: Icons.tag,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Fine reference number is required'
                    : null,
              ),
              const SizedBox(height: 12),
              _label('Fine Category'),
              DropdownButtonFormField<String>(
                value: _category,
                isExpanded: true,
                items: _categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c['value'],
                        child: Text(c['label']!),
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
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fine details saved (mock)'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF123B73),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
