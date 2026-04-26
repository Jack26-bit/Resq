import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/shared.dart';
import '../widgets/app_drawer.dart';
import '../core/crypto/identity_manager.dart';
import '../data/local/message_store.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _desc = TextEditingController();
  String _selected = 'Medical';
  late AnimationController _pulse;

  final _types = ['Medical', 'Fire', 'Structural', 'Trapped'];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: C.bg,
      drawer: const AppDrawer(),
      body: Column(
        children: [

          const NewsTicker(
            text:
                'URGENT: SYSTEM OVERRIDE ACTIVE - EMERGENCY RESPONSE MODE ENABLED - COORDINATES LOCKING - PRIORITY 1 CONNECTION -',
            bg: C.errorContainer,
            fg: C.onErrorContainer,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
              child: Column(
                children: [
                  GestureDetector(
                    onDoubleTap: () async {
                      // We use doubleTap as Flutter doesn't have native tripleTap.
                      // Alternatively, implement a tap counter.
                      await _emergencyWipe();
                    },
                    child: const Text(
                      'Report SOS',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.w900,
                        fontSize: 48,
                        letterSpacing: -2,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Direct uplink to tactical command',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: C.onSurfaceVar,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _locationCard(),
                  const SizedBox(height: 20),
                  _descriptionField(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: _mediaBtn(Icons.photo_camera, 'Add Images')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _mediaBtn(Icons.videocam, 'Record Video')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _criticalitySection(),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: () => _showSent(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: C.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 50,
                          )
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Send SOS',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              color: C.onPrimary,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.send, color: C.onPrimary, size: 22),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'BY CLICKING SEND, YOUR DATA IS TRANSMITTED VIA SECURE TACTICAL UPLINK.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: C.outline,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationCard() {
    return Container(
      decoration: BoxDecoration(
        color: C.surfaceLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 3,
              decoration: const BoxDecoration(
                color: C.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'GEO-LOCATION ACTIVE',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                            color: C.outline,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: C.primary, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '34.0522 N, 118.2437 W',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, __) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: C.surfaceHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: C.error
                                    .withOpacity(0.4 + _pulse.value * 0.6),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'LIVE',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: C.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: C.surfaceHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      CustomPaint(painter: _MapGrid(), child: const Center()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _descriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'DESCRIBE YOUR SITUATION',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
              color: C.outline,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: C.surfaceLow,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(20),
          child: TextField(
            controller: _desc,
            maxLines: 5,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: C.onSurface,
            ),
            decoration: const InputDecoration(
              hintText:
                  'Medical emergency, structural collapse, or immediate threat...',
              hintStyle: TextStyle(color: C.outlineVar, fontSize: 15),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _criticalitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'CRITICALITY LEVEL',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
              color: C.outline,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _types.map((t) {
            final sel = _selected == t;
            return GestureDetector(
              onTap: () => setState(() => _selected = t),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? C.error : C.surfaceHigh,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: C.error.withOpacity(0.1),
                            blurRadius: 12,
                          )
                        ]
                      : null,
                ),
                child: Text(
                  t.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: sel ? C.onError : C.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _mediaBtn(IconData icon, String label) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: C.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 10),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: C.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSent(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: C.surfaceMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'SOS TRANSMITTED',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w900,
            color: C.primary,
          ),
        ),
        content: const Text(
          'Your emergency signal has been sent to tactical command. A response team is being dispatched to your location.',
          style: TextStyle(
            fontFamily: 'Inter',
            color: C.onSurfaceVar,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pop();
            },
            child: const Text(
              'ACKNOWLEDGE',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w700,
                color: C.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _emergencyWipe() async {
    // Perform emergency data wipe
    await IdentityManager().wipeData();
    MessageStore().wipeAllData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'EMERGENCY WIPE EXECUTED. ALL LOCAL DATA DESTROYED.',
          style: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}

class _MapGrid extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF222222)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      12,
      Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
