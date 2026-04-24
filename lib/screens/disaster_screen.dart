import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/shared.dart';

class DisasterScreen extends StatefulWidget {
  const DisasterScreen({super.key});
  @override
  State<DisasterScreen> createState() => _DisasterScreenState();
}

class _DisasterScreenState extends State<DisasterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: Column(
        children: [
          ResQAppBar(
            title: 'DISASTER PROTOCOL',
            showBack: true,
            actions: [
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Text('ECHO',
                    style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: C.outlineVar)),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statusBanner(),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _liveConditions()),
                      const SizedBox(width: 12),
                      Expanded(child: _evacuationRoutes()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _resourceCard(),
                  const SizedBox(height: 24),
                  _emergencyContacts(),
                  const SizedBox(height: 24),
                  _aiInsights(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBanner() {
    return Container(
      decoration: BoxDecoration(
        color: C.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: C.primary, width: 4)),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 24)],
      ),
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Positioned(
              right: -10,
              top: -10,
              child: Opacity(
                  opacity: 0.07,
                  child: const Icon(Icons.warning,
                      size: 140, color: Colors.white))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.warning, color: C.primary, size: 18),
                const SizedBox(width: 8),
                const Text('SYSTEM STATUS',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.5,
                        color: C.onSurfaceVar)),
              ]),
              const SizedBox(height: 12),
              const Text(
                  'DISASTER MODE ACTIVE: Heavy rainfall expected within 24 hours.',
                  style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: C.primary,
                      height: 1.2,
                      letterSpacing: -0.5)),
              const SizedBox(height: 8),
              const Text(
                  'Flood risk rising in low-lying areas. Evacuation routes prepared. Stay alert for updates. All essential systems prioritized for survival.',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: C.onSurfaceVar,
                      height: 1.4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _liveConditions() {
    final items = [
      {
        'label': 'Flood Risk',
        'status': 'High',
        'statusColor': C.error,
        'icon': Icons.water_drop,
        'desc': 'Water levels rising near rivers'
      },
      {
        'label': 'Rainfall',
        'status': 'Increasing',
        'statusColor': C.primary,
        'icon': Icons.water,
        'desc': 'Heavy rain continues 24h'
      },
      {
        'label': 'Seismic',
        'status': 'Low',
        'statusColor': C.outlineVar,
        'icon': Icons.waves,
        'desc': 'No earthquake risk'
      },
      {
        'label': 'Landslide',
        'status': 'Moderate',
        'statusColor': Colors.orangeAccent,
        'icon': Icons.landscape,
        'desc': 'Hillside areas caution'
      },
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surfaceMid,
        borderRadius: BorderRadius.circular(12),
        border: const Border(top: BorderSide(color: C.outlineVar)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionLabel('Live Conditions'),
              AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => Row(children: [
                        Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white
                                    .withOpacity(0.5 + _pulse.value * 0.5))),
                        const SizedBox(width: 5),
                        const Text('LIVE',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                                color: Colors.white)),
                      ])),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: C.surfaceHigh,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Icon(item['icon'] as IconData,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(item['label'] as String,
                                style: const TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ]),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                                color: (item['statusColor'] as Color),
                                borderRadius: BorderRadius.circular(3)),
                            child: Text(
                                (item['status'] as String).toUpperCase(),
                                style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(item['desc'] as String,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: C.onSurfaceVar)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _evacuationRoutes() {
    final routes = [
      {
        'name': 'Route Alpha',
        'status': 'CLEAR',
        'dir': 'North on Hwy 1',
        'ok': true
      },
      {
        'name': 'Route Beta',
        'status': 'BLOCKED',
        'dir': 'West on Route 66',
        'ok': false
      },
      {
        'name': 'Route Gamma',
        'status': 'CLEAR',
        'dir': 'East via Bridge Rd',
        'ok': true
      },
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surfaceMid,
        borderRadius: BorderRadius.circular(12),
        border: const Border(top: BorderSide(color: C.outlineVar)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Evacuation Routes'),
          const SizedBox(height: 16),
          ...routes.map((r) {
            final ok = r['ok'] as bool;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: C.surfaceHigh,
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                      left: BorderSide(
                          color: ok ? Colors.greenAccent : C.error, width: 2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r['name'] as String,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: C.onSurface)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            color: (ok ? Colors.greenAccent : C.error)
                                .withOpacity(0.15),
                            child: Text(r['status'] as String,
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: ok ? Colors.greenAccent : C.error)),
                          ),
                        ]),
                    const SizedBox(height: 3),
                    Text(r['dir'] as String,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: C.onSurfaceVar)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _resourceCard() {
    final items = [
      {'label': 'Emergency Shelters', 'pct': 0.87, 'color': Colors.greenAccent},
      {'label': 'Medical Supplies', 'pct': 0.62, 'color': Colors.orangeAccent},
      {'label': 'Rescue Teams', 'pct': 0.94, 'color': Colors.greenAccent},
      {'label': 'Communication Grid', 'pct': 0.45, 'color': C.error},
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: C.surfaceMid, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Resource Allocation'),
          const SizedBox(height: 16),
          ...items.map((item) {
            final pct = item['pct'] as double;
            final color = item['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['label'] as String,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: C.onSurfaceVar)),
                        Text('${(pct * 100).toInt()}%',
                            style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: color)),
                      ]),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: C.surfaceHighest,
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 5),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _emergencyContacts() {
    final contacts = [
      {'name': 'Emergency Services', 'num': '911', 'icon': Icons.emergency},
      {
        'name': 'Disaster Hotline',
        'num': '1-800-FEMA',
        'icon': Icons.phone_in_talk
      },
      {'name': 'ECHO Command', 'num': 'ENCRYPTED', 'icon': Icons.lock},
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: C.surfaceMid, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Emergency Contacts'),
          const SizedBox(height: 16),
          ...contacts.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                      color: C.surfaceHigh,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(c['icon'] as IconData, color: C.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(c['name'] as String,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: C.onSurface))),
                      Text(c['num'] as String,
                          style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: C.primary)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _aiInsights() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.surfaceMid,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: C.primary, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.psychology, color: C.primary, size: 18),
            const SizedBox(width: 8),
            const Text('AI ASSESSMENT',
                style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    color: C.primary)),
          ]),
          const SizedBox(height: 12),
          const Text(
              'Based on current flood trajectory and rainfall data, Sector 4-B faces highest risk. Recommend immediate evacuation of Zone C within 4 hours. Medical resources being rerouted.',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: C.onSurfaceVar,
                  height: 1.5)),
          const SizedBox(height: 12),
          Row(children: [
            PulseDot(color: C.primary),
            const SizedBox(width: 8),
            const Text('CONFIDENCE: 94.2%',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: C.onSurface)),
          ]),
        ],
      ),
    );
  }
}
