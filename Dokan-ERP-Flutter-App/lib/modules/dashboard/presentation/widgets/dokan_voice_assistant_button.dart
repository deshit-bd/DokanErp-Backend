import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/modules/sales/sales.dart';
import 'package:dokan_erp/modules/products/products.dart';
import 'package:dokan_erp/modules/expenses/expenses.dart';

/// One mic button that understands multiple shop commands and routes each to the
/// right action:
///   • "রহিম ভাই ৪০০ টাকা বাকি নিসে"  -> add customer due
///   • "৫০০ টাকা দোকান ভাড়া খরচ"       -> add expense
///   • "৩টা কলম বিক্রি"                -> add product(s) to the sell cart
class DokanVoiceAssistantButton extends ConsumerStatefulWidget {
  const DokanVoiceAssistantButton({super.key});

  @override
  ConsumerState<DokanVoiceAssistantButton> createState() =>
      _DokanVoiceAssistantButtonState();
}

class _DokanVoiceAssistantButtonState
    extends ConsumerState<DokanVoiceAssistantButton> {
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

  Future<void> _listen() async {
    if (!_available) {
      _toast('মাইক্রোফোন পাওয়া যায়নি');
      return;
    }
    var transcript = '';
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          if (!_speech.isListening) {
            _speech.listen(
              localeId: 'bn_BD',
              listenOptions: SpeechListenOptions(partialResults: true),
              onResult: (r) {
                transcript = r.recognizedWords;
                setSheetState(() {});
                if (r.finalResult) Navigator.of(sheetContext).pop(transcript);
              },
            );
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mic, color: Colors.redAccent, size: 44),
                const SizedBox(height: 10),
                const Text('শুনছি... বলুন',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text(
                  'বিক্রি / খরচ / বাকি — যেকোনো কমান্ড',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Text(transcript.isEmpty ? '...' : transcript,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () async {
                    await _speech.stop();
                    Navigator.of(sheetContext).pop(transcript);
                  },
                  child: const Text('সম্পন্ন'),
                ),
              ],
            ),
          );
        },
      ),
    );
    await _speech.stop();
    if (!mounted || result == null || result.trim().isEmpty) return;
    await _route(VoiceCommandParser.parse(result));
  }

  Future<void> _route(VoiceCommand command) async {
    switch (command.intent) {
      case VoiceIntent.due:
        await _addDue(command);
        break;
      case VoiceIntent.expense:
        await _addExpense(command);
        break;
      case VoiceIntent.sell:
        await _addToCart(command);
        break;
      case VoiceIntent.unknown:
        _toast('বুঝতে পারিনি: "${command.rawText}" — আবার বলুন');
        break;
    }
  }

  Future<void> _addDue(VoiceCommand c) async {
    if (c.text.isEmpty || c.amount <= 0) {
      _toast('নাম বা টাকা বুঝিনি — আবার বলুন');
      return;
    }
    final ok = await _confirm(
        'বকেয়া যোগ', '${c.text} — ৳${c.amount} বকেয়া যোগ হবে (তারিখ: আজ)।');
    if (ok != true || !mounted) return;
    await ref
        .read(dokanPosProvider.notifier)
        .addCustomer(name: c.text, phone: '', openingDue: c.amount);
    if (mounted) _toast('${c.text} — ৳${c.amount} বকেয়া যোগ হয়েছে');
  }

  Future<void> _addExpense(VoiceCommand c) async {
    if (c.amount <= 0) {
      _toast('খরচের টাকা বুঝিনি — আবার বলুন');
      return;
    }
    final title = c.text.isEmpty ? 'ভয়েস খরচ' : c.text;
    final category = _expenseCategory('${c.text} ${c.rawText}');
    final ok = await _confirm(
        'খরচ যোগ', '$title — ৳${c.amount} খরচ যোগ হবে ($category, আজ)।');
    if (ok != true || !mounted) return;
    final record = DokanExpenseRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      category: category,
      amount: c.amount.toDouble(),
      date: DateTime.now(),
    );
    await ref.read(expenseReportControllerProvider.notifier).addExpense(record);
    if (mounted) _toast('$title — ৳${c.amount} খরচ যোগ হয়েছে');
  }

  Future<void> _addToCart(VoiceCommand c) async {
    if (c.text.isEmpty) {
      _toast('কোন পণ্য বুঝিনি — আবার বলুন');
      return;
    }
    final product = ref.read(dokanScanServiceProvider).findByName(c.text);
    if (product == null) {
      _toast('"${c.text}" নামে পণ্য পাওয়া যায়নি');
      return;
    }
    final qty = c.quantity < 1 ? 1 : c.quantity;
    final cart = ref.read(cartServiceProvider);
    for (var i = 0; i < qty; i++) {
      cart.addProduct(product);
    }
    if (mounted) {
      _toast('$qty×${product.name} কার্টে যোগ হয়েছে — বিক্রি সম্পন্ন করুন');
    }
  }

  String _expenseCategory(String text) {
    final t = text.toLowerCase();
    if (t.contains('ভাড়া') || t.contains('bhara')) return 'ভাড়া';
    if (t.contains('বিদ্যুৎ') || t.contains('বিল') || t.contains('bill')) {
      return 'বিদ্যুৎ বিল';
    }
    if (t.contains('বেতন') || t.contains('salary')) return 'কর্মচারীর বেতন';
    if (t.contains('পরিবহন') || t.contains('গাড়ি')) return 'পরিবহন';
    return 'অন্যান্য';
  }

  Future<bool?> _confirm(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('বাতিল'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('নিশ্চিত করুন'),
          ),
        ],
      ),
    );
  }

  void _toast(String message) {
    if (!mounted) return;
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
    return FloatingActionButton(
      heroTag: 'voice-assistant-fab',
      onPressed: _listen,
      backgroundColor: const Color(0xFF0C8C67),
      child: const Icon(Icons.mic, color: Colors.white),
    );
  }
}
