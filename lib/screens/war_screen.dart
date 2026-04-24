import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/shared.dart';

class WarScreen extends StatelessWidget {
  const WarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: Column(
        children: [
          ResQAppBar(
            title: 'WAR MODE',
            showBack: true,
            actions: const [
              Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.crisis_alert, color: C.error))
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Danger level hero
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('HIGH',
                                style: TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 72,
                                    letterSpacing: -4,
                                    color: C.primary,
                                    height: 0.9)),
                            const SizedBox(height: 8),
                            Row(children: [
                              Container(width: 4, height: 28, color: C.error),
                              const SizedBox(width: 10),
                              const Text('DANGER LEVEL',
                                  style: TextStyle(
                                      fontFamily: 'SpaceGrotesk',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      letterSpacing: 2,
                                      color: C.error)),
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: C.surfaceHigh,
                            borderRadius: BorderRadius.circular(12),
                            border: const Border(
                                left: BorderSide(color: C.primary, width: 2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Icon(Icons.warning,
                                    color: C.error, size: 18),
                                const SizedBox(width: 6),
                                const Text('ACTIVE THREATS',
                                    style: TextStyle(
                                        fontFamily: 'SpaceGrotesk',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10,
                                        letterSpacing: 1.5,
                                        color: Colors.white)),
                              ]),
                              const SizedBox(height: 10),
                              const Divider(color: C.outlineVar, height: 1),
                              const SizedBox(height: 10),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Airstrike Alert',
                                        style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: C.onSurface)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      color: C.error,
                                      child: const Text('ACTIVE',
                                          style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1,
                                              color: C.onError)),
                                    ),
                                  ]),
                              const SizedBox(height: 8),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Distance to zone',
                                        style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            color: C.onSurfaceVar)),
                                    const Text('1.2KM',
                                        style: TextStyle(
                                            fontFamily: 'SpaceGrotesk',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Colors.white)),
                                  ]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                      'Immediate kinetic activity detected in your sector. Tactical relocation advised.',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: C.onSurfaceVar,
                          height: 1.4)),
                  const SizedBox(height: 32),

                  // Tactical Overlay
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Tactical Overlay',
                          style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontWeight: FontWeight.w700,
                              fontSize: 26,
                              letterSpacing: -0.5,
                              color: C.primary)),
                      const Text('LIVE SYNC ACTIVE',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Color(0xFF666666))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                        color: C.surfaceLowest,
                        borderRadius: BorderRadius.circular(12)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          CustomPaint(
                              painter: _WarMapPainter(), size: Size.infinite),
                          // Map legend
                          Positioned(
                            bottom: 12,
                            left: 12,
                            right: 12,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _legendItem(Colors.red.shade700, 'Red Zone'),
                                  const SizedBox(width: 8),
                                  _legendItem(
                                      Colors.yellow.shade700, 'Yellow Zone'),
                                  const SizedBox(width: 8),
                                  _legendItem(Colors.green, 'Safe Corridors'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Protocol + Alerts side by side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _protocolCard()),
                      const SizedBox(width: 12),
                      Expanded(child: _sirenCard()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Threat Intel
                  _threatIntelCard(),
                  const SizedBox(height: 24),

                  // Survival Protocol
                  _survivalCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xCC0A0A0A),
          borderRadius: BorderRadius.circular(4),
          border: Border(left: BorderSide(color: color, width: 2)),
        ),
        child: Row(children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 6),
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Colors.white)),
        ]),
      );

  Widget _protocolCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: C.surfaceLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: C.outlineVar.withOpacity(0.1))),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PROTOCOL: CURFEW',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Color(0xFF666666))),
            SizedBox(height: 8),
            Text('20:00',
                style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                    letterSpacing: -2,
                    color: Colors.white,
                    height: 1)),
            Row(children: [
              Text('— ',
                  style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 18,
                      color: Color(0xFF666666))),
              Text('06:00',
                  style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 18,
                      color: Color(0xFF666666))),
            ]),
            SizedBox(height: 6),
            Text('All civilian movement prohibited.',
                style: TextStyle(
                    fontFamily: 'Inter', fontSize: 12, color: C.onSurfaceVar)),
          ],
        ),
      );

  Widget _sirenCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: C.surfaceLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: C.outlineVar.withOpacity(0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: C.outlineVar),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Row(children: [
                Icon(Icons.volume_up, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Siren Status',
                    style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.white)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    border: Border.all(color: C.outlineVar),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('STANDBY',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: Colors.white)),
              ),
            ]),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Row(children: [
                Icon(Icons.broadcast_on_home, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Comms Status',
                    style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.white)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: const Color(0x1A4CAF50),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('ENCRYPTED',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: Colors.greenAccent)),
              ),
            ]),
          ],
        ),
      );

  Widget _threatIntelCard() {
    final threats = [
      {
        'type': 'Airstrike',
        'level': 'CRITICAL',
        'time': '2 min ago',
        'color': C.error
      },
      {
        'type': 'Ground Forces',
        'level': 'HIGH',
        'time': '15 min ago',
        'color': Colors.orangeAccent
      },
      {
        'type': 'IED Activity',
        'level': 'MODERATE',
        'time': '1h ago',
        'color': Colors.yellowAccent
      },
    ];
    return Container(
      decoration: BoxDecoration(
          color: C.surfaceMid, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: SectionLabel('Threat Intelligence'),
          ),
          ...threats.map((t) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: C.outlineVar.withOpacity(0.2)))),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t['type'] as String,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: C.onSurface)),
                          Text(t['time'] as String,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: C.onSurfaceVar)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: (t['color'] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(t['level'] as String,
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: t['color'] as Color)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _survivalCard() {
    const steps = [
      'Stay below window level, away from glass',
      'Identify structural walls for cover',
      'Avoid metal objects and wiring',
      'Keep phone on silent — conserve battery',
      'Follow ECHO evacuation signal',
      'Do not use elevators during conflict',
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: C.surfaceMid, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Survival Protocol'),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: C.surfaceHigh,
                          borderRadius: BorderRadius.circular(4)),
                      child: Center(
                          child: Text('${e.key + 1}',
                              style: const TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: C.primary))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(e.value,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: C.onSurface,
                                height: 1.3))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _WarMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFF080808));
    final grid = Paint()
      ..color = const Color(0xFF151515)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    for (double y = 0; y < size.height; y += 30)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    // Red zones
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.35), 55,
        Paint()..color = const Color(0x40FF3B30));
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.6), 40,
        Paint()..color = const Color(0x25FF9500));
    // Safe corridor
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.72, size.width * 0.45, 18),
        Paint()..color = const Color(0x2034C759));
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.72, size.width * 0.45, 18),
        Paint()
          ..color = Colors.transparent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0x6034C759));
  }

  @override
  bool shouldRepaint(_) => false;
}
