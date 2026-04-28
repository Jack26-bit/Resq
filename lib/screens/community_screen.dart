import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/shared.dart';
import '../widgets/app_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<dynamic>> fetchCrisisNews() async {
    try {
      final apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
      final response = await http.get(Uri.parse(
          'https://newsapi.org/v2/everything?q=emergency+India&apiKey=$apiKey'));
      if (response.statusCode == 200) {
        return json.decode(response.body)['articles'] ?? [];
      }
    } catch (e) {
      debugPrint('Error fetching news: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: C.bg,
      drawer: const AppDrawer(),
      body: StreamBuilder<List<dynamic>>(
        stream: Stream.fromFuture(fetchCrisisNews()),
        builder: (context, snapshot) {
          final articles = snapshot.data ?? [];
          final itemCount = articles.length > 3 ? 3 : articles.length;

          return CustomScrollView(
            slivers: [
              // News ticker (shows only when data loaded and non-empty)
              if (snapshot.connectionState != ConnectionState.waiting &&
                  itemCount > 0)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Container(
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Color(0x1AFFFFFF))),
                          color: Color(0x66131313),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: const Icon(Icons.warning, color: C.error),
                          title: Text(
                            articles[index]['title'] ?? 'CRISIS ALERT',
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: C.onSurface),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            (articles[index]['source']?['name'] ?? 'SYS_LOG')
                                .toUpperCase(),
                            style: const TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: C.primary),
                          ),
                        ),
                      );
                    },
                    childCount: itemCount,
                  ),
                )
              else if (snapshot.connectionState == ConnectionState.waiting)
                const SliverToBoxAdapter(
                  child: LinearProgressIndicator(
                      color: C.primary, backgroundColor: C.surfaceMid),
                ),

              // Main scrollable content
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
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
                    const SizedBox(height: 16),

                    // AI Chat Bot
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/ai_help'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                        decoration: BoxDecoration(
                          color: C.surfaceLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: C.outlineVar.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: C.surfaceHigh,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.terminal, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('AI Chat Bot',
                                      style: TextStyle(
                                          fontFamily: 'SpaceGrotesk',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                          color: Colors.white)),
                                  SizedBox(height: 4),
                                  Text('Tactical INTEL & assistance module',
                                      style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          color: Color(0xFF888888))),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Color(0xFF666666)),
                          ],
                        ),
                      ),
                    ),
                    // BigQuery Export Test
                    const SectionLabel('BIGQUERY EXPORT TEST'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              try {
                                await FirebaseFirestore.instance.collection('posts').doc('bigquery-mirror-test').set({
                                  'timestamp': FieldValue.serverTimestamp(),
                                  'message': 'Testing BigQuery Export Extension from Echo App!',
                                  'user': 'test_user_123',
                                  'type': 'test_post'
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Created test post! Check BigQuery.', style: TextStyle(color: Colors.black)), backgroundColor: C.primary),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e'), backgroundColor: C.error),
                                  );
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: C.surfaceMid,
                              foregroundColor: C.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('CREATE DOC', style: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              try {
                                await FirebaseFirestore.instance.collection('posts').doc('bigquery-mirror-test').delete();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Deleted test post! Check BigQuery.', style: TextStyle(color: Colors.black)), backgroundColor: C.error),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e'), backgroundColor: C.error),
                                  );
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: C.surfaceMid,
                              foregroundColor: C.error,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('DELETE DOC', style: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
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
                                painter: _CommunityMap(),
                                size: Size.infinite),
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
                                        borderRadius:
                                            BorderRadius.circular(4)),
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
                  ]),
                ),
              ),
            ],
          );
        },
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
                const PulseDot(color: C.error, size: 8)
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
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    // Markers
    final red = Paint()..color = const Color(0x33FF453A);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), 20, red);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.6), 15, red);
  }

  @override
  bool shouldRepaint(_) => false;
}
