import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/shared.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _pingCtrl;
  bool _stealthMode = false;
  bool _meshSharing = true;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pingCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _pingCtrl.dispose();
    super.dispose();
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void _sendRapidSOS() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.cell_tower, color: Colors.white),
            SizedBox(width: 12),
            Text('RAPID SOS BROADCAST SENT TO MESH',
                style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1)),
          ],
        ),
        backgroundColor: C.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  _buildSOSHero(),
                  const SizedBox(height: 32),
                  _buildModeCards(context),
                  const SizedBox(height: 32),
                  _buildFamilySection(),
                  const SizedBox(height: 32),
                  _buildLocalGrid(),
                  const SizedBox(height: 32),
                  _buildSystemDiagnostics(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xB3131313),
        border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
        boxShadow: [
          BoxShadow(
              color: Color(0x66000000), blurRadius: 40, offset: Offset(0, 20))
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Builder(
                    builder: (ctx) => GestureDetector(
                          onTap: () => _openDrawer(ctx),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child:
                                Icon(Icons.menu, color: Colors.white, size: 24),
                          ),
                        )),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0x80171717),
                      borderRadius: BorderRadius.circular(4),
                      border: const Border(
                          left: BorderSide(color: C.errorContainer, width: 2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          color: C.errorContainer,
                          child: const Center(
                            child: Text('LIVE',
                                style: TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 9,
                                    letterSpacing: 2,
                                    color: C.onErrorContainer)),
                          ),
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              'FLOOD WARNING: SECTOR 4-B — EVACUATE IMMEDIATELY',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: Color(0xFFCCCCCC)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendRapidSOS,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: C.errorContainer,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text('SOS',
                        style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 3,
                            color: C.onErrorContainer)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── SOS Hero ──────────────────────────────────────────────────────────────
  Widget _buildSOSHero() {
    return Column(
      children: [
        GestureDetector(
          onTap: _sendRapidSOS,
          child: AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, child) => Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulse ring
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                        .withValues(alpha: 0.04 + _pulseCtrl.value * 0.06),
                    border: Border.all(
                      color: Colors.white
                          .withValues(alpha: 0.08 + _pulseCtrl.value * 0.12),
                      width: 1.5,
                    ),
                  ),
                ),
                // Inner pulse ring
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                        .withValues(alpha: 0.04 + _pulseCtrl.value * 0.04),
                    border: Border.all(
                      color: Colors.white
                          .withValues(alpha: 0.12 + _pulseCtrl.value * 0.1),
                      width: 1,
                    ),
                  ),
                ),
                // Main white SOS button
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white.withValues(
                              alpha: 0.15 + _pulseCtrl.value * 0.20),
                          blurRadius: 50),
                      const BoxShadow(
                          color: Color(0x99000000),
                          blurRadius: 40,
                          offset: Offset(0, 8)),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emergency_share,
                          color: Colors.black, size: 48),
                      SizedBox(height: 4),
                      Text('SOS',
                          style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              letterSpacing: 4,
                              color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'EMERGENCY ASSISTANCE',
          style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w900,
              fontSize: 28,
              letterSpacing: -1,
              color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          'TAP TO TRIGGER PRIORITY RESPONSE',
          style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              letterSpacing: 2.5,
              color: Color(0xFF666666)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─── Mode Cards ────────────────────────────────────────────────────────────
  Widget _buildModeCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TACTICAL MODES',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                color: Color(0xFF666666))),
        const SizedBox(height: 12),
        _modeCard(
          context,
          label: 'WAR MODE',
          subtitle: 'Conflict response, safe corridors & supply chain',
          icon: Icons.military_tech,
          accent: const Color(0xFFFF3B30),
          route: '/war',
        ),
        const SizedBox(height: 12),
        _modeCard(
          context,
          label: 'DISASTER MODE',
          subtitle: 'Flood, seismic, tsunami & wildfire monitoring',
          icon: Icons.warning_amber_rounded,
          accent: const Color(0xFFFF9500),
          route: '/disaster',
        ),
        const SizedBox(height: 12),
        _modeCard(
          context,
          label: 'LOCAL ZONE',
          subtitle: 'Campus incidents, shelter & community alerts',
          icon: Icons.location_city,
          accent: const Color(0xFF34C759),
          route: '/local',
        ),
      ],
    );
  }

  Widget _modeCard(
    BuildContext context, {
    required String label,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: C.surfaceLow,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: accent, width: 3)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 0.5,
                          color: accent)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Color(0xFF888888))),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: accent.withValues(alpha: 0.6), size: 22),
          ],
        ),
      ),
    );
  }

  // ─── Family Safety ────────────────────────────────────────────────────────
  Widget _buildFamilySection() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(width: 4, height: 36, color: C.primary),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Family Safety',
                  style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                      letterSpacing: -0.5,
                      color: C.primary)),
            ),
            const Text('STATUS: MONITORED',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    letterSpacing: 2.5,
                    color: Color(0xFF666666))),
          ],
        ),
        const SizedBox(height: 16),
        _familyCard('Sarah Jenkins', 'Sector 4-B Shelter • 1.2km', 'SAFE',
            isSafe: true, isTransit: false),
        const SizedBox(height: 8),
        _familyCard('Mark Jenkins', 'Transit Road C-9 • 4.8km', 'IN TRANSIT',
            isSafe: false, isTransit: true),
        const SizedBox(height: 8),
        _familyCard('Elara Jenkins', 'Sector 4-B Shelter • 1.2km', 'SAFE',
            isSafe: true, isTransit: false),
      ],
    );
  }

  Widget _familyCard(String name, String location, String status,
      {required bool isSafe, required bool isTransit}) {
    final statusColor = isSafe ? C.green : C.error;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: C.surfaceLow, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: C.surfaceHigh,
                  border: Border.all(color: C.outlineVar, width: 2),
                ),
                child:
                    const Icon(Icons.person, color: C.onSurfaceVar, size: 28),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                    border: Border.all(color: C.bg, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on,
                      color: Color(0xFF666666), size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text(location,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Color(0xFF888888)),
                          overflow: TextOverflow.ellipsis)),
                ]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: statusColor)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (isTransit)
                    _iconBtn(Icons.priority_high, C.error,
                        C.error.withValues(alpha: 0.2))
                  else
                    _iconBtn(Icons.call, C.onSurface, C.surfaceHigh),
                  const SizedBox(width: 8),
                  _iconBtn(Icons.near_me, C.onSurface, C.surfaceHigh),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color fg, Color bg) => Container(
        width: 36,
        height: 36,
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: fg, size: 16),
      );

  // ─── Local Grid / Mini Map ────────────────────────────────────────────────
  Widget _buildLocalGrid() {
    return Column(
      children: [
        Row(
          children: [
            Container(width: 4, height: 36, color: C.outlineVar),
            const SizedBox(width: 12),
            const Text('Local Grid',
                style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                    letterSpacing: -0.5,
                    color: C.primary)),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _pingCtrl,
          builder: (_, __) => Container(
            height: 280,
            decoration: BoxDecoration(
              color: C.surfaceMid,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.outlineVar.withValues(alpha: 0.1)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  CustomPaint(painter: _GridPainter(), size: Size.infinite),
                  Container(color: const Color(0x66000000)),
                  // HUD top
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xCC0A0A0A),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('GRID LAT/LONG',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 9,
                                      letterSpacing: 2,
                                      color: Color(0xFF666666))),
                              Text('40.7128° N, 74.0060° W',
                                  style: TextStyle(
                                      fontFamily: 'SpaceGrotesk',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: C.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: C.error.withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber,
                                  color: C.error, size: 12),
                              SizedBox(width: 6),
                              Text('FLOODING DETECTED',
                                  style: TextStyle(
                                      fontFamily: 'SpaceGrotesk',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      color: C.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Center ping
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 40 + _pingCtrl.value * 20,
                          height: 40 + _pingCtrl.value * 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: C.primary.withValues(
                                alpha: 0.15 - _pingCtrl.value * 0.15),
                            border: Border.all(
                                color: C.primary.withValues(
                                    alpha: 0.3 - _pingCtrl.value * 0.3)),
                          ),
                        ),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: C.primary,
                              border: Border.all(color: C.bg, width: 2)),
                        ),
                      ],
                    ),
                  ),
                  // Bottom expand button
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 36,
                        height: 36,
                        color: Colors.white,
                        child: const Icon(Icons.fullscreen,
                            color: Colors.black, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── System Diagnostics ────────────────────────────────────────────────────
  Widget _buildSystemDiagnostics() {
    final items = [
      {'label': 'Battery', 'value': '84%', 'sub': null, 'bar': 0.84},
      {'label': 'Comm Link', 'value': 'ACTIVE', 'sub': null, 'bar': 0.75},
      {
        'label': 'ResQ AI',
        'value': 'READY',
        'sub': 'Offline Cache 4.2GB',
        'bar': null
      },
      {
        'label': 'Response',
        'value': '5 MIN',
        'sub': 'Est. TTR Sector 4',
        'bar': null
      },
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: C.surfaceLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text((item['label'] as String).toUpperCase(),
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Color(0xFF666666))),
              const SizedBox(height: 4),
              Text(item['value'] as String,
                  style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.white)),
              const Spacer(),
              if (item['bar'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item['bar'] as double,
                    backgroundColor: C.surfaceHigh,
                    valueColor: const AlwaysStoppedAnimation(C.primary),
                    minHeight: 4,
                  ),
                )
              else if (item['sub'] != null)
                Text(item['sub'] as String,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: Color(0xFF888888))),
            ],
          ),
        );
      },
    );
  }

  // ─── Tactical Drawer ───────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
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
                        borderRadius: BorderRadius.circular(8)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/echo_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

            const SizedBox(height: 8),
            const Divider(color: Color(0xFF2A2A2A), height: 1),
            const SizedBox(height: 8),

            // Toggles
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('OPERATIONAL SETTINGS',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: Color(0xFF666666))),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: const Text('Stealth Mode',
                  style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white)),
              subtitle: const Text('Hide device from public mesh',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Color(0xFF666666))),
              value: _stealthMode,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF444444),
              inactiveThumbColor: const Color(0xFF555555),
              inactiveTrackColor: const Color(0xFF2A2A2A),
              onChanged: (val) => setState(() => _stealthMode = val),
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: const Text('Mesh Sharing',
                  style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white)),
              subtitle: const Text('Help relay signals to others',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Color(0xFF666666))),
              value: _meshSharing,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF444444),
              inactiveThumbColor: const Color(0xFF555555),
              inactiveTrackColor: const Color(0xFF2A2A2A),
              onChanged: (val) => setState(() => _meshSharing = val),
            ),

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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += 40)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }

  @override
  bool shouldRepaint(_) => false;
}
