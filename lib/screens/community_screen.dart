import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/shared.dart';
import '../widgets/app_drawer.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: C.bg,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          ResQAppBar(
            title: 'ECHO',
            onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            actions: const [
              Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.sensors, color: C.onSurfaceVar))
            ],
          ),
          const NewsTicker(
            text:
                'COMMUNITY ALERT: SECTOR 7 POWER GRID OFFLINE  //  VOLUNTEER DISPATCH ACTIVE IN NORTH QUADRANT  //  CLOUD COVER 85%  //  BANDWIDTH RESTRICTED',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero
                  const Text('Peer\nPortal',
                      style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w900,
                          fontSize: 52,
                          letterSpacing: -2,
                          height: 0.95,
                          color: C.primary)),
                  const SizedBox(height: 16),
                  const Text(
                      'Direct assistance synchronization for localized crises. Verified node communication only.',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: C.onSurfaceVar,
                          height: 1.5,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 32),

                  // I Need Help
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/sos'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      decoration: BoxDecoration(
                          color: C.primary,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Column(
                        children: [
                          Icon(Icons.emergency, color: C.onPrimary, size: 40),
                          SizedBox(height: 12),
                          Text('I Need Help',
                              style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                  letterSpacing: 3,
                                  color: C.onPrimary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // I Can Help
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      decoration: BoxDecoration(
                          color: C.surfaceHigh,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Column(
                        children: [
                          Icon(Icons.volunteer_activism,
                              color: C.onSurface, size: 40),
                          SizedBox(height: 12),
                          Text('I Can Help',
                              style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                  letterSpacing: 3,
                                  color: C.onSurface)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Nearby Requests
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('NEARBY REQUESTS',
                          style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3.5,
                              color: C.outline)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: C.surfaceHighest,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('LIVE: 08',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _requestCard('0.4 KM AWAY • 12M AGO', 'Medical Supplies',
                      'Requires insulin (Type 1) and sterile gauze. Sector 4 - Residential Block 12.',
                      urgent: true),
                  const SizedBox(height: 20),
                  _requestCard('1.2 KM AWAY • 45M AGO', 'Potable Water',
                      '5 Gallon emergency reserve needed for elderly resident center. No filtration available.'),
                  const SizedBox(height: 20),
                  _requestCard('2.8 KM AWAY • 1H AGO', 'Heavy Lifting',
                      'Debris clearing required at main entrance of Community Shelter A. 2+ volunteers.'),
                  const SizedBox(height: 32),

                  // Map section
                  const SectionLabel('TACTICAL MAP INSIGHT'),
                  const SizedBox(height: 12),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                        color: C.surfaceMid,
                        borderRadius: BorderRadius.circular(12)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          CustomPaint(
                              painter: _CommunityMap(), size: Size.infinite),
                          Container(color: const Color(0x66000000)),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                      color: const Color(0xCC0A0A0A),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: const Text('TAP TO VIEW FULL MAP',
                                      style: TextStyle(
                                          fontFamily: 'SpaceGrotesk',
                                          fontSize: 11,
                                          letterSpacing: 2,
                                          color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestCard(String meta, String title, String desc,
      {bool urgent = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: C.surfaceLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(meta,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                      color: C.outline)),
              if (urgent)
                PulseDot(color: C.error, size: 8)
              else
                const SizedBox(
                    width: 8,
                    height: 8,
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: C.surfaceBright))),
            ],
          ),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: -0.5,
                  color: C.primary)),
          const SizedBox(height: 8),
          Text(desc,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: C.onSurfaceVar,
                  height: 1.4)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: C.primary,
                foregroundColor: C.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('ACCEPT HELP',
                  style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityMap extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF181818)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += 30)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    // Markers
    final red = Paint()..color = const Color(0x33FF453A);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), 20, red);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.6), 15, red);
  }

  @override
  bool shouldRepaint(_) => false;
}
