import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/platform/bluetooth_mesh_support.dart';
import '../theme/colors.dart';
import '../widgets/ui_kit.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _loc = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkAlreadyLoggedIn();
  }

  /// If user has already signed up before, skip to home.
  Future<void> _checkAlreadyLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('user_uid');
    if (uid != null && uid.isNotEmpty && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Future<void> _requestPermissions() async {
    final permissions = <Permission>[
      Permission.location,
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.notification,
    ];

    if (supportsBluetoothMesh) {
      permissions.addAll([
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.nearbyWifiDevices,
      ]);
    }

    // Only request runtime permissions on Android/iOS — avoid calling
    // Permission.* on web where many permissions (like storage) are unsupported.
    if (isWebSupportedPermission()) {
      await permissions.request();
    }
  }

  Future<void> _handleSignUp() async {
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final loc = _loc.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in your name and phone number.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Generate a stable user ID for this device
      final prefs = await SharedPreferences.getInstance();
      String uid = prefs.getString('user_uid') ?? const Uuid().v4();

      // Save user profile to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'phone': phone,
        'location': loc,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Persist UID locally so the user stays "logged in"
      await prefs.setString('user_uid', uid);
      await prefs.setString('user_name', name);
      await prefs.setString('user_phone', phone);
      await prefs.setString('user_location', loc);

      await _requestPermissions();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: C.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleLogIn() async {
    // "Log in" just re-uses the locally persisted UID
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('user_uid');
    if (uid != null && uid.isNotEmpty) {
      // Update lastSeen in Firestore
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'lastSeen': FieldValue.serverTimestamp()});

      await _requestPermissions();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No existing account found. Please sign up.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: ResqBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 960;
              final hero = _buildHero(context, isWide: isWide);
              final form = _buildFormCard(context);

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ResqPage(
                  maxWidth: isWide ? 1120 : 560,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: hero),
                            const SizedBox(width: 32),
                            Expanded(child: form),
                          ],
                        )
                      else ...[
                        hero,
                        const SizedBox(height: 28),
                        form,
                      ],
                      const SizedBox(height: 24),
                      _buildFooter(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
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

  Widget _buildHero(BuildContext context, {required bool isWide}) {
    return Column(
      crossAxisAlignment:
          isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            -1, 0, 0, 0, 255,
            0, -1, 0, 0, 255,
            0, 0, -1, 0, 255,
            0, 0, 0, 1, 0,
          ]),
          child: Image.asset(
            'assets/images/echo_logo.png',
            height: 84,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'REAL-TIME DISASTER RESPONSE NETWORK',
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: 3,
                color: C.onSurfaceVar,
              ),
        ),
        const SizedBox(height: 20),
        Text(
          'Create a secure local profile to unlock mesh sync, SOS broadcast, and AI guidance.',
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: C.onSurfaceVar,
              ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            _capabilityChip(Icons.hub, 'Mesh sync ready'),
            _capabilityChip(Icons.sos, 'Priority alerts'),
            _capabilityChip(Icons.lock, 'Device-bound access'),
          ],
        ),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return ResqCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Initialize access',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: C.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            'Set up your identity to join the live response grid.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          const ResqFieldLabel('Full name'),
          const SizedBox(height: 8),
          ResqTextField(
            controller: _name,
            hint: 'Johnathan Doe',
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 18),
          const ResqFieldLabel('Phone number'),
          const SizedBox(height: 8),
          ResqTextField(
            controller: _phone,
            hint: '+91 98765 43210',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 18),
          const ResqFieldLabel('Location'),
          const SizedBox(height: 8),
          ResqTextField(
            controller: _loc,
            hint: 'City or pincode (e.g. 560016)',
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            suffixIcon: const Icon(Icons.my_location, color: C.primary, size: 20),
            onSubmitted: (_) {
              if (!_loading) {
                _handleSignUp();
              }
            },
          ),
          const SizedBox(height: 24),
          ResqPrimaryButton(
            label: 'SIGN UP',
            isLoading: _loading,
            onPressed: _loading ? null : _handleSignUp,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/login'),
              child: const Text('Already part of the network? Log in'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration:
                  const BoxDecoration(shape: BoxShape.circle, color: C.primary),
            ),
            const SizedBox(width: 8),
            Text(
              'SYSTEM LIVE',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: C.outline,
                    letterSpacing: 2,
                  ),
            ),
          ],
        ),
        Text(
          'v2.4.0 tactical',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: C.outline,
                letterSpacing: 2,
              ),
        ),
      ],
    );
  }

  Widget _capabilityChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: C.surfaceLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.outlineVar.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: C.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: C.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
