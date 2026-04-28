import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../widgets/shared.dart';
import '../services/ml_translator.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});
  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen>
    with TickerProviderStateMixin {
  final _inputCtrl = TextEditingController();
  final _service = MlTranslatorService();
  String _translatedText = '';
  bool _isTranslating = false;
  bool _isDownloading = false;
  String _statusText = 'READY — SELECT LANGUAGES & TYPE';
  bool _sourceReady = false;
  bool _targetReady = false;

  late LanguageEntry _sourceLang;
  late LanguageEntry _targetLang;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _sourceLang = MlTranslatorService.supportedLanguages
        .firstWhere((l) => l.language == TranslateLanguage.english);
    _targetLang = MlTranslatorService.supportedLanguages
        .firstWhere((l) => l.language == TranslateLanguage.spanish);
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _service.configure(_sourceLang.language, _targetLang.language);
    _checkModels();
  }

  Future<void> _checkModels() async {
    _sourceReady = await _service.isModelDownloaded(_sourceLang.language);
    _targetReady = await _service.isModelDownloaded(_targetLang.language);
    if (mounted) {
      setState(() {
        if (_sourceReady && _targetReady) {
          _statusText = 'MODELS READY — START TRANSLATING';
        } else {
          _statusText = 'MODELS NEEDED — TAP DOWNLOAD';
        }
      });
    }
  }

  Future<void> _downloadModels() async {
    setState(() {
      _isDownloading = true;
      _statusText = 'DOWNLOADING LANGUAGE MODELS...';
    });
    try {
      if (!_sourceReady) {
        await _service.downloadModel(_sourceLang.language);
      }
      if (!_targetReady) {
        await _service.downloadModel(_targetLang.language);
      }
      _sourceReady = true;
      _targetReady = true;
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _statusText = 'MODELS READY — START TRANSLATING';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _statusText = 'DOWNLOAD FAILED — RETRY';
        });
      }
    }
  }

  Future<void> _translate() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    if (!_sourceReady || !_targetReady) {
      await _downloadModels();
      if (!_sourceReady || !_targetReady) return;
    }
    setState(() {
      _isTranslating = true;
      _statusText = 'TRANSLATING...';
    });
    try {
      final result = await _service.translate(text);
      if (mounted) {
        setState(() {
          _translatedText = result;
          _isTranslating = false;
          _statusText = 'TRANSLATION COMPLETE';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
          _statusText = 'TRANSLATION ERROR';
          _translatedText = 'Error: ${e.toString()}';
        });
      }
    }
  }

  void _swapLanguages() {
    setState(() {
      final tmp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = tmp;
      final tmpR = _sourceReady;
      _sourceReady = _targetReady;
      _targetReady = tmpR;
      // Swap text
      if (_translatedText.isNotEmpty) {
        _inputCtrl.text = _translatedText;
        _translatedText = '';
      }
    });
    _service.configure(_sourceLang.language, _targetLang.language);
  }

  void _pickLanguage(bool isSource) async {
    final result = await showModalBottomSheet<LanguageEntry>(
      context: context,
      backgroundColor: C.surfaceLow,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _LanguagePicker(
        current: isSource ? _sourceLang : _targetLang,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        if (isSource) {
          _sourceLang = result;
          _sourceReady = false;
        } else {
          _targetLang = result;
          _targetReady = false;
        }
        _translatedText = '';
      });
      _service.configure(_sourceLang.language, _targetLang.language);
      _checkModels();
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _service.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: const ResQAppBar(title: 'Translate', showBack: true),
      body: Column(
        children: [
          const NewsTicker(
            text: 'ML KIT ON-DEVICE TRANSLATION — 55+ LANGUAGES — OFFLINE CAPABLE — SECURE LOCAL PROCESSING —',
            bg: Color(0xFF1A1A2E),
            fg: Color(0xFF7B61FF),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                children: [
                  // Language selector row
                  _languageRow(),
                  const SizedBox(height: 20),
                  // Input card
                  _inputCard(),
                  const SizedBox(height: 16),
                  // Translate button
                  _translateButton(),
                  const SizedBox(height: 16),
                  // Status bar
                  _statusBar(),
                  const SizedBox(height: 16),
                  // Output card
                  if (_translatedText.isNotEmpty) _outputCard(),
                  const SizedBox(height: 16),
                  // Model management
                  _modelInfoCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageRow() {
    return Row(
      children: [
        Expanded(child: _langChip(_sourceLang, true)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: _swapLanguages,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF7B61FF).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF7B61FF).withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.swap_horiz_rounded,
                  color: Color(0xFF7B61FF), size: 22),
            ),
          ),
        ),
        Expanded(child: _langChip(_targetLang, false)),
      ],
    );
  }

  Widget _langChip(LanguageEntry lang, bool isSource) {
    return GestureDetector(
      onTap: () => _pickLanguage(isSource),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: C.surfaceLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF7B61FF).withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Text(lang.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSource ? 'FROM' : 'TO',
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 8, fontWeight: FontWeight.w800,
                      letterSpacing: 2, color: Color(0xFF7B61FF),
                    ),
                  ),
                  Text(
                    lang.name.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700,
                      fontSize: 13, color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.unfold_more, color: C.outline, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _inputCard() {
    return Container(
      decoration: BoxDecoration(
        color: C.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7B61FF).withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Text('${_sourceLang.flag}  ${_sourceLang.name.toUpperCase()}',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 10,
                      fontWeight: FontWeight.w700, letterSpacing: 1.5, color: C.outline)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _inputCtrl.clear(),
                  child: const Icon(Icons.close, color: C.outline, size: 16),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _inputCtrl,
              maxLines: 5,
              minLines: 3,
              style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500,
                  fontSize: 16, color: C.onSurface, height: 1.5),
              decoration: const InputDecoration(
                hintText: 'Enter text to translate...',
                hintStyle: TextStyle(color: C.outlineVar, fontSize: 15),
                border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) _inputCtrl.text = data!.text!;
                  },
                  child: _actionChip(Icons.paste_rounded, 'PASTE'),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _inputCtrl.clear(),
                  child: _actionChip(Icons.clear_all_rounded, 'CLEAR'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: C.surfaceHigh, borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: C.outline, size: 13),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 9,
              fontWeight: FontWeight.w700, letterSpacing: 1, color: C.outline)),
        ],
      ),
    );
  }

  Widget _translateButton() {
    final ready = _sourceReady && _targetReady;
    return GestureDetector(
      onTap: _isTranslating || _isDownloading
          ? null
          : (ready ? _translate : _downloadModels),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: _isTranslating || _isDownloading
                ? [const Color(0xFF3A3A3A), const Color(0xFF2A2A2A)]
                : [const Color(0xFF7B61FF), const Color(0xFF5B3FD6)],
          ),
          boxShadow: [
            if (!_isTranslating && !_isDownloading)
              BoxShadow(color: const Color(0xFF7B61FF).withValues(alpha: 0.3), blurRadius: 20),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isTranslating || _isDownloading)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
              ),
            Icon(
              ready ? Icons.translate_rounded : Icons.download_rounded,
              color: Colors.white, size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              _isDownloading
                  ? 'DOWNLOADING MODELS...'
                  : _isTranslating
                      ? 'TRANSLATING...'
                      : ready
                          ? 'TRANSLATE'
                          : 'DOWNLOAD MODELS',
              style: const TextStyle(fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w900, fontSize: 16,
                  letterSpacing: 1, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          const Icon(Icons.terminal, color: Color(0xFF7B61FF), size: 14),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_statusText, style: const TextStyle(fontFamily: 'SpaceGrotesk',
                fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1,
                color: Color(0xFF7B61FF))),
          ),
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (_sourceReady && _targetReady)
                    ? Color.lerp(const Color(0xFF34C759),
                        const Color(0xFF34C759).withValues(alpha: 0.3), _pulseCtrl.value)
                    : Color.lerp(const Color(0xFFFF9500),
                        const Color(0xFFFF9500).withValues(alpha: 0.3), _pulseCtrl.value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _outputCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: C.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF34C759).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Text('${_targetLang.flag}  ${_targetLang.name.toUpperCase()}',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 10,
                      fontWeight: FontWeight.w700, letterSpacing: 1.5,
                      color: Color(0xFF34C759))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('ON-DEVICE', style: TextStyle(fontFamily: 'Inter',
                      fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 1,
                      color: Color(0xFF34C759))),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              _translatedText,
              style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500,
                  fontSize: 16, color: C.onSurface, height: 1.5),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _translatedText));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ));
                  },
                  child: _actionChip(Icons.copy_rounded, 'COPY'),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _translatedText));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ));
                  },
                  child: _actionChip(Icons.share_rounded, 'SHARE'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modelInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surfaceLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: C.outline, size: 14),
              SizedBox(width: 8),
              Text('MODEL STATUS', style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w700, letterSpacing: 2.5, color: C.outline)),
            ],
          ),
          const SizedBox(height: 12),
          _modelRow(_sourceLang, _sourceReady),
          const SizedBox(height: 6),
          _modelRow(_targetLang, _targetReady),
          const SizedBox(height: 12),
          const Text(
            'Each model is ~30MB and cached on-device for offline use. '
            'Models are processed locally — your data never leaves the device.',
            style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                color: C.outline, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _modelRow(LanguageEntry lang, bool ready) {
    return Row(
      children: [
        Text(lang.flag, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(lang.name, style: const TextStyle(fontFamily: 'Inter',
              fontSize: 12, fontWeight: FontWeight.w600, color: C.onSurface)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: ready
                ? const Color(0xFF34C759).withValues(alpha: 0.15)
                : const Color(0xFFFF9500).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            ready ? 'CACHED' : 'NOT DOWNLOADED',
            style: TextStyle(fontFamily: 'Inter', fontSize: 8,
                fontWeight: FontWeight.w800, letterSpacing: 1,
                color: ready ? const Color(0xFF34C759) : const Color(0xFFFF9500)),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet language picker.
class _LanguagePicker extends StatefulWidget {
  final LanguageEntry current;
  const _LanguagePicker({required this.current});
  @override
  State<_LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<_LanguagePicker> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final langs = MlTranslatorService.supportedLanguages
        .where((l) => l.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: C.outline, borderRadius: BorderRadius.circular(2)),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('SELECT LANGUAGE',
                style: TextStyle(fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.w900, fontSize: 16,
                    letterSpacing: 2, color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(fontFamily: 'Inter', color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search languages...',
                hintStyle: const TextStyle(color: C.outlineVar),
                prefixIcon: const Icon(Icons.search, color: C.outline, size: 20),
                filled: true,
                fillColor: C.surfaceHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: ctrl,
              itemCount: langs.length,
              itemBuilder: (_, i) {
                final lang = langs[i];
                final sel = lang.language == widget.current.language;
                return ListTile(
                  leading: Text(lang.flag, style: const TextStyle(fontSize: 22)),
                  title: Text(lang.name,
                      style: TextStyle(fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w700, fontSize: 14,
                          color: sel ? const Color(0xFF7B61FF) : Colors.white)),
                  trailing: sel
                      ? const Icon(Icons.check_circle, color: Color(0xFF7B61FF), size: 20)
                      : null,
                  onTap: () => Navigator.pop(context, lang),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
