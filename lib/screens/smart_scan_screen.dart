import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../theme/colors.dart';
import '../services/ml_object_detector.dart';
import '../services/ml_image_labeler.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// Full-screen camera view with live ML Kit object detection overlay.
/// Used from the SOS screen to scan the environment and auto-detect hazards.
class SmartScanScreen extends StatefulWidget {
  const SmartScanScreen({super.key});

  @override
  State<SmartScanScreen> createState() => _SmartScanScreenState();
}

class _SmartScanScreenState extends State<SmartScanScreen>
    with TickerProviderStateMixin {
  CameraController? _camCtrl;
  List<CameraDescription> _cameras = [];
  bool _isInitialised = false;
  bool _isScanning = false;
  String _statusText = 'INITIALISING CAMERA...';

  final MlObjectDetector _detector = MlObjectDetector();
  final MlImageLabeler _imageLabeler = MlImageLabeler();
  List<DetectedItem> _detections = [];
  final List<_ScanResult> _scanLog = [];
  int _frameCount = 0;

  late AnimationController _scanLineCtrl;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _statusText = 'NO CAMERA AVAILABLE');
        return;
      }
      // Prefer back camera
      final cam = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );
      _camCtrl = CameraController(cam, ResolutionPreset.medium,
          enableAudio: false, imageFormatGroup: ImageFormatGroup.nv21);
      await _camCtrl!.initialize();
      if (!mounted) return;
      setState(() {
        _isInitialised = true;
        _statusText = 'CAMERA READY — TAP SCAN TO BEGIN';
      });
    } catch (e) {
      setState(() => _statusText = 'CAMERA ERROR: ${e.toString().toUpperCase()}');
    }
  }

  void _startScanning() {
    if (_camCtrl == null || !_isInitialised || _isScanning) return;
    _detector.initialiseStream();
    setState(() {
      _isScanning = true;
      _statusText = 'SCANNING ENVIRONMENT...';
      _detections = [];
      _scanLog.clear();
      _frameCount = 0;
    });

    _camCtrl!.startImageStream((image) async {
      _frameCount++;
      // Process every 3rd frame to save resources
      if (_frameCount % 3 != 0) return;

      final cam = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );
      final items =
          await _detector.processLiveFrame(image, cam, cam.sensorOrientation);

      if (!mounted) return;
      if (items.isNotEmpty) {
        setState(() {
          _detections = items;
          _statusText =
              '${items.length} OBJECT${items.length > 1 ? "S" : ""} DETECTED';
        });
        // Log unique detections
        for (final item in items) {
          final tag = item.topLabel?.emergencyTag ?? 'Unknown';
          final conf = item.topLabel?.confidence ?? 0;
          final exists = _scanLog.any(
              (r) => r.tag == tag && (r.confidence - conf).abs() < 0.1);
          if (!exists) {
            _scanLog.add(_ScanResult(
              tag: tag,
              mlLabel: item.topLabel?.text ?? 'Unknown',
              confidence: conf,
              time: DateTime.now(),
            ));
          }
        }
      }
    });
  }

  Future<void> _stopScanning() async {
    if (_camCtrl == null || !_isScanning) return;
    await _camCtrl!.stopImageStream();
    setState(() {
      _isScanning = false;
      _statusText = 'SCAN COMPLETE — ${_scanLog.length} ITEMS LOGGED';
    });
  }

  Future<void> _captureAndAnalyse() async {
    if (_camCtrl == null || !_isInitialised) return;
    if (_isScanning) await _stopScanning();

    setState(() => _statusText = 'CAPTURING IMAGE...');
    try {
      final file = await _camCtrl!.takePicture();
      _detector.initialiseSingleImage();
      
      // Run both Object Detection and Image Labeling in parallel (Both on-device/free)
      final results = await Future.wait([
        _detector.processImageFile(file.path),
        _imageLabeler.processImageFile(file.path),
      ]);
      
      final items = results[0] as List<DetectedItem>;
      final labels = results[1] as List<ImageLabel>;

      if (!mounted) return;
      setState(() {
        _detections = items;
        _statusText =
            'ANALYSIS: ${items.length} OBJECTS, ${labels.length} CONTEXT LABELS';
      });

      // Log detected objects
      for (final item in items) {
        final tag = item.topLabel?.emergencyTag ?? 'Unknown';
        final conf = item.topLabel?.confidence ?? 0;
        _scanLog.add(_ScanResult(
          tag: tag,
          mlLabel: item.topLabel?.text ?? 'Unknown',
          confidence: conf,
          time: DateTime.now(),
        ));
      }

      // Log environment labels (context)
      for (final label in labels) {
        _scanLog.add(_ScanResult(
          tag: 'Environment / Context',
          mlLabel: label.label,
          confidence: label.confidence,
          time: DateTime.now(),
        ));
      }
    } catch (e) {
      setState(() => _statusText = 'CAPTURE FAILED: $e');
    }
  }

  void _returnResults() {
    Navigator.of(context).pop(ScanResults(
      detections: List.unmodifiable(_detections),
      log: List.unmodifiable(_scanLog.map((r) => r.summary)),
      summary: _buildSummary(),
    ));
  }

  String _buildSummary() {
    if (_scanLog.isEmpty) return 'No objects detected during scan.';
    final tags = _scanLog.map((r) => r.tag).toSet();
    return 'Detected: ${tags.join(', ')}. '
        '${_scanLog.length} total detection(s) logged.';
  }

  @override
  void dispose() {
    _camCtrl?.dispose();
    _detector.dispose();
    _imageLabeler.dispose();
    _scanLineCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          if (_isInitialised && _camCtrl != null)
            Positioned.fill(
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _camCtrl!.value.previewSize?.height ?? 1,
                    height: _camCtrl!.value.previewSize?.width ?? 1,
                    child: CameraPreview(_camCtrl!),
                  ),
                ),
              ),
            )
          else
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(color: C.primary),
              ),
            ),

          // Detection bounding boxes overlay
          if (_detections.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: _BoundingBoxPainter(
                  detections: _detections,
                  previewSize: _camCtrl?.value.previewSize,
                ),
              ),
            ),

          // Scan line animation
          if (_isScanning)
            AnimatedBuilder(
              animation: _scanLineCtrl,
              builder: (_, __) {
                final h = MediaQuery.of(context).size.height;
                return Positioned(
                  top: _scanLineCtrl.value * h,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFF00E5FF).withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          // Corner brackets overlay
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _CornerBracketPainter()),
            ),
          ),

          // Top status bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(null),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SMART SCAN',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'ML KIT OBJECT DETECTION',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: Color(0xFF00E5FF),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, __) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _isScanning
                                ? Colors.red.withOpacity(
                                    0.15 + _pulseCtrl.value * 0.15)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isScanning
                                  ? Colors.red.withOpacity(0.4)
                                  : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isScanning
                                      ? Colors.red
                                      : const Color(0xFF00E5FF),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isScanning ? 'LIVE' : 'READY',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  color: Colors.white,
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
            ),
          ),

          // Bottom control panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.terminal,
                                color: Color(0xFF00E5FF), size: 14),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _statusText,
                                style: const TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  color: Color(0xFF00E5FF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Detection log
                      if (_scanLog.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxHeight: 120),
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFF00E5FF).withOpacity(0.15)),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _scanLog.length,
                            itemBuilder: (_, i) {
                              final r = _scanLog[_scanLog.length - 1 - i];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _confColor(r.confidence),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        r.tag,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${(r.confidence * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontFamily: 'SpaceGrotesk',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _confColor(r.confidence),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      // Action buttons
                      Row(
                        children: [
                          // Capture photo
                          Expanded(
                            child: GestureDetector(
                              onTap: _isInitialised ? _captureAndAnalyse : null,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: C.surfaceHigh,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(Icons.camera_alt_rounded,
                                        color: Colors.white, size: 24),
                                    SizedBox(height: 4),
                                    Text(
                                      'CAPTURE',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Start / Stop scan
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: _isInitialised
                                  ? (_isScanning
                                      ? _stopScanning
                                      : _startScanning)
                                  : null,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: _isScanning
                                      ? Colors.red.withOpacity(0.7)
                                      : const Color(0xFF00E5FF),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isScanning
                                              ? Colors.red
                                              : const Color(0xFF00E5FF))
                                          .withOpacity(0.3),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isScanning
                                          ? Icons.stop_rounded
                                          : Icons.radar_rounded,
                                      color: _isScanning
                                          ? Colors.white
                                          : Colors.black,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isScanning ? 'STOP SCAN' : 'START SCAN',
                                      style: TextStyle(
                                        fontFamily: 'SpaceGrotesk',
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        letterSpacing: 1,
                                        color: _isScanning
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Confirm / Send results back
                          Expanded(
                            child: GestureDetector(
                              onTap: _scanLog.isNotEmpty ? _returnResults : null,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: _scanLog.isNotEmpty
                                      ? C.green.withOpacity(0.8)
                                      : C.surfaceHigh,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.check_rounded,
                                        color: _scanLog.isNotEmpty
                                            ? Colors.white
                                            : Colors.white30,
                                        size: 24),
                                    const SizedBox(height: 4),
                                    Text(
                                      'CONFIRM',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                        color: _scanLog.isNotEmpty
                                            ? Colors.white
                                            : Colors.white30,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _confColor(double c) {
    if (c >= 0.7) return const Color(0xFF34C759);
    if (c >= 0.4) return const Color(0xFFFFD60A);
    return const Color(0xFFFF453A);
  }
}

/// Paints bounding boxes & labels for detected objects on the camera preview.
class _BoundingBoxPainter extends CustomPainter {
  final List<DetectedItem> detections;
  final Size? previewSize;

  _BoundingBoxPainter({required this.detections, this.previewSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (previewSize == null) return;

    final scaleX = size.width / previewSize!.height;
    final scaleY = size.height / previewSize!.width;

    final boxPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.08);

    for (final det in detections) {
      final rect = Rect.fromLTRB(
        det.boundingBox.left * scaleX,
        det.boundingBox.top * scaleY,
        det.boundingBox.right * scaleX,
        det.boundingBox.bottom * scaleY,
      );

      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
      canvas.drawRRect(rrect, boxPaint);
      canvas.drawRRect(rrect, fillPaint);

      // Draw label
      final label = det.topLabel;
      if (label != null) {
        final textPainter = TextPainter(
          text: TextSpan(
            text:
                '${label.emergencyTag}  ${(label.confidence * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final bgRect = Rect.fromLTWH(
          rect.left,
          rect.top - 20,
          textPainter.width + 12,
          18,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
          Paint()..color = const Color(0xDD00E5FF),
        );
        textPainter.paint(canvas, Offset(rect.left + 6, rect.top - 18));
      }

      // Tracking ID
      if (det.trackingId != null) {
        final idPainter = TextPainter(
          text: TextSpan(
            text: '#${det.trackingId}',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        idPainter.paint(canvas, Offset(rect.right - idPainter.width - 4, rect.bottom + 4));
      }
    }
  }

  @override
  bool shouldRepaint(_BoundingBoxPainter old) => true;
}

/// Draws tactical corner brackets on the scan view.
class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const len = 30.0;
    const margin = 40.0;

    // Top-left
    canvas.drawLine(
        const Offset(margin, margin), const Offset(margin + len, margin), p);
    canvas.drawLine(
        const Offset(margin, margin), const Offset(margin, margin + len), p);

    // Top-right
    canvas.drawLine(Offset(size.width - margin, margin),
        Offset(size.width - margin - len, margin), p);
    canvas.drawLine(Offset(size.width - margin, margin),
        Offset(size.width - margin, margin + len), p);

    // Bottom-left
    canvas.drawLine(Offset(margin, size.height - margin),
        Offset(margin + len, size.height - margin), p);
    canvas.drawLine(Offset(margin, size.height - margin),
        Offset(margin, size.height - margin - len), p);

    // Bottom-right
    canvas.drawLine(Offset(size.width - margin, size.height - margin),
        Offset(size.width - margin - len, size.height - margin), p);
    canvas.drawLine(Offset(size.width - margin, size.height - margin),
        Offset(size.width - margin, size.height - margin - len), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

/// Results passed back to the SOS screen.
class ScanResults {
  final List<DetectedItem> detections;
  final List<String> log;
  final String summary;
  const ScanResults({
    required this.detections,
    required this.log,
    required this.summary,
  });
}

class _ScanResult {
  final String tag;
  final String mlLabel;
  final double confidence;
  final DateTime time;

  _ScanResult({
    required this.tag,
    required this.mlLabel,
    required this.confidence,
    required this.time,
  });

  String get summary =>
      '$tag (${(confidence * 100).toStringAsFixed(0)}% — $mlLabel)';
}
