import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';
import '../widgets/ui_kit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  bool _loading = false;

  Future<void> _handleLogin() async {
    final phone = _phone.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('user_uid');

      if (uid != null && uid.isNotEmpty) {
        // Update lastSeen and go to home
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'lastSeen': FieldValue.serverTimestamp()});

        if (mounted) Navigator.of(context).pushReplacementNamed('/home');
        return;
      }

      // If no local uid, attempt to find by phone in Firestore
      final q = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (q.docs.isNotEmpty) {
        final foundUid = q.docs.first['uid'] as String?;
        if (foundUid != null && foundUid.isNotEmpty) {
          await prefs.setString('user_uid', foundUid);
          await prefs.setString('user_phone', phone);
          if (mounted) Navigator.of(context).pushReplacementNamed('/home');
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No account found. Please sign up.'),
            backgroundColor: C.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e'), backgroundColor: C.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: ResqBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ResqPage(
                maxWidth: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    Image.asset('assets/images/echo_logo.png', height: 68),
                    const SizedBox(height: 16),
                    Text(
                      'WELCOME BACK',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: C.onSurfaceVar,
                            letterSpacing: 2.4,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ResqCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Continue session',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Use your device-linked phone number to reconnect.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          const ResqFieldLabel('Phone number'),
                          const SizedBox(height: 8),
                          ResqTextField(
                            controller: _phone,
                            hint: 'Phone number (e.g. +91 98765 43210)',
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              if (!_loading) {
                                _handleLogin();
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          ResqPrimaryButton(
                            label: 'LOG IN',
                            isLoading: _loading,
                            onPressed: _loading ? null : _handleLogin,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                              child: const Text('Create new account'),
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
      ),
    );
  }
}
