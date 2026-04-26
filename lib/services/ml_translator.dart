import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// Wraps Google ML Kit On-Device Translation for the ECHO app.
/// Supports 50+ languages with dynamic model downloads (~30MB each).
/// Models are downloaded on-demand and cached on-device for offline use.
class MlTranslatorService {
  OnDeviceTranslator? _translator;
  TranslateLanguage _sourceLanguage = TranslateLanguage.english;
  TranslateLanguage _targetLanguage = TranslateLanguage.spanish;
  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  TranslateLanguage get sourceLanguage => _sourceLanguage;
  TranslateLanguage get targetLanguage => _targetLanguage;

  /// All supported languages with human-readable names.
  static final List<LanguageEntry> supportedLanguages = [
    const LanguageEntry(TranslateLanguage.afrikaans, 'Afrikaans', '🇿🇦'),
    const LanguageEntry(TranslateLanguage.arabic, 'Arabic', '🇸🇦'),
    const LanguageEntry(TranslateLanguage.belarusian, 'Belarusian', '🇧🇾'),
    const LanguageEntry(TranslateLanguage.bulgarian, 'Bulgarian', '🇧🇬'),
    const LanguageEntry(TranslateLanguage.bengali, 'Bengali', '🇧🇩'),
    const LanguageEntry(TranslateLanguage.catalan, 'Catalan', '🏴'),
    const LanguageEntry(TranslateLanguage.chinese, 'Chinese', '🇨🇳'),
    const LanguageEntry(TranslateLanguage.croatian, 'Croatian', '🇭🇷'),
    const LanguageEntry(TranslateLanguage.czech, 'Czech', '🇨🇿'),
    const LanguageEntry(TranslateLanguage.danish, 'Danish', '🇩🇰'),
    const LanguageEntry(TranslateLanguage.dutch, 'Dutch', '🇳🇱'),
    const LanguageEntry(TranslateLanguage.english, 'English', '🇬🇧'),
    const LanguageEntry(TranslateLanguage.esperanto, 'Esperanto', '🌍'),
    const LanguageEntry(TranslateLanguage.estonian, 'Estonian', '🇪🇪'),
    const LanguageEntry(TranslateLanguage.finnish, 'Finnish', '🇫🇮'),
    const LanguageEntry(TranslateLanguage.french, 'French', '🇫🇷'),
    const LanguageEntry(TranslateLanguage.galician, 'Galician', '🏴'),
    const LanguageEntry(TranslateLanguage.georgian, 'Georgian', '🇬🇪'),
    const LanguageEntry(TranslateLanguage.german, 'German', '🇩🇪'),
    const LanguageEntry(TranslateLanguage.greek, 'Greek', '🇬🇷'),
    const LanguageEntry(TranslateLanguage.gujarati, 'Gujarati', '🇮🇳'),
    const LanguageEntry(TranslateLanguage.hebrew, 'Hebrew', '🇮🇱'),
    const LanguageEntry(TranslateLanguage.hindi, 'Hindi', '🇮🇳'),
    const LanguageEntry(TranslateLanguage.hungarian, 'Hungarian', '🇭🇺'),
    const LanguageEntry(TranslateLanguage.icelandic, 'Icelandic', '🇮🇸'),
    const LanguageEntry(TranslateLanguage.indonesian, 'Indonesian', '🇮🇩'),
    const LanguageEntry(TranslateLanguage.irish, 'Irish', '🇮🇪'),
    const LanguageEntry(TranslateLanguage.italian, 'Italian', '🇮🇹'),
    const LanguageEntry(TranslateLanguage.japanese, 'Japanese', '🇯🇵'),
    const LanguageEntry(TranslateLanguage.kannada, 'Kannada', '🇮🇳'),
    const LanguageEntry(TranslateLanguage.korean, 'Korean', '🇰🇷'),
    const LanguageEntry(TranslateLanguage.latvian, 'Latvian', '🇱🇻'),
    const LanguageEntry(TranslateLanguage.lithuanian, 'Lithuanian', '🇱🇹'),
    const LanguageEntry(TranslateLanguage.macedonian, 'Macedonian', '🇲🇰'),
    const LanguageEntry(TranslateLanguage.malay, 'Malay', '🇲🇾'),
    const LanguageEntry(TranslateLanguage.marathi, 'Marathi', '🇮🇳'),
    const LanguageEntry(TranslateLanguage.norwegian, 'Norwegian', '🇳🇴'),
    const LanguageEntry(TranslateLanguage.persian, 'Persian', '🇮🇷'),
    const LanguageEntry(TranslateLanguage.polish, 'Polish', '🇵🇱'),
    const LanguageEntry(TranslateLanguage.portuguese, 'Portuguese', '🇵🇹'),
    const LanguageEntry(TranslateLanguage.romanian, 'Romanian', '🇷🇴'),
    const LanguageEntry(TranslateLanguage.russian, 'Russian', '🇷🇺'),
    const LanguageEntry(TranslateLanguage.slovak, 'Slovak', '🇸🇰'),
    const LanguageEntry(TranslateLanguage.slovenian, 'Slovenian', '🇸🇮'),
    const LanguageEntry(TranslateLanguage.spanish, 'Spanish', '🇪🇸'),
    const LanguageEntry(TranslateLanguage.swahili, 'Swahili', '🇰🇪'),
    const LanguageEntry(TranslateLanguage.swedish, 'Swedish', '🇸🇪'),
    const LanguageEntry(TranslateLanguage.tamil, 'Tamil', '🇮🇳'),
    const LanguageEntry(TranslateLanguage.telugu, 'Telugu', '🇮🇳'),
    const LanguageEntry(TranslateLanguage.thai, 'Thai', '🇹🇭'),
    const LanguageEntry(TranslateLanguage.turkish, 'Turkish', '🇹🇷'),
    const LanguageEntry(TranslateLanguage.ukrainian, 'Ukrainian', '🇺🇦'),
    const LanguageEntry(TranslateLanguage.urdu, 'Urdu', '🇵🇰'),
    const LanguageEntry(TranslateLanguage.vietnamese, 'Vietnamese', '🇻🇳'),
    const LanguageEntry(TranslateLanguage.welsh, 'Welsh', '🏴'),
  ];

  /// Set the source and target languages and re-create the translator.
  void configure(TranslateLanguage source, TranslateLanguage target) {
    _sourceLanguage = source;
    _targetLanguage = target;
    _translator?.close();
    _translator = OnDeviceTranslator(
      sourceLanguage: _sourceLanguage,
      targetLanguage: _targetLanguage,
    );
  }

  /// Check if the required models are downloaded.
  Future<bool> isModelDownloaded(TranslateLanguage lang) async {
    return await _modelManager.isModelDownloaded(lang.bcpCode);
  }

  /// Download a language model.
  Future<bool> downloadModel(TranslateLanguage lang) async {
    return await _modelManager.downloadModel(lang.bcpCode);
  }

  /// Delete a language model from device.
  Future<bool> deleteModel(TranslateLanguage lang) async {
    return await _modelManager.deleteModel(lang.bcpCode);
  }

  /// Translate the given [text].
  /// Make sure models are downloaded before calling this.
  Future<String> translate(String text) async {
    if (_translator == null) {
      configure(_sourceLanguage, _targetLanguage);
    }
    return await _translator!.translateText(text);
  }

  /// Release resources.
  void dispose() {
    _translator?.close();
    _translator = null;
  }
}

/// A language with its ML Kit enum, display name, and flag emoji.
class LanguageEntry {
  final TranslateLanguage language;
  final String name;
  final String flag;
  const LanguageEntry(this.language, this.name, this.flag);
}
