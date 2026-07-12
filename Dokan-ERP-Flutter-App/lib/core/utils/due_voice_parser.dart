/// Parses a spoken "due" (বাকি) sentence into a structured command.
///
/// Handles mixed Bangla/English speech such as:
///   "রহিম ভাই ৪০০ টাকা বাকি নিসে"
///   "Rahim vai 400 taka baki nise"
/// producing { customerName: "রহিম ভাই", amount: 400, isDue: true }.
class DueVoiceCommand {
  const DueVoiceCommand({
    required this.customerName,
    required this.amount,
    required this.isDue,
    required this.rawText,
  });

  final String customerName;
  final int amount;
  final bool isDue;
  final String rawText;

  bool get isValid => customerName.isNotEmpty && amount > 0 && isDue;
}

abstract final class DueVoiceParser {
  // Words that signal a due/credit was taken.
  static const _dueKeywords = [
    'baki', 'বাকি', 'বকেয়া', 'ধার', 'dhar', 'nise', 'নিসে', 'নিয়েছে',
    'niyeche', 'niyechen', 'nilo', 'নিলো', 'due', 'credit',
  ];

  // Noise words stripped from the customer name.
  static const _noiseWords = [
    'টাকা', 'taka', 'tk', 'tk.', 'taka', 'poisa', 'পয়সা',
    'baki', 'বাকি', 'বকেয়া', 'ধার', 'dhar', 'due', 'credit',
    'nise', 'নিসে', 'নিয়েছে', 'niyeche', 'niyechen', 'nilo', 'নিলো',
    'nilen', 'নিলেন', 'add', 'koro', 'করো', 'kore', 'করে',
  ];

  static DueVoiceCommand parse(String text) {
    final normalized = _banglaDigitsToEnglish(text).trim();

    final amountMatch = RegExp(r'(\d{1,7})').firstMatch(normalized);
    final amount = amountMatch != null ? int.tryParse(amountMatch.group(1)!) ?? 0 : 0;

    final lower = normalized.toLowerCase();
    final isDue = _dueKeywords.any((keyword) => lower.contains(keyword));

    var name = normalized;
    if (amountMatch != null) {
      name = name.replaceFirst(amountMatch.group(1)!, ' ');
    }
    for (final word in _noiseWords) {
      name = name.replaceAll(
        RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false),
        ' ',
      );
      // Bangla words aren't matched by \b, so also strip them directly.
      name = name.replaceAll(word, ' ');
    }
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();

    return DueVoiceCommand(
      customerName: name,
      amount: amount,
      isDue: isDue,
      rawText: text,
    );
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
