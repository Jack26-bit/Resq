import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../theme/colors.dart';
import '../widgets/ui_kit.dart';
import '../widgets/shared.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _pingCtrl;
  final bool _stealthMode = false;
  final bool _meshSharing = true;
  Position? _currentPosition;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pingCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
          );
        }
      }
    } catch (e) {
      debugPrint('Home location error: $e');
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _pingCtrl.dispose();
    super.dispose();
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
      body: ResqBackground(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: ResqPage(
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
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: _actionButton(
                              label: 'I NEED HELP',
                              color: C.error,
                              icon: Icons.sos,
                              onTap: () => Navigator.of(context).pushNamed('/sos'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _actionButton(
                              label: 'I CAN HELP',
                              color: C.green,
                              icon: Icons.volunteer_activism,
                              onTap: () => Navigator.of(context).pushNamed('/community'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: C.surfaceLowest.withValues(alpha: 0.92),
        border: Border(bottom: BorderSide(color: C.outlineVar.withValues(alpha: 0.6))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
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
                Expanded(
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: C.surfaceLow,
                      borderRadius: BorderRadius.circular(4),
                      border: Border(
                        left: BorderSide(
                          color: C.errorContainer.withValues(alpha: 0.9),
                          width: 2,
                        ),
                      ),
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
                                  color: C.onSurfaceVar),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _sendRapidSOS,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: C.errorContainer,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: C.error.withValues(alpha: 0.4)),
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
    final modes = [
      {
        'label': 'WAR MODE',
        'subtitle': 'Conflict response, safe corridors & supply chain',
        'icon': Icons.military_tech,
        'accent': C.error,
        'route': '/war',
      },
      {
        'label': 'DISASTER MODE',
        'subtitle': 'Flood, seismic, tsunami & wildfire monitoring',
        'icon': Icons.warning_amber_rounded,
        'accent': C.amber,
        'route': '/disaster',
      },
      {
        'label': 'LOCAL ZONE',
        'subtitle': 'Campus incidents, shelter & community alerts',
        'icon': Icons.location_city,
        'accent': C.green,
        'route': '/local',
      },
      {
        'label': 'LIVE MAP',
        'subtitle': 'Real-time hazard mapping & navigation',
        'icon': Icons.map,
        'accent': C.info,
        'route': '/map',
      },
      {
        'label': 'SMART SCAN',
        'subtitle': 'AI-powered damage assessment',
        'icon': Icons.document_scanner,
        'accent': C.primary,
        'route': '/scan',
      },
      {
        'label': 'TRANSLATE',
        'subtitle': 'Real-time offline translation',
        'icon': Icons.translate,
        'accent': C.info,
        'route': '/translate',
      },
      {
        'label': 'COMMUNITY',
        'subtitle': 'Connect with volunteers & resources',
        'icon': Icons.people,
        'accent': C.primary,
        'route': '/community',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1100 ? 3 : width >= 760 ? 2 : 1;
        final cardWidth = (width - ((columns - 1) * 12)) / columns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Tactical modes'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: modes
                  .map(
                    (mode) => SizedBox(
                      width: cardWidth,
                      child: _modeCard(
                        context,
                        label: mode['label'] as String,
                        subtitle: mode['subtitle'] as String,
                        icon: mode['icon'] as IconData,
                        accent: mode['accent'] as Color,
                        route: mode['route'] as String,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: C.surfaceLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: C.outlineVar.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.5,
                        color: C.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: C.onSurfaceVar,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: accent.withValues(alpha: 0.7), size: 22),
            ],
          ),
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
        Container(
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
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null 
                        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                        : const LatLng(13.1147, 77.6382), 
                    zoom: 16,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GRID LAT/LONG',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              _currentPosition != null
                                  ? '${_currentPosition!.latitude.toStringAsFixed(4)}° N, ${_currentPosition!.longitude.toStringAsFixed(4)}° E'
                                  : '13.1147° N, 77.6382° E',
                              style: const TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom expand button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/map'),
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
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.7), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 1,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1100 ? 4 : width >= 760 ? 3 : 2;
        final ratio = width >= 1100 ? 1.4 : 1.6;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: ratio,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final item = items[i];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: C.surfaceLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: C.outlineVar.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (item['label'] as String).toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['value'] as String,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                        ),
                  ),
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
                    Text(
                      item['sub'] as String,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
