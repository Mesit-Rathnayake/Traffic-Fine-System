import 'package:flutter/material.dart';
import 'package:traffic_fine_system_mobileapp/services/api_service.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _license = TextEditingController();

  static const Color _primaryBlue = Color(0xFF123B73);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await ApiService.fetchUserProfile();
    if (userData != null) {
      setState(() {
        _fullName.text = userData['name'] ?? userData['fullName'] ?? '';
        _email.text = userData['email'] ?? '';
        _phone.text = userData['phone'] ?? '';
        _license.text = userData['license'] ?? '';
      });
    }
  }

  Future<void> _handlesave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final updatedData = {
      'name': _fullName.text,
      'email': _email.text,
      'phone': _phone.text,
      'license': _license.text,
    };

    // Send this to your backend
    bool success = await ApiService.updateUserProfile(updatedData);

    if (success) {
      if (!mounted) return;
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal information saved!'),
          backgroundColor: _primaryBlue,
        ),
      );
    }
  }

  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _license.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Personal information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(
              _isEditing ? 'Cancel' : 'Edit',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
        leading: const BackButton(),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar section ────────────────────────────────
                    const _AvatarHeader(),
                    const SizedBox(height: 20),

                    _InputField(
                      controller: _fullName,
                      hint: 'Full name',
                      icon: Icons.badge_outlined,
                      readOnly: !_isEditing, // Locks the field when not editing
                    ),

                    // ── Form card ─────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel(text: 'Full name', required: true),
                          _InputField(
                            controller: _fullName,
                            hint: 'As on your NIC',
                            icon: Icons.badge_outlined,
                            readOnly: !_isEditing,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Full name is required'
                                : null,
                          ),
                          const _FieldDivider(),
                          _FieldLabel(text: 'Email address', required: true),
                          _InputField(
                            controller: _email,
                            hint: 'Receipt will be sent here',
                            icon: Icons.mail_outline_rounded,
                            readOnly: !_isEditing,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!v.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const _FieldDivider(),

                          _FieldLabel(text: 'Phone number', required: true),
                          _InputField(
                            controller: _phone,
                            hint: '07X XXX XXXX',
                            icon: Icons.phone_outlined,
                            readOnly: !_isEditing,
                            keyboardType: TextInputType.phone,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Phone number is required'
                                : null,
                          ),
                          const _FieldDivider(),

                          _FieldLabel(text: 'Licence no.', required: false),
                          _InputField(
                            controller: _license,
                            hint: 'Optional',
                            icon: Icons.drive_file_rename_outline_rounded,
                            readOnly: !_isEditing,
                            isOptional: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    _RequiredNote(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Save button ─────────────────────────────────────────
            if (_isEditing) _SaveButton(onPressed: _handlesave),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar header
// ─────────────────────────────────────────────────────────────────────────────
class _AvatarHeader extends StatelessWidget {
  const _AvatarHeader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F1FB),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFB5D4F4), width: 2),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 34,
              color: Color(0xFF185FA5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your profile details',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Field label
// ─────────────────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;

  const _FieldLabel({required this.text, required this.required});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            letterSpacing: 0.1,
          ),
          children: [
            if (required)
              const TextSpan(
                text: '  *',
                style: TextStyle(
                  color: Color(0xFFA32D2D),
                  fontWeight: FontWeight.w700,
                ),
              )
            else
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'Optional',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Input field
// ─────────────────────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final bool readOnly;
  final bool isOptional;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.readOnly = false,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        validator: validator,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            size: 19,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          filled: true,
          fillColor: isOptional
              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.03)
              : (isDark ? Theme.of(context).colorScheme.surface : Colors.white),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.4),
              width: 0.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: isOptional
                  ? Theme.of(context).dividerColor.withOpacity(0.25)
                  : Theme.of(context).dividerColor.withOpacity(0.45),
              width: isOptional ? 0.5 : 0.5,
              style: isOptional ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF185FA5), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFA32D2D), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFA32D2D), width: 1.5),
          ),
          errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFA32D2D)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Divider between fields
// ─────────────────────────────────────────────────────────────────────────────
class _FieldDivider extends StatelessWidget {
  const _FieldDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 0.5,
        color: Theme.of(context).dividerColor.withOpacity(0.25),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Required fields note
// ─────────────────────────────────────────────────────────────────────────────
class _RequiredNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Required fields are marked with  *',
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Save button (pinned to bottom)
// ─────────────────────────────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SaveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text(
            'Save information',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF123B73),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
