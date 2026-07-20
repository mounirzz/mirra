import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A system text-to-speech voice.
class VoiceOption {
  const VoiceOption(this.name, this.locale);
  final String name;
  final String locale;

  bool sameAs(VoiceOption? o) => o != null && o.name == name && o.locale == locale;
}

/// Wraps flutter_tts: lists English voices, applies one, and reads text aloud.
class VoiceService {
  final FlutterTts _tts = FlutterTts();
  bool _inited = false;

  Future<void> _init() async {
    if (_inited) return;
    _inited = true;
    await _tts.awaitSpeakCompletion(true);
    await _tts.setSpeechRate(0.46); // calm, affirmation-friendly pace
    await _tts.setPitch(1.0);
  }

  // Legacy MacinTalk "novelty" voices (Bad News, Boing, Zarvox…) don't sound
  // like a person, so we hide them. They fall back to name-matching on the rare
  // device that doesn't expose an identifier.
  static const _noveltyNames = {
    'Albert', 'Bad News', 'Bahh', 'Bells', 'Boing', 'Bubbles', 'Cellos',
    'Deranged', 'Fred', 'Good News', 'Hysterical', 'Jester', 'Junior', 'Kathy',
    'Organ', 'Pipe Organ', 'Princess', 'Ralph', 'Superstar', 'Trinoids',
    'Whisper', 'Wobble', 'Zarvox',
  };

  bool _isNatural(String identifier, String name) {
    if (identifier.isNotEmpty) {
      // Legacy synthesizers use com.apple.speech.synthesis.voice.* ; the real
      // speech voices use com.apple.ttsbundle.* / com.apple.voice.* / siri_*.
      return !identifier.startsWith('com.apple.speech.synthesis.voice.');
    }
    return !_noveltyNames.contains(name);
  }

  Future<List<VoiceOption>> englishVoices() async {
    await _init();
    final raw = (await _tts.getVoices) as List<dynamic>? ?? const [];
    final out = <VoiceOption>[];
    final seen = <String>{};
    for (final v in raw) {
      final m = Map<String, dynamic>.from(v as Map);
      final name = (m['name'] ?? '').toString();
      final locale = (m['locale'] ?? '').toString();
      final identifier = (m['identifier'] ?? '').toString();
      if (name.isEmpty || !locale.toLowerCase().startsWith('en')) continue;
      if (!_isNatural(identifier, name)) continue;
      if (seen.add(name)) out.add(VoiceOption(name, locale));
    }
    out.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return out;
  }

  Future<void> setVoice(VoiceOption v) async {
    await _init();
    try {
      await _tts.setVoice({'name': v.name, 'locale': v.locale});
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    await _init();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}

final voiceServiceProvider = Provider<VoiceService>((ref) => VoiceService());

final voicesProvider = FutureProvider<List<VoiceOption>>(
  (ref) => ref.read(voiceServiceProvider).englishVoices(),
);

/// The chosen voice (persisted). Applied to the TTS engine on load + change.
class SelectedVoiceNotifier extends StateNotifier<VoiceOption?> {
  SelectedVoiceNotifier(this._ref) : super(null) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final name = sp.getString('voice_name');
    final locale = sp.getString('voice_locale');
    if (name != null && locale != null) {
      final v = VoiceOption(name, locale);
      state = v;
      await _ref.read(voiceServiceProvider).setVoice(v);
    }
  }

  Future<void> select(VoiceOption v) async {
    state = v;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('voice_name', v.name);
    await sp.setString('voice_locale', v.locale);
    await _ref.read(voiceServiceProvider).setVoice(v);
  }
}

final selectedVoiceProvider =
    StateNotifierProvider<SelectedVoiceNotifier, VoiceOption?>(
  (ref) => SelectedVoiceNotifier(ref),
);
