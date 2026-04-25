import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'shared.dart';

/// Reusable tactical drawer used across all shell screens.
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _cloudSync = true;
  bool _meshRelay = true;
  bool _fmReceiver = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: C.surfaceLow,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/echo_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('ECHO',
                            style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Colors.white)),
                        Text('TACTICAL COMMAND',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                letterSpacing: 2,
                                color: Color(0xFF666666))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: Color(0xFF666666), size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF2A2A2A), height: 1),
            const SizedBox(height: 16),

            // Data Transparency section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('SERVICES TRANSPARENCY',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: Color(0xFF666666))),
            ),
            const SizedBox(height: 12),
            _dataItem(Icons.gps_fixed, 'Real-time GPS', '40.7128° N, 74.0060° W'),
            _dataItem(Icons.phone_android, 'Device Mesh Identity', 'RQ-UNIT-8F3A2C'),
            _dataItem(Icons.sensors, 'Radio Frequency Access', 'VHF / UHF / FM'),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFF2A2A2A), height: 1),
            const SizedBox(height: 16),

            // Connectivity Controls
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('CONNECTIVITY CONTROLS',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: Color(0xFF666666))),
            ),
            const SizedBox(height: 8),
            _buildToggle(
              'Internet Cloud-Sync',
              _cloudSync,
              const Color(0xFF00E5FF),
              (v) => setState(() => _cloudSync = v),
            ),
            _buildToggle(
              'P2P Mesh Relay',
              _meshRelay,
              const Color(0xFF00E5FF),
              (v) => setState(() => _meshRelay = v),
            ),
            _buildToggle(
              'FM Receiver Mode',
              _fmReceiver,
              const Color(0xFFFF3B30),
              (v) => setState(() => _fmReceiver = v),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9500), size: 14),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '⚠️ Plug in headphones for antenna signal',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: Color(0xFFFF9500),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
            // Footer version
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const PulseDot(color: C.green),
                  const SizedBox(width: 8),
                  const Text('MESH NETWORK ACTIVE · v2.4.1',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          letterSpacing: 1.5,
                          color: Color(0xFF666666))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool value, Color activeColor, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? activeColor : const Color(0xFF444444),
              boxShadow: value
                  ? [BoxShadow(color: activeColor.withValues(alpha: 0.5), blurRadius: 6)]
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.white)),
        ],
      ),
      value: value,
      activeThumbColor: Colors.white,
      activeTrackColor: activeColor.withValues(alpha: 0.3),
      inactiveThumbColor: const Color(0xFF555555),
      inactiveTrackColor: const Color(0xFF2A2A2A),
      onChanged: onChanged,
    );
  }

  Widget _dataItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF555555), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Colors.white)),
                Text(value,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: Color(0xFF888888))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
