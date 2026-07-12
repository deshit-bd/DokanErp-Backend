import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// A microphone button that captures speech and returns the recognised text.
///
/// Drop it next to any search field: tap to start listening, tap again to stop.
/// Recognised words are streamed to [onResult] so the caller can update its
/// query live. Works on Android/iOS; on web it depends on the browser's speech
/// support and silently disables itself when unavailable.
class DokanVoiceSearchButton extends StatefulWidget {
  const DokanVoiceSearchButton({
    super.key,
    required this.onResult,
    this.localeId = 'bn_BD',
    this.tooltip = 'ভয়েস দিয়ে খুঁজুন',
    this.color,
  });

  /// Called with the (partial and final) transcript as the user speaks.
  final ValueChanged<String> onResult;

  /// Preferred locale — Bangla by default, falls back to the device default.
  final String localeId;
  final String tooltip;
  final Color? color;

  @override
  State<DokanVoiceSearchButton> createState() => _DokanVoiceSearchButtonState();
}

class _DokanVoiceSearchButtonState extends State<DokanVoiceSearchButton> {
  final SpeechToText _speech = SpeechToText();
  bool _available = false;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            setState(() => _listening = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _listening = false);
        },
      );
      if (mounted) setState(() => _available = available);
    } catch (_) {
      if (mounted) setState(() => _available = false);
    }
  }

  Future<void> _toggle() async {
    if (!_available) return;
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      localeId: widget.localeId,
      onResult: (result) => widget.onResult(result.recognizedWords),
      listenOptions: SpeechListenOptions(partialResults: true),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide entirely when speech isn't available (e.g. unsupported web browser).
    if (!_available && kIsWeb) return const SizedBox.shrink();
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return IconButton(
      tooltip: widget.tooltip,
      onPressed: _available ? _toggle : null,
      icon: Icon(
        _listening ? Icons.mic : Icons.mic_none_rounded,
        color: _listening ? Colors.redAccent : color,
      ),
    );
  }
}
