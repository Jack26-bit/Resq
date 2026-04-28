import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// Wraps Google ML Kit On-Device Image Labeling.
/// This works on the Firebase Spark (Free) plan as it runs entirely on the phone.
/// It detects thousands of generic object categories to provide context.
class MlImageLabeler {
  ImageLabeler? _labeler;

  void initialise() {
    // Using default options for on-device labeling
    final options = ImageLabelerOptions(confidenceThreshold: 0.5);
    _labeler = ImageLabeler(options: options);
  }

  /// Processes an image file and returns descriptive labels.
  Future<List<ImageLabel>> processImageFile(String path) async {
    if (_labeler == null) initialise();
    final inputImage = InputImage.fromFilePath(path);
    return await _labeler!.processImage(inputImage);
  }

  void dispose() {
    _labeler?.close();
    _labeler = null;
  }
}
