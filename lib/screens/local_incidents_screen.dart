import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/shared.dart';

class LocalIncidentsScreen extends StatelessWidget {
  const LocalIncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: Column(
        children: [
          const ResQAppBar(title: 'LOCAL INCIDENTS', showBack: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // System status
                  const Row(children: [
                    PulseDot(),
                    SizedBox(width: 8),
                    SectionLabel('System Status'),
                  ]),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: C.surfaceHigh, borderRadius: BorderRadius.circular(12)),
                    child: const Stack(
                      children: [
                        Positioned(top: -8, right: -8,
                          child: Opacity(opacity: 0.08, child: Icon(Icons.radar, size: 80, color: Colors.white))),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('LOCAL AREA MODE ACTIVE',
                                style: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w900, fontSize: 20, color: C.primary)),
                            SizedBox(height: 8),
                            Text('Community issues are being tracked and resolved. Stay updated and report problems nearby.',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: C.onSurfaceVar, height: 1.4)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Urgent notice
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: C.primary,
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(left: BorderSide(color: C.error, width: 4)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning, color: C.onPrimary, size: 22),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('URGENT NOTICE',
                                  style: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1, color: C.onPrimary)),
                              SizedBox(height: 4),
                              Text('Water supply interruption expected till evening. Residents advised to store water.',
                                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 15, color: C.onPrimary, height: 1.3)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Active Issues
                  const SectionLabel('Active Issues'),
                  const SizedBox(height: 12),
                  ..._issues(),
                  const SizedBox(height: 24),

                  // Community Action
                  const SectionLabel('Community Action'),
                  const SizedBox(height: 12),
                  _communityAction(),
                  const SizedBox(height: 24),

                  // Local services
                  const SectionLabel('Local Services'),
                  const SizedBox(height: 12),
                  ..._services(),
                  const SizedBox(height: 24),

                  // Report button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add_circle_outline, color: C.primary),
                      label: const Text('REPORT NEW ISSUE',
                          style: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 2, color: C.primary)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: const BorderSide(color: C.outlineVar),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  List<Widget> _issues() {
    final data = [
      {'title': 'Water Supply: Disrupted', 'desc': 'No water in Block A since morning', 'status': 'High'},
      {'title': 'Power Outage: Partial', 'desc': 'Streets 3–5 affected, restoration in progress', 'status': 'Ongoing'},
      {'title': 'Road Condition: Poor', 'desc': 'Potholes reported near Main Road', 'status': 'Log Only'},
      {'title': 'Garbage Collection: Delayed', 'desc': 'Waste not cleared in last 2 days', 'status': 'Queued'},
    ];
    return data.map((d) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: C.surfaceMid, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d['title'] as String, style: const TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700, fontSize: 14, color: C.primary)),
                  const SizedBox(height: 2),
                  Text(d['desc'] as String, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: C.onSurfaceVar)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: C.surfaceHighest, borderRadius: BorderRadius.circular(20)),
              child: Text((d['status'] as String).toUpperCase(),
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: C.onSurface)),
            ),
          ],
        ),
      ),
    )).toList();
  }

  Widget _communityAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: C.surfaceMid, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _actionItem(Icons.group, '24 Volunteers', 'mobilized')),
              const SizedBox(width: 12),
              Expanded(child: _actionItem(Icons.inventory, '87 Supply kits', 'distributed')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _actionItem(Icons.local_hospital, '3 Medical', 'posts active')),
              const SizedBox(width: 12),
              Expanded(child: _actionItem(Icons.home, '2 Shelters', 'open')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionItem(IconData icon, String val, String sub) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: C.surfaceHigh, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: C.primary, size: 20),
            const SizedBox(height: 6),
            Text(val, style: const TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700, fontSize: 13, color: C.primary)),
            Text(sub, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.onSurfaceVar)),
          ],
        ),
      );

  List<Widget> _services() {
    final data = [
      {'name': 'Emergency Shelter A', 'info': '120/200 capacity', 'status': 'OPEN', 'icon': Icons.home},
      {'name': 'Medical Station #3', 'info': '24/7 staff on duty', 'status': 'OPEN', 'icon': Icons.local_hospital},
      {'name': 'Food Distribution', 'info': 'Daily rations available', 'status': 'CLOSES 8PM', 'icon': Icons.restaurant},
    ];
    return data.map((d) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: C.surfaceHigh, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: C.surfaceHighest, borderRadius: BorderRadius.circular(8)),
              child: Icon(d['icon'] as IconData, color: C.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d['name'] as String, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14, color: C.onSurface)),
                  Text(d['info'] as String, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.onSurfaceVar)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(d['status'] as String,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.greenAccent)),
            ),
          ],
        ),
      ),
    )).toList();
  }
}
