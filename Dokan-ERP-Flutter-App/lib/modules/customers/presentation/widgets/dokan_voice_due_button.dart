import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/modules/sales/sales.dart';

/// A mic button that records a spoken due, e.g. "রহিম ভাই ৪০০ টাকা বাকি নিসে",
/// parses it, confirms with the user, then adds the amount to that customer's
/// due ledger (creating the customer if needed).
class DokanVoiceDueButton extends ConsumerStatefulWidget {
  const DokanVoiceDueButton({super.key});

  @override
  ConsumerState<DokanVoiceDueButton> createState() =>
      _DokanVoiceDueButtonState();
}

class _DokanVoiceDueButtonState extends ConsumerState<DokanVoiceDueButton> {
  final SpeechToText _speech = SpeechToText();
  bool _available = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final available = await _speech.initialize();
      if (mounted) setState(() => _available = available);
    } catch (_) {
      if (mounted) setState(() => _available = false);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  Future<void> _startListening() async {
    if (!_available) {
      try {
        final available = await _speech.initialize();
        if (mounted) setState(() => _available = available);
        if (!available) {
          _toast('মাইক্রোফোন অনুমোদন করুন');
          return;
        }
      } catch (_) {
        _toast('মাইক্রোফোন অনুমোদন করুন');
        return;
      }
    }
    var transcript = '';
    final completed = await showModalBottomSheet<String>(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void finish() => Navigator.of(sheetContext).pop(transcript);
            // Begin listening once the sheet is shown.
            if (!_speech.isListening) {
              _speech.listen(
                localeId: 'bn_BD',
                listenOptions: SpeechListenOptions(partialResults: true),
                onResult: (result) {
                  transcript = result.recognizedWords;
                  setSheetState(() {});
                  if (result.finalResult) finish();
                },
              );
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mic, color: Colors.redAccent, size: 44),
                  const SizedBox(height: 12),
                  const Text('শুনছি... বলুন',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text('যেমন: "রহিম ভাই ৪০০ টাকা বাকি নিসে"',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 16),
                  Text(transcript.isEmpty ? '...' : transcript,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () async {
                      await _speech.stop();
                      finish();
                    },
                    child: const Text('সম্পন্ন'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    await _speech.stop();
    if (!mounted || completed == null || completed.trim().isEmpty) return;
    _processTranscript(completed);
  }

  Future<void> _processTranscript(String text) async {
    final command = DueVoiceParser.parse(text);
    if (!command.isValid) {
      _toast('বুঝতে পারিনি: "$text" — আবার চেষ্টা করুন');
      return;
    }

    await ref.read(dokanPosProvider.notifier).addCustomer(
          name: command.customerName,
          phone: '',
          openingDue: command.amount,
        );
    if (!mounted) return;
    _toast('${command.customerName} — ৳${command.amount} বকেয়া যোগ হয়েছে');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0F766E),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'voice-due-fab',
      onPressed: _startListening,
      backgroundColor: const Color(0xFF0C8C67),
      icon: const Icon(Icons.mic, color: Colors.white),
      label: const Text('ভয়েসে বকেয়া',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }
}
