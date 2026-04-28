import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    // The system instructions force the model to behave as ECHO AI, tailored for disaster response.
    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none), // Important for disaster/survival advice
    ];

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      safetySettings: safetySettings,
      systemInstruction: Content.system(
        'You are ECHO AI, an advanced, tactical disaster response assistant. '
        'Your purpose is to provide life-saving advice, survival strategies, first aid protocols, '
        'and emergency guidance. Keep your responses highly concise, tactical, and formatted with bullet points. '
        'Never break character. Do not use markdown headers (#), just simple bolding and bullets.',
      ),
    );

    _chatSession = _model.startChat();
  }

  Future<String> sendMessage(String text) async {
    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      return response.text?.trim() ?? 'I was unable to process that request. Please rephrase your emergency.';
    } catch (e) {
      return 'NETWORK FAILURE. Unable to connect to ECHO AI core. Error: $e';
    }
  }

  Future<String> analyzeImage(Uint8List imageBytes, String mimeType) async {
    try {
      final prompt = TextPart('Analyze this image from a disaster/emergency perspective. Provide a brief tactical summary of what is visible, highlighting any hazards, resources, or critical situations.');
      final imagePart = DataPart(mimeType, imageBytes);
      final response = await _model.generateContent([
        Content.multi([prompt, imagePart])
      ]);
      return response.text?.trim() ?? 'Unable to analyze image.';
    } catch (e) {
      return 'AI ANALYSIS FAILED. Error: $e';
    }
  }
}
