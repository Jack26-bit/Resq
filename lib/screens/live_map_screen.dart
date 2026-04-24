import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/shared.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});
  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> with TickerProviderStateMixin {
  late AnimationController _pulse;
  late AnimationController _sheet;
  String _filter = 'ALL';
  bool _isAlertsExpanded = false;
  final _filters = ['ALL', 'SOS', 'SHELTER', 'MEDICAL', 'FIRE'];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _sheet = AnimationController(vsync: this, duration: const Duration(milliseconds: 300), value: 1.0);
  }

  @override
  void dispose() { _pulse.dispose(); _sheet.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: Column(
        children: [
          // Map header
          Container(
            decoration: const BoxDecoration(
              color: Color(0xB3131313),
              border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 64,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (_, __) => Icon(Icons.sensors,
                            color: C.primary.withValues(alpha: 0.4 + _pulse.value * 0.6), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text('LIVE MAP', style: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: C.surfaceHigh, borderRadius: BorderRadius.circular(6)),
                        child: const Row(children: [
                          Icon(Icons.wifi_tethering, color: Colors.greenAccent, size: 14),
                          SizedBox(width: 6),
                          Text('MESH ON', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.greenAccent)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const NewsTicker(
            text: 'SYS_LOG: Deployment in Sector 7 active  ·  INCIDENT_392: Resource Grid stabilized  ·  WEATHER_ALERT: Severe precipitation Zone B  ·  COMMS: AI Uplink 98.4%',
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _TacticalMapPainter())),
                Container(color: const Color(0x66000000)),
                // Filter chips
                Positioned(
                  top: 12, left: 0, right: 0,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: _filters.map((f) {
                        final sel = _filter == f;
                        return GestureDetector(
                          onTap: () => setState(() => _filter = f),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: sel ? C.primary : const Color(0xCC2A2A2A),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8)],
                            ),
                            child: Text(f, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: sel ? C.onPrimary : C.onSurface)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Map controls
                Positioned(
                  right: 12, top: 60,
                  child: Column(children: [
                    _mapBtn(Icons.add),
                    const SizedBox(height: 8),
                    _mapBtn(Icons.remove),
                    const SizedBox(height: 8),
                    Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(color: C.primary, borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: const Icon(Icons.my_location, color: C.onPrimary, size: 20),
                    ),
                  ]),
                ),
                ..._buildMarkers(context),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (details.primaryDelta! < -5 && !_isAlertsExpanded) {
                        setState(() => _isAlertsExpanded = true);
                      } else if (details.primaryDelta! > 5 && _isAlertsExpanded) {
                        setState(() => _isAlertsExpanded = false);
                      }
                    },
                    onTap: () {
                      setState(() => _isAlertsExpanded = !_isAlertsExpanded);
                    },
                    child: _buildBottomSheet(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapBtn(IconData icon) => Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: const Color(0xCC2A2A2A), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white, size: 20),
      );

  List<Widget> _buildMarkers(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    final markers = [
      {'top': 0.30, 'left': 0.35, 'color': C.error, 'icon': Icons.warning, 'label': 'FIRE_INCIDENT [04]'},
      {'top': 0.48, 'left': 0.60, 'color': C.primary, 'icon': Icons.medical_services, 'label': 'MEDICAL [02]'},
      {'top': 0.20, 'left': 0.55, 'color': Colors.greenAccent, 'icon': Icons.home, 'label': 'SHELTER [A]'},
    ];
    return markers.map((m) {
      final color = m['color'] as Color;
      // height of map area ~500
      const mapH = 500.0;
      return AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) => Positioned(
          top: mapH * (m['top'] as double),
          left: w * (m['left'] as double),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 32 + _pulse.value * 8, height: 32 + _pulse.value * 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15 + _pulse.value * 0.1)),
                  ),
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color,
                        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10)]),
                    child: Icon(m['icon'] as IconData, color: Colors.black, size: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xCC131313), borderRadius: BorderRadius.circular(3)),
                child: Text(m['label'] as String,
                    style: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildBottomSheet() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: const BoxDecoration(
        color: Color(0xF2131313),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Color(0x80000000), blurRadius: 50, offset: Offset(0, -20))],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(width: 44, height: 4, decoration: BoxDecoration(color: C.surfaceHighest, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Alerts', style: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.5, color: C.primary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: C.surfaceHighest, borderRadius: BorderRadius.circular(20)),
                child: const Text('3 NEARBY', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 10, letterSpacing: 1.5, color: Colors.white)),
              ),
            ],
          ),
          if (_isAlertsExpanded) ...[
            const SizedBox(height: 16),
            _alertRow(C.error, 'SOS #104', '0.4km away', 'Medical emergency reported'),
            const SizedBox(height: 12),
            _alertRow(Colors.greenAccent, 'SHELTER A', '1.2km away', 'Capacity: 120/200'),
            const SizedBox(height: 12),
            _alertRow(Colors.blueAccent, 'MEDICAL #3', '0.8km away', 'Staff on duty 24/7'),
          ] else ...[
            const SizedBox(height: 8),
            const Text('Tap or swipe up to expand', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.onSurfaceVar)),
          ],
        ],
      ),
    );
  }

  Widget _alertRow(Color color, String title, String dist, String desc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.surfaceLow,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 14, color: C.onSurface)),
                Text(desc, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.onSurfaceVar)),
              ],
            ),
          ),
          Text(dist, style: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700, fontSize: 13, color: color)),
        ],
      ),
    );
  }
}

class _TacticalMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dark base
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFF0A0A0A));
    // Grid
    final gridP = Paint()..color = const Color(0xFF181818)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridP);
    for (double y = 0; y < size.height; y += 40) canvas.drawLine(Offset(0, y), Offset(size.width, y), gridP);
    // Thicker major grid
    final major = Paint()..color = const Color(0xFF202020)..strokeWidth = 1.5;
    for (double x = 0; x < size.width; x += 120) canvas.drawLine(Offset(x, 0), Offset(x, size.height), major);
    for (double y = 0; y < size.height; y += 120) canvas.drawLine(Offset(0, y), Offset(size.width, y), major);
    // Red flood zone
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), 80,
        Paint()..color = const Color(0x1AFF453A));
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.6), 60,
        Paint()..color = const Color(0x0FFF453A));
  }
  @override
  bool shouldRepaint(_) => false;
}
