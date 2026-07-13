/// Detects the intent of a spoken shop command and extracts its fields.
///
/// Examples:
///   "রহিম ভাই ৪০০ টাকা বাকি নিসে"   -> due     (name=রহিম ভাই, amount=400)
///   "৫০০ টাকা দোকান ভাড়া খরচ"        -> expense (title=দোকান ভাড়া, amount=500)
///   "৩টা কলম বিক্রি"                 -> sell    (product=কলম, quantity=3)
enum VoiceIntent { due, expense, sell, removeSell, addStaff, stockIn, stockOut, unknown }

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
    'বিক্রি', 'বিক্রয়', 'বেচা', 'বেচলাম', 'বেচো', 'bikri', 'bikroy', 'becha', 'sell', 'sale', 'সেল',
  ];
  static const _expenseKeywords = [
    'খরচ', 'খরচা', 'khoroch', 'khorcha', 'expense', 'বিল', 'bill', 'ভাড়া', 'bhara',
    'বেতন', 'beton', 'salary', 'আসছে', 'এক্সপেন্স', 'কস্ট',
  ];
  static const _dueKeywords = [
    'বাকি', 'বকেয়া', 'ধার', 'baki', 'bokeya', 'dhar', 'due', 'credit',
    'নিসে', 'নিয়েছে', 'niyeche', 'nise', 'ডিউ',
  ];
  static const _removeKeywords = [
    'বাদ', 'রিমুভ', 'মুছে', 'মুছো', 'মুছুন', 'ফেলে', 'delete', 'remove', 'clear', 'ডিলিট', 'ক্লিয়ার',
  ];
  static const _staffKeywords = [
    'कर्मचारी', 'কর্মচারী', 'স্টাফ', 'কাজের মানুষ', 'salesman', 'staff', 'employee', 'এমপ্লয়ি',
  ];
  static const _stockInKeywords = [
    'আসছে', 'ঢুকাও', 'যোগ করো', 'স্টক যোগ', 'মাল আসছে', 'আইছে', 'মাল আইছে', 'যোগ', 'স্টকইন', 'stock in', 'stockin', 'এড', 'অ্যাড',
  ];
  static const _stockOutKeywords = [
    'নষ্ট', 'নষ্ট হয়ে গেছে', 'মেয়াদ শেষ', 'পচে গেছে', 'পঁচা', 'ভাঙা', 'কাটা', 'বাদ দাও', 'damage', 'waste', 'reduce', 'ড্যামেজ', 'ওয়েস্ট',
  ];

  static const _commonNoise = [
    'টাকা', 'taka', 'tk', 'poisa', 'পয়সা', 'টা', 'টি', 'pcs', 'piece', 'pc',
    'add', 'koro', 'করো', 'kore', 'করে', 'holo', 'হলো', 'kor', 'দাও', 'dao',
    'কেজি', 'kg', 'লিটার', 'liter', 'ডজন', 'doz', 'হালি', 'প্যাকেট', 'packet',
    'বস্তা', 'কার্টন', 'পিস', 'দেও', 'দে', 'নিল', 'নিলো', 'নিসে', 'নিয়েছে',
    'দিল', 'দিলো', 'দিয়েছে', 'দিছে', 'দিসে', 'দেয়', 'করুন', 'করছে', 'নতুন',
    'পণ্য', 'পন্য', 'পান্না', 'পানা', 'ponno', 'ponyo', 'panna', 'আইটেম', 'item',
    'একটি', 'একটা', 'এক',
  ];

  static VoiceCommand parse(String raw) {
    final normalized = _normalizeBanglaTextAndNumbers(raw).trim();
    final lower = normalized.toLowerCase();

    final numbers = RegExp(r'(\d{1,7})')
        .allMatches(normalized)
        .map((m) => int.tryParse(m.group(1)!) ?? 0)
        .where((n) => n > 0)
        .toList();

    final intent = _detectIntent(lower);

    int quantity = 1;
    int amount = 0;

    // Check for explicit currency patterns (e.g. 500 taka)
    final amountMatch = RegExp(r'(\d+)\s*(টাকা|টাকার|taka|tk|৳)', caseSensitive: false).firstMatch(normalized);
    if (amountMatch != null) {
      amount = int.tryParse(amountMatch.group(1)!) ?? 0;
      
      final remainingNormalized = normalized.replaceFirst(amountMatch.group(0)!, '');
      final remainingNumbers = RegExp(r'(\d{1,7})')
          .allMatches(remainingNormalized)
          .map((m) => int.tryParse(m.group(1)!) ?? 0)
          .where((n) => n > 0)
          .toList();
          
      if (remainingNumbers.isNotEmpty) {
        quantity = remainingNumbers.first;
      }
    } else {
      if (intent == VoiceIntent.sell || intent == VoiceIntent.stockIn || intent == VoiceIntent.stockOut) {
        if (numbers.length == 1) {
          if (numbers.first >= 10 && intent == VoiceIntent.sell) {
            amount = numbers.first;
            quantity = 1;
          } else {
            quantity = numbers.first;
            amount = 0;
          }
        } else if (numbers.length > 1) {
          quantity = numbers[0];
          amount = numbers[1];
        }
      } else {
        amount = numbers.isNotEmpty ? numbers.first : 0;
        quantity = 1;
      }
    }

    // Strip numbers, action verbs and units — but keep descriptive nouns like
    // "ভাড়া"/"বিল"/"বেতন" so an expense title stays meaningful.
    final keywords = <String>{
      ..._commonNoise,
      ..._sellKeywords,
      ..._dueKeywords,
      ..._removeKeywords,
      ..._staffKeywords,
      ..._stockInKeywords,
      ..._stockOutKeywords,
      'খরচ', 'খরচা', 'khoroch', 'khorcha', 'expense',
    };
    
    // Sort keywords by length descending to prevent shorter substrings (like "টা")
    // from matching inside longer words (like "লিটার") before the longer word is replaced.
    final sortedKeywords = keywords.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    var text = normalized;
    for (final n in numbers) {
      text = text.replaceFirst(n.toString(), ' ');
    }
    for (final word in sortedKeywords) {
      text = text
          .replaceAll(RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false), ' ')
          .replaceAll(word, ' ');
    }
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return VoiceCommand(
      intent: intent,
      text: text,
      amount: amount,
      quantity: quantity,
      rawText: raw,
    );
  }

  static VoiceIntent _detectIntent(String lower) {
    if (_removeKeywords.any(lower.contains)) {
      if (_sellKeywords.any(lower.contains) || lower.contains('কার্ট') || lower.contains('cart')) {
        return VoiceIntent.removeSell;
      }
      return VoiceIntent.stockOut;
    }
    if (_staffKeywords.any(lower.contains)) return VoiceIntent.addStaff;
    if (_stockInKeywords.any(lower.contains)) return VoiceIntent.stockIn;
    if (_stockOutKeywords.any(lower.contains)) return VoiceIntent.stockOut;
    if (_sellKeywords.any(lower.contains)) return VoiceIntent.sell;
    if (_expenseKeywords.any(lower.contains)) return VoiceIntent.expense;
    if (_dueKeywords.any(lower.contains)) return VoiceIntent.due;
    return VoiceIntent.unknown;
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

    t = t.replaceAll('ওয়ান', '1');
    t = t.replaceAll('ওযান', '1');
    t = t.replaceAll('ওয়ান', '1');
    t = t.replaceAll('টু', '2');
    t = t.replaceAll('থ্রি', '3');
    t = t.replaceAll('ফোর', '4');
    t = t.replaceAll('ফাইভ', '5');
    t = t.replaceAll('সিক্স', '6');
    t = t.replaceAll('সেভেন', '7');
    t = t.replaceAll('এইট', '8');
    t = t.replaceAll('নাইন', '9');
    t = t.replaceAll('টেন', '10');
    t = t.replaceAll('হানড্রেড', '100');
    t = t.replaceAll('থাউজেন্ড', '1000');

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
