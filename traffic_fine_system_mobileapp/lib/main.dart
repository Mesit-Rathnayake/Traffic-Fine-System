import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'screens/home_page.dart';

const Color kOrange = Color(0xFFFF7A00);
const Color kLightOrange = Color(0xFFFFB36B);
const Color kDarkTeal = Color(0xFF0B4F6C);
const Color kBlue = Color(0xFF1B85B8);
const Color kBg = Color(0xFFF6F2EA);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: kDarkTeal).copyWith(
      primary: kDarkTeal,
      secondary: kOrange,
      background: kBg,
      surface: Colors.white,
      onPrimary: Colors.white,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Traffic Fine App',
      theme: ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: kBg,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: kOrange, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: kDarkTeal,
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
        '/payment-home': (context) => const HomePage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _floatController;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _lift;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat(reverse: true);
    _fade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _lift = Tween<double>(begin: 16, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_entryController, _floatController]),
        builder: (context, _) {
          final pulse = math.sin(_floatController.value * math.pi * 2);
          return Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF07111F),
                      Color(0xFF0B1B2D),
                      Color(0xFF132A40),
                      Color(0xFF0B1220),
                    ],
                    stops: [0.0, 0.35, 0.72, 1.0],
                  ),
                ),
              ),
              const CustomPaint(painter: _SplashBackdropPainter()),
              ..._particles(size, pulse),
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Opacity(
                      opacity: _fade.value,
                      child: Transform.translate(
                        offset: Offset(0, _lift.value),
                        child: Transform.scale(
                          scale: _scale.value,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 170,
                                width: 170,
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.24),
                                      Colors.white.withOpacity(0.06),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.72, 1.0],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyanAccent.withOpacity(
                                        0.14,
                                      ),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.35),
                                      blurRadius: 32,
                                      offset: const Offset(0, 18),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.18),
                                        Colors.white.withOpacity(0.05),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      height: 112,
                                      width: 112,
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFFFF7A00,
                                            ).withOpacity(0.22),
                                            blurRadius: 24,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/logo.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              const Text(
                                'Traffic Fine System',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Secure. Fast. Professional.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.74),
                                  fontSize: 14,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                width: 120,
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.55),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Loading your dashboard',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.72),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _particles(Size size, double pulse) {
    final specs = <_SplashParticleSpec>[
      const _SplashParticleSpec(top: 0.14, left: 0.12, size: 10, opacity: 0.72),
      const _SplashParticleSpec(top: 0.2, right: 0.14, size: 14, opacity: 0.55),
      const _SplashParticleSpec(top: 0.36, left: 0.2, size: 6, opacity: 0.48),
      const _SplashParticleSpec(
        bottom: 0.22,
        right: 0.18,
        size: 9,
        opacity: 0.5,
      ),
      const _SplashParticleSpec(
        bottom: 0.16,
        left: 0.16,
        size: 12,
        opacity: 0.42,
      ),
      const _SplashParticleSpec(top: 0.58, right: 0.08, size: 5, opacity: 0.4),
    ];

    return specs
        .map((spec) {
          final dx =
              math.sin((_floatController.value * math.pi * 2) + spec.phase) *
              spec.driftX;
          final dy =
              math.cos((_floatController.value * math.pi * 2) + spec.phase) *
              spec.driftY;
          return Positioned(
            top: spec.top != null ? size.height * spec.top! + dy : null,
            left: spec.left != null ? size.width * spec.left! + dx : null,
            right: spec.right != null ? size.width * spec.right! - dx : null,
            bottom: spec.bottom != null
                ? size.height * spec.bottom! - dy
                : null,
            child: Transform.scale(
              scale: 0.92 + (pulse * 0.03),
              child: Container(
                width: spec.size,
                height: spec.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(spec.opacity),
                      Colors.white.withOpacity(spec.opacity * 0.25),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(spec.opacity * 0.35),
                      blurRadius: 18,
                    ),
                  ],
                ),
              ),
            ),
          );
        })
        .toList(growable: false);
  }
}

class _SplashParticleSpec {
  const _SplashParticleSpec({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
    required this.opacity,
  }) : phase = (top ?? bottom ?? 0) * 7.0 + (left ?? right ?? 0) * 11.0,
       driftX = 6 + ((top ?? bottom ?? 0) * 12),
       driftY = 4 + ((left ?? right ?? 0) * 10);

  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double size;
  final double opacity;
  final double phase;
  final double driftX;
  final double driftY;
}

class _SplashBackdropPainter extends CustomPainter {
  const _SplashBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final topGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF54D7FF).withOpacity(0.28),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.5, size.height * 0.2),
              radius: size.shortestSide * 0.55,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.2),
      size.shortestSide * 0.55,
      topGlow,
    );

    final leftGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF2D8CFF).withOpacity(0.18),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.14, size.height * 0.58),
              radius: size.shortestSide * 0.48,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.14, size.height * 0.58),
      size.shortestSide * 0.48,
      leftGlow,
    );

    final bottomGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF8A5CFF).withOpacity(0.14),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.82, size.height * 0.88),
              radius: size.shortestSide * 0.42,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.88),
      size.shortestSide * 0.42,
      bottomGlow,
    );

    final lines = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final y = size.height * (0.14 + i * 0.16);
      canvas.drawLine(
        Offset(size.width * 0.12, y),
        Offset(size.width * 0.88, y - 18),
        lines,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ==================== AUTH SCREENS ====================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: kDarkTeal.withOpacity(0.06),
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      height: 88,
                      width: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kOrange, kLightOrange],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: kOrange.withOpacity(0.18),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.traffic,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: kDarkTeal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to continue managing your traffic fines.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 22),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Email address',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: kBlue,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Please enter your email';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: kBlue,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Please enter your password';
                            if (v.length < 6)
                              return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: kBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 26,
                      color: kDarkTeal,
                    ),
                    label: const Text(
                      'Continue with Google',
                      style: TextStyle(
                        color: kDarkTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don’t have an account? ',
                          style: TextStyle(fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/signup'),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: kOrange,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: kDarkTeal.withOpacity(0.06),
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      height: 88,
                      width: 88,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [kDarkTeal, kBlue]),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: kDarkTeal.withOpacity(0.12),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: kDarkTeal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Register to access traffic fine services.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 22),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Full name',
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: kBlue,
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter your name'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Email address',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: kBlue,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Please enter your email';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Phone number',
                            prefixIcon: Icon(
                              Icons.phone_outlined,
                              color: kBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: kBlue,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.length < 6)
                              return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _obscure,
                          decoration: const InputDecoration(
                            hintText: 'Confirm password',
                            prefixIcon: Icon(
                              Icons.lock_reset_outlined,
                              color: kBlue,
                            ),
                          ),
                          validator: (v) {
                            if (v != _passwordController.text)
                              return 'Passwords do not match';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: kDarkTeal),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: kOrange,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
