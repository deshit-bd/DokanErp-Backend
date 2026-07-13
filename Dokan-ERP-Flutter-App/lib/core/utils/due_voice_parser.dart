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
    'টাকা', 'taka', 'tk', 'tk.', 'poisa', 'পয়সা', 'টা', 'টি', 'pcs', 'piece', 'pc',
    'baki', 'বাকি', 'বকেয়া', 'ধার', 'dhar', 'due', 'credit',
    'nise', 'নিসে', 'নিয়েছে', 'niyeche', 'niyechen', 'nilo', 'নিলো',
    'nilen', 'নিলেন', 'add', 'koro', 'করো', 'kore', 'করে', 'holo', 'হলো', 'kor',
    'দাও', 'dao', 'কেজি', 'kg', 'লিটার', 'liter', 'ডজন', 'doz', 'হালি', 'প্যাকেট',
    'packet', 'বস্তা', 'কার্টন', 'পিস', 'দেও', 'দে', 'দিল', 'দিলো', 'দিয়েছে',
    'দিছে', 'দিসে', 'দেয়', 'করুন', 'করছে', 'নতুন',
  ];

  static DueVoiceCommand parse(String text) {
    final normalized = _normalizeBanglaTextAndNumbers(text).trim();
    final lower = normalized.toLowerCase();

    final amountMatch = RegExp(r'(\d{1,7})').firstMatch(normalized);
    final amount = amountMatch != null ? int.tryParse(amountMatch.group(1)!) ?? 0 : 0;

    final isDue = _dueKeywords.any((keyword) => lower.contains(keyword));

    // Sort keywords by length descending to prevent shorter substrings (like "টা")
    // from matching inside longer words (like "লিটার") before the longer word is replaced.
    final sortedNoise = _noiseWords.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    var name = normalized;
    if (amountMatch != null) {
      name = name.replaceFirst(amountMatch.group(1)!, ' ');
    }
    for (final word in sortedNoise) {
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

  static String _normalizeBanglaTextAndNumbers(String input) {
    var t = input.toLowerCase();

    // 1. Dialect variations of words and noise reductions
    t = t.replaceAll('টেহা', 'টাকা');
    t = t.replaceAll('টেরা', 'টাকা');
    t = t.replaceAll('দেহাও', 'দেখাও');
    t = t.replaceAll('বেচো', 'বিক্রি');
    t = t.replaceAll('বেচাও', 'বিক্রি');
    t = t.replaceAll('বেচ', 'বিক্রি');
    t = t.replaceAll('বেচলাম', 'বিক্রি');
    t = t.replaceAll('বেঁচে', 'বিক্রি');
    t = t.replaceAll('আইছে', 'আসছে');
    t = t.replaceAll('আইল', 'আসছে');
    t = t.replaceAll('আইয়্যে', 'আসছে');
    
    t = t.replaceAll('দুইডা', '2');
    t = t.replaceAll('তিনডা', '3');
    t = t.replaceAll('চারডা', '4');
    t = t.replaceAll('পাঁচডা', '5');
    t = t.replaceAll('ছয়ডা', '6');
    t = t.replaceAll('সাতডা', '7');
    t = t.replaceAll('আটডা', '8');
    t = t.replaceAll('নয়ডা', '9');
    t = t.replaceAll('দশডা', '10');

    t = t.replaceAll('দুইটা', '2');
    t = t.replaceAll('তিনটা', '3');
    t = t.replaceAll('চারটা', '4');
    t = t.replaceAll('পাঁচটা', '5');
    t = t.replaceAll('ছয়টা', '6');
    t = t.replaceAll('সাতটা', '7');
    t = t.replaceAll('আটটা', '8');
    t = t.replaceAll('নয়টা', '9');
    t = t.replaceAll('দশটা', '10');

    // 2. Fractional quantities
    t = t.replaceAll('আধা কেজি', '1 কেজি');
    t = t.replaceAll('পোয়া কেজি', '1 কেজি');
    t = t.replaceAll('দেড় কেজি', '1 কেজি');
    t = t.replaceAll('আড়াই কেজি', '2 কেজি');
    t = t.replaceAll('সাড়ে তিন কেজি', '3 কেজি');
    t = t.replaceAll('আধা লিটার', '1 লিটার');
    t = t.replaceAll('হাফ লিটার', '1 লিটার');
    t = t.replaceAll('এক ডজন', '12');
    t = t.replaceAll('ডজন', '12');

    // 3. English written numbers
    t = t.replaceAll('one', '1');
    t = t.replaceAll('two', '2');
    t = t.replaceAll('three', '3');
    t = t.replaceAll('four', '4');
    t = t.replaceAll('five', '5');
    t = t.replaceAll('six', '6');
    t = t.replaceAll('seven', '7');
    t = t.replaceAll('eight', '8');
    t = t.replaceAll('nine', '9');
    t = t.replaceAll('ten', '10');
    t = t.replaceAll('hundred', '100');
    t = t.replaceAll('thousand', '1000');

    // 4. Multi-digit text numbers
    t = t.replaceAll('আড়াই হাজার', '2500');
    t = t.replaceAll('আড়াইশো', '250');
    t = t.replaceAll('আড়াইশত', '250');
    t = t.replaceAll('দেড়শো', '150');
    t = t.replaceAll('দেড়শত', '150');
    t = t.replaceAll('পনেরো শো', '1500');
    t = t.replaceAll('পনের শো', '1500');
    t = t.replaceAll('সাড়ে তিনশো', '350');
    t = t.replaceAll('দশ হাজার', '10000');
    t = t.replaceAll('এক হাজার', '1000');
    t = t.replaceAll('পাঁচশো', '500');
    t = t.replaceAll('পাঁচশত', '500');
    t = t.replaceAll('একশো', '100');
    t = t.replaceAll('একশত', '100');
    t = t.replaceAll('দুইশো', '200');
    t = t.replaceAll('তিনশো', '300');
    t = t.replaceAll('চারশো', '400');
    t = t.replaceAll('ছয়শো', '600');
    t = t.replaceAll('সাতশো', '700');
    t = t.replaceAll('আটশো', '800');
    t = t.replaceAll('নয়শো', '900');

    t = t.replaceAll('আড়াই', '2');
    t = t.replaceAll('দেড়', '1');
    t = t.replaceAll('আধা', '1');
    t = t.replaceAll('হাফ', '1');
    t = t.replaceAll('পোয়া', '1');

    // 5. Digits mapping (Bengali digits to English)
    const map = {
      '০': '0', '১': '1', '২': '2', '৩': '3', '৪': '4',
      '৫': '5', '৬': '6', '৭': '7', '৮': '8', '৯': '9',
    };
    final buffer = StringBuffer();
    for (final char in t.split('')) {
      buffer.write(map[char] ?? char);
    }
    t = buffer.toString();

    // 6. Bengali written numbers to digits
    t = _safeReplaceBanglaNumber(t, 'এক', '1');
    t = _safeReplaceBanglaNumber(t, 'দুই', '2');
    t = _safeReplaceBanglaNumber(t, 'তিন', '3');
    t = _safeReplaceBanglaNumber(t, 'চার', '4');
    t = _safeReplaceBanglaNumber(t, 'পাঁচ', '5');
    t = _safeReplaceBanglaNumber(t, 'ছয়', '6');
    t = _safeReplaceBanglaNumber(t, 'সাত', '7');
    t = _safeReplaceBanglaNumber(t, 'আট', '8');
    t = _safeReplaceBanglaNumber(t, 'নয়', '9');
    t = _safeReplaceBanglaNumber(t, 'দশ', '10');
    t = _safeReplaceBanglaNumber(t, 'বিশ', '20');
    t = _safeReplaceBanglaNumber(t, 'ত্রিশ', '30');
    t = _safeReplaceBanglaNumber(t, 'চল্লিশ', '40');
    t = _safeReplaceBanglaNumber(t, 'পঞ্চাশ', '50');
    t = _safeReplaceBanglaNumber(t, 'ষাট', '60');
    t = _safeReplaceBanglaNumber(t, 'সত্তর', '70');
    t = _safeReplaceBanglaNumber(t, 'আশি', '80');
    t = _safeReplaceBanglaNumber(t, 'নব্বই', '90');

    // 7. Merge compound hundreds: e.g. "100 50" -> "150"
    t = t.replaceAllMapped(RegExp(r'(\d)00\s+(\d{1,2})'), (match) {
      final hundreds = match.group(1)!;
      final tensOnes = match.group(2)!.padLeft(2, '0');
      return '$hundreds$tensOnes';
    });

    // Merge compound thousands: e.g. "2000 500" -> "2500"
    t = t.replaceAllMapped(RegExp(r'(\d)000\s+(\d{1,3})'), (match) {
      final thousands = match.group(1)!;
      final rest = match.group(2)!.padLeft(3, '0');
      return '$thousands$rest';
    });

    return t;
  }

  static String _safeReplaceBanglaNumber(String text, String banglaWord, String digit) {
    final pattern = RegExp(
      '(^|\\s)$banglaWord(\\s|টা|টি|জন|কেজি|লিটার|টাকা|৳|\$)',
    );
    return text.replaceAllMapped(pattern, (match) {
      final prefix = match.group(1)!;
      final suffix = match.group(2)!;
      return '$prefix$digit$suffix';
    });
  }
}
