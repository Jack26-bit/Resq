import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

/// Wraps Google ML Kit Object Detection for the SOS feature.
/// Detects objects from camera frames, classifies them into broad
/// categories (fashion goods, food, home goods, places, plants),
/// and maps them to emergency-relevant descriptors.
class MlObjectDetector {
  ObjectDetector? _detector;
  bool _isBusy = false;

  /// Initialise the detector in STREAM_MODE for live camera feed.
  void initialiseStream() {
    final options = ObjectDetectorOptions(
      mode: DetectionMode.stream,
      classifyObjects: true,
      multipleObjects: true,
    );
    _detector = ObjectDetector(options: options);
  }

  /// Initialise the detector in SINGLE_IMAGE_MODE for a captured photo.
  void initialiseSingleImage() {
    final options = ObjectDetectorOptions(
      mode: DetectionMode.single,
      classifyObjects: true,
      multipleObjects: true,
    );
    _detector = ObjectDetector(options: options);
  }

  /// Process a [CameraImage] from the live camera feed.
  /// Returns a list of [DetectedItem]s (empty if busy or no detections).
  Future<List<DetectedItem>> processLiveFrame(
    CameraImage image,
    CameraDescription camera,
    int sensorOrientation,
  ) async {
    if (_isBusy || _detector == null) return [];
    _isBusy = true;

    try {
      final inputImage = _buildInputImage(image, camera, sensorOrientation);
      if (inputImage == null) {
        _isBusy = false;
        return [];
      }
      final objects = await _detector!.processImage(inputImage);
      _isBusy = false;
      return _mapDetections(objects);
    } catch (_) {
      _isBusy = false;
      return [];
    }
  }

  /// Process a file path (e.g. a captured photo).
  Future<List<DetectedItem>> processImageFile(String filePath) async {
    if (_detector == null) return [];
    final inputImage = InputImage.fromFilePath(filePath);
    final objects = await _detector!.processImage(inputImage);
    return _mapDetections(objects);
  }

  /// Build [InputImage] from the camera frame.
  InputImage? _buildInputImage(
    CameraImage image,
    CameraDescription camera,
    int sensorOrientation,
  ) {
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    // Determine rotation based on sensor orientation
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    if (rotation == null) return null;

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  /// Map ML Kit [DetectedObject]s to our [DetectedItem] model.
  List<DetectedItem> _mapDetections(List<DetectedObject> objects) {
    return objects.map((obj) {
      final labels = obj.labels.map((l) {
        return DetectedLabel(
          text: l.text,
          confidence: l.confidence,
          index: l.index,
          emergencyTag: _toEmergencyTag(l.text),
        );
      }).toList();

      return DetectedItem(
        trackingId: obj.trackingId,
        boundingBox: Rect.fromLTRB(
          obj.boundingBox.left.toDouble(),
          obj.boundingBox.top.toDouble(),
          obj.boundingBox.right.toDouble(),
          obj.boundingBox.bottom.toDouble(),
        ),
        labels: labels,
      );
    }).toList();
  }

  /// Map ML Kit coarse categories to emergency-relevant tags.
  String _toEmergencyTag(String mlLabel) {
    switch (mlLabel.toLowerCase()) {
      case 'fashion goods':
        return 'Person / Clothing Detected';
      case 'food':
        return 'Supplies / Food Detected';
      case 'home goods':
        return 'Structural / Debris Detected';
      case 'place':
      case 'places':
        return 'Location / Structure Detected';
      case 'plant':
      case 'plants':
        return 'Vegetation / Environment';
      default:
        return 'Object Detected';
    }
  }

  /// Release resources.
  Future<void> dispose() async {
    await _detector?.close();
    _detector = null;
  }
}

/// A detected item from ML Kit mapped for SOS usage.
class DetectedItem {
  final int? trackingId;
  final Rect boundingBox;
  final List<DetectedLabel> labels;

  const DetectedItem({
    this.trackingId,
    required this.boundingBox,
    required this.labels,
  });

  /// Best label by confidence, or null.
  DetectedLabel? get topLabel =>
      labels.isEmpty ? null : (labels..sort((a, b) => b.confidence.compareTo(a.confidence))).first;
}

/// A single label on a detected object.
class DetectedLabel {
  final String text;
  final double confidence;
  final int index;
  final String emergencyTag;

  const DetectedLabel({
    required this.text,
    required this.confidence,
    required this.index,
    required this.emergencyTag,
  });
}
