/// Detects the intent of a spoken shop command and extracts its fields.
///
/// Examples:
///   "রহিম ভাই ৪০০ টাকা বাকি নিসে"   -> due     (name=রহিম ভাই, amount=400)
///   "৫০০ টাকা দোকান ভাড়া খরচ"        -> expense (title=দোকান ভাড়া, amount=500)
///   "৩টা কলম বিক্রি"                 -> sell    (product=কলম, quantity=3)
enum VoiceIntent { due, expense, sell, unknown }

class VoiceCommand {
  const VoiceCommand({
    required this.intent,
    required this.text,
    required this.amount,
    required this.quantity,
    required this.rawText,
  });

  final VoiceIntent intent;

  /// Customer name (due), expense title, or product name (sell).
  final String text;
  final int amount;
  final int quantity;
  final String rawText;
}

abstract final class VoiceCommandParser {
  static const _sellKeywords = [
    'বিক্রি', 'বিক্রয়', 'বেচা', 'বেচলাম', 'বেচো', 'bikri', 'bikroy', 'becha', 'sell', 'sale',
  ];
  static const _expenseKeywords = [
    'খরচ', 'খরচা', 'khoroch', 'khorcha', 'expense', 'বিল', 'bill', 'ভাড়া', 'bhara',
    'বেতন', 'beton', 'salary', 'ভাড়া',
  ];
  static const _dueKeywords = [
    'বাকি', 'বকেয়া', 'ধার', 'baki', 'bokeya', 'dhar', 'due', 'credit',
    'নিসে', 'নিয়েছে', 'niyeche', 'nise',
  ];

  static const _commonNoise = [
    'টাকা', 'taka', 'tk', 'poisa', 'পয়সা', 'টা', 'টি', 'pcs', 'piece', 'pc',
    'add', 'koro', 'করো', 'kore', 'করে', 'holo', 'হলো', 'kor', 'দাও', 'dao',
  ];

  static VoiceCommand parse(String raw) {
    final normalized = _banglaDigitsToEnglish(raw).trim();
    final lower = normalized.toLowerCase();

    final numbers = RegExp(r'(\d{1,7})')
        .allMatches(normalized)
        .map((m) => int.tryParse(m.group(1)!) ?? 0)
        .where((n) => n > 0)
        .toList();

    final intent = _detectIntent(lower);

    // Strip numbers, action verbs and units — but keep descriptive nouns like
    // "ভাড়া"/"বিল"/"বেতন" so an expense title stays meaningful.
    final keywords = <String>{
      ..._commonNoise,
      ..._sellKeywords,
      ..._dueKeywords,
      'খরচ', 'খরচা', 'khoroch', 'khorcha', 'expense',
    };
    var text = normalized;
    for (final n in numbers) {
      text = text.replaceFirst(n.toString(), ' ');
    }
    for (final word in keywords) {
      text = text
          .replaceAll(RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false), ' ')
          .replaceAll(word, ' ');
    }
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // For sell, the leading number is a quantity; amount (price) is optional.
    final quantity = intent == VoiceIntent.sell
        ? (numbers.isNotEmpty ? numbers.first : 1)
        : 1;
    final amount = intent == VoiceIntent.sell
        ? (numbers.length > 1 ? numbers[1] : 0)
        : (numbers.isNotEmpty ? numbers.first : 0);

    return VoiceCommand(
      intent: intent,
      text: text,
      amount: amount,
      quantity: quantity,
      rawText: raw,
    );
  }

  static VoiceIntent _detectIntent(String lower) {
    if (_sellKeywords.any(lower.contains)) return VoiceIntent.sell;
    if (_expenseKeywords.any(lower.contains)) return VoiceIntent.expense;
    if (_dueKeywords.any(lower.contains)) return VoiceIntent.due;
    return VoiceIntent.unknown;
  }

  static String _banglaDigitsToEnglish(String input) {
    const map = {
      '০': '0', '১': '1', '২': '2', '৩': '3', '৪': '4',
      '৫': '5', '৬': '6', '৭': '7', '৮': '8', '৯': '9',
    };
    final buffer = StringBuffer();
    for (final char in input.split('')) {
      buffer.write(map[char] ?? char);
    }
    return buffer.toString();
  }
}
