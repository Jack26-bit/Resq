import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  GoogleMapController? _mapController;
  final LatLng _center = const LatLng(13.115403, 77.63577); // NMIT Campus Center
  
  final List<Map<String, dynamic>> _manualMarkers = [];
  String? _currentAddMode;

  static const String _mapStyle = '''
[
  { "elementType": "geometry", "stylers": [{ "color": "#1a1a1a" }] },
  { "elementType": "labels.text.fill", "stylers": [{ "color": "#746855" }] },
  { "elementType": "labels.text.stroke", "stylers": [{ "color": "#242424" }] },
  { "featureType": "administrative", "elementType": "geometry", "stylers": [{ "color": "#757575" }] },
  { "featureType": "administrative.country", "elementType": "labels.text.fill", "stylers": [{ "color": "#9e9e9e" }] },
  { "featureType": "administrative.land_parcel", "stylers": [{ "visibility": "off" }] },
  { "featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [{ "color": "#bdbdbd" }] },
  { "featureType": "poi", "elementType": "labels.text.fill", "stylers": [{ "color": "#757575" }] },
  { "featureType": "poi.park", "elementType": "geometry", "stylers": [{ "color": "#181818" }] },
  { "featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [{ "color": "#616161" }] },
  { "featureType": "poi.park", "elementType": "labels.text.stroke", "stylers": [{ "color": "#1b1b1b" }] },
  { "featureType": "road", "elementType": "geometry.fill", "stylers": [{ "color": "#2c2c2c" }] },
  { "featureType": "road", "elementType": "labels.text.fill", "stylers": [{ "color": "#8a8a8a" }] },
  { "featureType": "road.arterial", "elementType": "geometry", "stylers": [{ "color": "#373737" }] },
  { "featureType": "road.highway", "elementType": "geometry", "stylers": [{ "color": "#3c3c3c" }] },
  { "featureType": "road.highway.controlled_access", "elementType": "geometry", "stylers": [{ "color": "#4e4e4e" }] },
  { "featureType": "road.local", "elementType": "labels.text.fill", "stylers": [{ "color": "#616161" }] },
  { "featureType": "transit", "elementType": "labels.text.fill", "stylers": [{ "color": "#757575" }] },
  { "featureType": "water", "elementType": "geometry", "stylers": [{ "color": "#000000" }] },
  { "featureType": "water", "elementType": "labels.text.fill", "stylers": [{ "color": "#3d3d3d" }] }
]
''';

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
                Positioned.fill(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('sos_reports').snapshots(),
                    builder: (context, snapshot) {
                      Set<Marker> firestoreMarkers = {};
                      if (snapshot.hasData) {
                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          if (data['location'] != null && data['location']['latitude'] != null && data['location']['longitude'] != null) {
                            final lat = (data['location']['latitude'] as num).toDouble();
                            final lng = (data['location']['longitude'] as num).toDouble();
                            firestoreMarkers.add(Marker(
                              markerId: MarkerId(doc.id),
                              position: LatLng(lat, lng),
                              infoWindow: InfoWindow(title: data['criticality']?.toString() ?? 'SOS'),
                              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                            ));
                          }
                        }
                      }
                      
                      final allMarkers = <Marker>{
                        ..._getMarkers(),
                        ...firestoreMarkers,
                      };

                      return GoogleMap(
                        initialCameraPosition: CameraPosition(target: _center, zoom: 18),
                        cameraTargetBounds: CameraTargetBounds(
                          LatLngBounds(
                            southwest: const LatLng(13.1100, 77.6300),
                            northeast: const LatLng(13.1200, 77.6400),
                          ),
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                          _mapController?.setMapStyle(_mapStyle);
                        },
                        onTap: (LatLng pos) {
                          if (_currentAddMode != null) {
                            setState(() {
                              _manualMarkers.add({
                                'id': 'MANUAL_${DateTime.now().millisecondsSinceEpoch}',
                                'pos': pos,
                                'type': _currentAddMode,
                                'color': _currentAddMode == 'MEDICAL' ? C.primary : Colors.greenAccent,
                                'label': 'Manual $_currentAddMode'
                              });
                              _currentAddMode = null; // Reset mode after adding
                            });
                          }
                        },
                        markers: allMarkers,
                        circles: {
                          Circle(
                            circleId: const CircleId('SOS_ZONE'),
                            center: _center,
                            radius: 100,
                            fillColor: const Color(0xFFFF0000).withValues(alpha: 0.1),
                            strokeColor: const Color(0xFFFF0000),
                            strokeWidth: 1,
                          ),
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                      );
                    }
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                      stops: const [0.0, 0.2, 0.8, 1.0],
                    ),
                  ),
                ),
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
                    _mapBtn(Icons.add, () => _mapController?.animateCamera(CameraUpdate.zoomIn()), null),
                    const SizedBox(height: 8),
                    _mapBtn(Icons.remove, () => _mapController?.animateCamera(CameraUpdate.zoomOut()), null),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _mapController?.animateCamera(CameraUpdate.newLatLng(_center)),
                      child: Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(color: C.primary, borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: const Icon(Icons.my_location, color: C.onPrimary, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _mapBtn(Icons.local_hospital, () => setState(() => _currentAddMode = 'MEDICAL'), _currentAddMode == 'MEDICAL'),
                    const SizedBox(height: 8),
                    _mapBtn(Icons.house, () => setState(() => _currentAddMode = 'SHELTER'), _currentAddMode == 'SHELTER'),
                  ]),
                ),

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

  Set<Marker> _getMarkers() {
    final campusPoints = [
      {'id': 'MEDIC_MAIN', 'pos': const LatLng(13.115527, 77.635774), 'type': 'MEDICAL', 'color': C.primary, 'label': 'Health Centre'},
      {'id': 'SHELTER_FOOD_COURT', 'pos': const LatLng(13.116362, 77.636407), 'type': 'SHELTER', 'color': Colors.greenAccent, 'label': 'Food Court (S1)'},
      {'id': 'SHELTER_BLOCK', 'pos': const LatLng(13.115635, 77.634511), 'type': 'SHELTER', 'color': Colors.greenAccent, 'label': 'C-Block (S2)'},
    ];

    final allPoints = [...campusPoints, ..._manualMarkers];

    return allPoints
        .where((m) => _filter == 'ALL' || m['type'] == _filter)
        .map((m) => Marker(
              markerId: MarkerId(m['id'] as String),
              position: m['pos'] as LatLng,
              infoWindow: InfoWindow(title: m['label'] as String?),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                _getHueForColor(m['color'] as Color),
              ),
            ))
        .toSet();
  }

  double _getHueForColor(Color color) {
    if (color == C.error) return BitmapDescriptor.hueRed;
    if (color == C.primary) return BitmapDescriptor.hueAzure;
    if (color == Colors.greenAccent) return BitmapDescriptor.hueGreen;
    return BitmapDescriptor.hueRed;
  }

  Widget _mapBtn(IconData icon, VoidCallback onTap, bool? isActive) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: (isActive ?? false) ? C.primary : const Color(0xCC2A2A2A), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: (isActive ?? false) ? C.onPrimary : Colors.white, size: 20),
        ),
      );

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
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridP);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridP);
    }
    // Thicker major grid
    final major = Paint()..color = const Color(0xFF202020)..strokeWidth = 1.5;
    for (double x = 0; x < size.width; x += 120) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), major);
    }
    for (double y = 0; y < size.height; y += 120) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), major);
    }
    // Red flood zone
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), 80,
        Paint()..color = const Color(0x1AFF453A));
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.6), 60,
        Paint()..color = const Color(0x0FFF453A));
  }
  @override
  bool shouldRepaint(_) => false;
}
