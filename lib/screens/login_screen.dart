import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';

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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/images/echo_logo.png', height: 64),
                const SizedBox(height: 12),
                const Text('WELCOME BACK', style: TextStyle(color: C.onSurfaceVar, fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700, letterSpacing: 2)),
                const SizedBox(height: 28),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: C.onSurface, fontFamily: 'Inter'),
                  decoration: InputDecoration(
                    hintText: 'Phone number (e.g. +91 98765 43210)',
                    hintStyle: const TextStyle(color: C.outlineVar),
                    filled: true,
                    fillColor: C.surfaceLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _loading ? null : _handleLogin,
                    style: TextButton.styleFrom(
                      backgroundColor: C.primary,
                      foregroundColor: C.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('LOG IN', style: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 2)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                  child: const Text('Create new account', style: TextStyle(color: C.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
