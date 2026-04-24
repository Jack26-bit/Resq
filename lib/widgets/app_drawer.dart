import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'shared.dart';

/// Reusable tactical drawer used across all shell screens.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

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
            const SizedBox(height: 8),

            // Navigation items
            _drawerNavItem(context, Icons.warning_amber_rounded,
                'DISASTER MODE', const Color(0xFFFF9500), '/disaster'),
            _drawerNavItem(context, Icons.military_tech, 'WAR MODE',
                const Color(0xFFFF3B30), '/war'),
            _drawerNavItem(context, Icons.location_city, 'LOCAL ZONE',
                const Color(0xFF34C759), '/local'),
            _drawerNavItem(context, Icons.sos, 'SOS SCREEN',
                const Color(0xFFFF3B30), '/sos'),

            const SizedBox(height: 8),
            const Divider(color: Color(0xFF2A2A2A), height: 1),
            const SizedBox(height: 16),

            // Data Transparency section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('DATA TRANSPARENCY',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: Color(0xFF666666))),
            ),
            const SizedBox(height: 12),
            _dataItem(
                Icons.gps_fixed, 'GPS Coordinates', '40.7128° N, 74.0060° W'),
            _dataItem(Icons.phone_android, 'Device Identity', 'RQ-UNIT-8F3A2C'),
            _dataItem(Icons.hub, 'Local Mesh ID', 'MESH-NODE-7B'),

            const Spacer(),
            // Footer version
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  PulseDot(color: C.green),
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

  Widget _drawerNavItem(BuildContext context, IconData icon, String label,
      Color accent, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(route);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(width: 14),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
                    color: Colors.white)),
            const Spacer(),
            Icon(Icons.chevron_right,
                color: accent.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
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
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: Color(0xFF888888))),
                Text(value,
                    style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
