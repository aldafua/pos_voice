import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

typedef VoiceResultCallback = void Function(String words, bool isFinal);

/// Pembungkus paket speech_to_text untuk pengenalan suara berbahasa Indonesia.
class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;
  String? _localeId;

  /// Pendengar status/kesalahan diatur oleh widget yang sedang aktif.
  void Function(String status)? statusListener;
  void Function(String error)? errorListener;

  bool get isListening => _speech.isListening;

  Future<bool> ensureInitialized() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(
      onStatus: (s) => statusListener?.call(s),
      onError: (e) => errorListener?.call(e.errorMsg),
    );
    if (_initialized) {
      final locales = await _speech.locales();
      for (final l in locales) {
        if (l.localeId.toLowerCase().startsWith('id')) {
          _localeId = l.localeId;
          break;
        }
      }
    }
    return _initialized;
  }

  Future<void> startListening(VoiceResultCallback onResult) async {
    if (!await ensureInitialized()) return;
    await _speech.listen(
      onResult: (SpeechRecognitionResult r) => onResult(r.recognizedWords, r.finalResult),
      localeId: _localeId ?? 'id_ID',
      listenFor: const Duration(seconds: 12),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> stop() => _speech.stop();

  Future<void> cancel() => _speech.cancel();
}
