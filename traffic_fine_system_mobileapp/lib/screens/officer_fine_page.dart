import 'package:flutter/material.dart';

import '../services/api_service.dart';

class OfficerFinePage extends StatefulWidget {
  const OfficerFinePage({super.key});

  @override
  State<OfficerFinePage> createState() => _OfficerFinePageState();
}

class _OfficerFinePageState extends State<OfficerFinePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _districtController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverLicenseController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _offenseLocationController = TextEditingController();
  final _notesController = TextEditingController();
  final _offenseDateController = TextEditingController();

  String _category = '';
  DateTime? _offenseDate;
  bool _loading = false;
  String? _message;
  bool _messageIsError = false;
  Map<String, dynamic>? _createdFine;

  static const _categories = [
    ('SPEEDING', 'Speeding'),
    ('RED_LIGHT', 'Running Red Light'),
    ('NO_SEAT_BELT', 'Not Wearing Seat Belt'),
    ('PARKING', 'Illegal Parking'),
    ('DOCUMENTARY', 'Documentary Offense'),
    ('OTHER', 'Other'),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _districtController.dispose();
    _driverNameController.dispose();
    _driverLicenseController.dispose();
    _vehicleNumberController.dispose();
    _offenseLocationController.dispose();
    _notesController.dispose();
    _offenseDateController.dispose();
    super.dispose();
  }

  void _syncOffenseDateText() {
    _offenseDateController.text = _offenseDate == null
        ? ''
        : '${_offenseDate!.day.toString().padLeft(2, '0')}/${_offenseDate!.month.toString().padLeft(2, '0')}/${_offenseDate!.year}';
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _offenseDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (selected != null && mounted) {
      setState(() {
        _offenseDate = selected;
        _syncOffenseDateText();
      });
    }
  }

  Future<void> _submitFine() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_category.isEmpty) {
      setState(() {
        _message = 'Please select a fine category.';
        _messageIsError = true;
      });
      return;
    }

    if (_offenseDate == null) {
      setState(() {
        _message = 'Select the offense date.';
        _messageIsError = true;
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
      _messageIsError = false;
    });

    try {
      final response = await ApiService.dio.post(
        '/fines',
        data: {
          'category': _category,
          'amount': double.parse(_amountController.text.trim()),
          'district': _districtController.text.trim().isEmpty
              ? null
              : _districtController.text.trim(),
          'driverName': _driverNameController.text.trim(),
          'driverLicense': _driverLicenseController.text.trim(),
          'vehicleNumber': _vehicleNumberController.text.trim(),
          'offenseDate': _offenseDate!.toIso8601String(),
          'offenseLocation': _offenseLocationController.text.trim(),
          'notes': _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        },
      );

      final fine = response.data is Map<String, dynamic>
          ? response.data['fine'] ?? response.data
          : null;

      if (!mounted) return;
      setState(() {
        _createdFine = fine is Map<String, dynamic> ? fine : null;
        _message = 'Fine created successfully.';
        _messageIsError = false;
        _category = '';
        _amountController.clear();
        _districtController.clear();
        _driverNameController.clear();
        _driverLicenseController.clear();
        _vehicleNumberController.clear();
        _offenseLocationController.clear();
        _notesController.clear();
        _offenseDate = null;
        _offenseDateController.clear();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _message = error.toString().replaceFirst('Exception: ', '');
        _messageIsError = true;
      });
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2EA),
      appBar: AppBar(
        title: const Text('Officer Fine Entry'),
        backgroundColor: const Color(0xFF0B4F6C),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: const Text(
              'Sign out',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0B4F6C), Color(0xFF1B85B8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Officer fine entry',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Create a fine, generate the reference, and let the driver pay later.',
                        style: TextStyle(color: Colors.white70, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_message != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _messageIsError
                          ? const Color(0xFFFFE6E6)
                          : const Color(0xFFE8F8EF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _messageIsError
                            ? const Color(0xFFE3A7A7)
                            : const Color(0xFFB5E3C8),
                      ),
                    ),
                    child: Text(
                      _message!,
                      style: TextStyle(
                        color: _messageIsError
                            ? const Color(0xFF8A1F1F)
                            : const Color(0xFF1E6B3D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (_createdFine != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Created reference',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0B4F6C),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _createdFine!['referenceNumber']?.toString() ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D2B55),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Driver: ${_createdFine!['driverName']?.toString() ?? 'N/A'}',
                        ),
                        Text(
                          'Vehicle: ${_createdFine!['vehicleNumber']?.toString() ?? 'N/A'}',
                        ),
                        Text(
                          'Amount: LKR ${_createdFine!['amount']?.toString() ?? '0'}',
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fine details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0D2B55),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _category.isEmpty ? null : _category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: _categories
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item.$1,
                                child: Text(item.$2),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _category = value ?? ''),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Select a category'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount (LKR)',
                        ),
                        validator: (value) {
                          final amount = double.tryParse(value?.trim() ?? '');
                          if (amount == null || amount <= 0) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _districtController,
                        decoration: const InputDecoration(
                          labelText: 'District',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _driverNameController,
                        decoration: const InputDecoration(
                          labelText: 'Driver name',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter the driver name'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _driverLicenseController,
                        decoration: const InputDecoration(
                          labelText: 'Driver license',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter the license number'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _vehicleNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Vehicle number',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter the vehicle number'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        readOnly: true,
                        controller: _offenseDateController,
                        onTap: _pickDate,
                        decoration: const InputDecoration(
                          labelText: 'Offense date',
                          hintText: 'Select date',
                        ),
                        validator: (_) => _offenseDate == null
                            ? 'Select the offense date'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _offenseLocationController,
                        decoration: const InputDecoration(
                          labelText: 'Offense location',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter the offense location'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'Notes'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loading ? null : _submitFine,
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Submit fine'),
                      ),
                    ],
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
