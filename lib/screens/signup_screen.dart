import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _loc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Header with logo
              ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  -1,  0,  0, 0, 255,
                   0, -1,  0, 0, 255,
                   0,  0, -1, 0, 255,
                   0,  0,  0, 1,   0,
                ]),
                child: Image.asset(
                  'assets/images/echo_logo.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'REAL-TIME DISASTER RESPONSE NETWORK',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  letterSpacing: 3,
                  color: C.onSurfaceVar,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Card
              Container(
                decoration: BoxDecoration(
                  color: C.surfaceMid,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: C.outlineVar.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.all(32),
                child: Stack(
                  children: [
                    // Grain texture (subtle gradient fallback)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.03,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.transparent,
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'INITIALIZE ACCESS',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            color: C.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _label('Full Name'),
                        const SizedBox(height: 8),
                        _field(_name, 'Johnathan Doe', TextInputType.name),
                        const SizedBox(height: 20),
                        _label('Phone Number'),
                        const SizedBox(height: 8),
                        _field(
                            _phone, '+1 (555) 000-0000', TextInputType.phone),
                        const SizedBox(height: 20),
                        _label('Location'),
                        const SizedBox(height: 8),
                        _locationField(),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () async {
                              try {
                                await FirebaseAuth.instance.signInAnonymously();
                                if (context.mounted) {
                                  Navigator.of(context).pushReplacementNamed('/home');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Auth Error: $e')),
                                  );
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: C.primary,
                              foregroundColor: C.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'SIGN UP',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                letterSpacing: 3,
                                color: C.onPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: Color(0x1AFFFFFF)),
                        const SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context)
                                .pushReplacementNamed('/home'),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: C.onSurfaceVar),
                                children: [
                                  TextSpan(
                                      text: 'Already part of the network? '),
                                  TextSpan(
                                    text: 'Log in',
                                    style: TextStyle(
                                        color: C.primary,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: C.primary),
                      ),
                      const SizedBox(width: 8),
                      const Text('SYSTEM LIVE',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              letterSpacing: 2,
                              color: C.outline)),
                    ],
                  ),
                  const Text('v2.4.0 tactical',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          letterSpacing: 2,
                          color: C.outline)),
                ],
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
      // Floating SOS
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed('/sos'),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: C.errorContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: C.error.withOpacity(0.3),
                  blurRadius: 24,
                  spreadRadius: 4)
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sos, color: C.error, size: 28),
              Text('SOS',
                  style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: C.error)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(
        t.toUpperCase(),
        style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
            color: C.onSurfaceVar),
      );

  Widget _field(TextEditingController ctrl, String hint, TextInputType type) =>
      TextField(
        controller: ctrl,
        keyboardType: type,
        style: const TextStyle(fontFamily: 'Inter', color: C.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: C.outlineVar),
          filled: true,
          fillColor: C.surfaceLow,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: C.primary)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      );

  Widget _locationField() => TextField(
        controller: _loc,
        style: const TextStyle(fontFamily: 'Inter', color: C.onSurface),
        decoration: InputDecoration(
          hintText: 'Search coordinates or city',
          hintStyle: const TextStyle(color: C.outlineVar),
          filled: true,
          fillColor: C.surfaceLow,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: C.primary)),
          contentPadding:
              const EdgeInsets.only(left: 16, top: 18, bottom: 18, right: 50),
          suffixIcon: const Icon(Icons.my_location, color: C.primary, size: 20),
        ),
      );
}
