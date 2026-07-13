import 'dart:math' as math;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/dokan_catalog_product.dart';
import 'product_service.dart';

class DokanScanResult {
  const DokanScanResult({
    required this.rawCode,
    required this.normalizedCode,
    required this.product,
  });

  final String rawCode;
  final String normalizedCode;
  final DokanCatalogProduct? product;

  bool get isResolved => product != null;
}

class DokanScanService {
  DokanScanService(this._productService) {
    loadCustomSynonyms();
  }

  final ProductService _productService;
  final Map<String, List<String>> customSynonyms = {};

  Map<String, List<String>> get defaultSynonyms => _bilingualSynonyms;

  DokanScanResult resolve(String rawCode) {
    final normalizedCode = _productService.normalizeProductId(rawCode);
    final product = _productService.getProduct(normalizedCode);

    return DokanScanResult(
      rawCode: rawCode,
      normalizedCode: normalizedCode,
      product: product,
    );
  }

  Future<void> loadCustomSynonyms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('dokan_voice_synonyms');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> decoded = json.decode(jsonStr);
        decoded.forEach((key, val) {
          if (val is List) {
            customSynonyms[key] = List<String>.from(val);
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _saveCustomSynonyms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dokan_voice_synonyms', json.encode(customSynonyms));
    } catch (_) {}
  }

  void registerSynonym(String englishWord, String banglaWord) {
    final key = englishWord.toLowerCase().trim();
    final val = banglaWord.toLowerCase().trim();
    if (key.isEmpty || val.isEmpty) return;
    if (!customSynonyms.containsKey(key)) {
      customSynonyms[key] = [];
    }
    if (!customSynonyms[key]!.contains(val)) {
      customSynonyms[key]!.add(val);
    }
    _saveCustomSynonyms();
  }

  void removeSynonym(String englishWord, String banglaWord) {
    final key = englishWord.toLowerCase().trim();
    final val = banglaWord.toLowerCase().trim();
    if (customSynonyms.containsKey(key)) {
      customSynonyms[key]!.remove(val);
      if (customSynonyms[key]!.isEmpty) {
        customSynonyms.remove(key);
      }
      _saveCustomSynonyms();
    }
  }

  /// Best-effort product lookup by (spoken) name for voice-driven selling.
  DokanCatalogProduct? findByName(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return null;
    final products = _productService.allProducts;

    // 1. Exact match
    for (final product in products) {
      if (product.name.toLowerCase() == needle) return product;
    }

    // 2. Substring match
    for (final product in products) {
      final name = product.name.toLowerCase();
      if (name.contains(needle) || needle.contains(name)) return product;
    }

    // 3. Token-overlap / Sub-word fuzzy matching (extremely robust for Bengali/English transcriptions)
    final needleTokens = needle.split(RegExp(r'[\s\-]+')).where((t) => t.length > 1).toList();
    if (needleTokens.isNotEmpty) {
      DokanCatalogProduct? bestMatch;
      double bestScore = 0.0;

      for (final product in products) {
        final name = product.name.toLowerCase();
        final nameTokens = name.split(RegExp(r'[\s\-]+')).where((t) => t.length > 1).toList();
        if (nameTokens.isEmpty) continue;

        double scoreSum = 0.0;
        for (final nt in needleTokens) {
          double bestTokenScore = 0.0;
          for (final t in nameTokens) {
            final sim = _phoneticSimilarity(nt, t);
            if (sim > bestTokenScore) {
              bestTokenScore = sim;
            }
          }
          scoreSum += bestTokenScore;
        }

        final finalScore = scoreSum / needleTokens.length;
        if (finalScore > bestScore) {
          bestScore = finalScore;
          bestMatch = product;
        }
      }

      if (bestScore >= 0.5 && bestMatch != null) {
        return bestMatch;
      }
    }

    return null;
  }

  double _phoneticSimilarity(String tokenA, String tokenB) {
    final a = tokenA.toLowerCase().trim();
    final b = tokenB.toLowerCase().trim();
    if (a == b) return 1.0;
    if (a.contains(b) || b.contains(a)) return 0.9;

    // 1. Check custom translations first
    for (final entry in _bilingualSynonyms.entries) {
      final key = entry.key;
      final synonyms = entry.value;

      final isAMatching = (key == a || synonyms.contains(a));
      final isBMatching = (key == b || synonyms.contains(b));

      if (isAMatching && isBMatching) {
        return 1.0;
      }
    }

    // 2. Check dynamic custom synonyms
    for (final entry in customSynonyms.entries) {
      final key = entry.key;
      final synonyms = entry.value;

      final isAMatching = (key == a || synonyms.contains(a));
      final isBMatching = (key == b || synonyms.contains(b));

      if (isAMatching && isBMatching) {
        return 1.0;
      }
    }

    // 3. Check phonetic transliteration similarity (e.g. সাকিব <-> Sakib)
    final phoneticA = _toPhonetic(a);
    final phoneticB = _toPhonetic(b);
    if (phoneticA.isNotEmpty && phoneticB.isNotEmpty) {
      if (phoneticA == phoneticB) return 0.95;
      if (phoneticA.contains(phoneticB) || phoneticB.contains(phoneticA)) return 0.85;

      // 4. Consonant skeleton match (handles vowel shifting and minor spelling variations, e.g. sagor/sagr)
      final skeletonA = _toConsonantSkeleton(phoneticA);
      final skeletonB = _toConsonantSkeleton(phoneticB);
      if (skeletonA.isNotEmpty && skeletonB.isNotEmpty && skeletonA == skeletonB) {
        int matchingChars = 0;
        final minLen = math.min(phoneticA.length, phoneticB.length);
        for (var i = 0; i < minLen; i++) {
          if (phoneticA[i] == phoneticB[i]) matchingChars++;
        }
        final vowelMatchRatio = matchingChars / minLen;
        return 0.5 + (0.3 * vowelMatchRatio);
      }
    }

    return 0.0;
  }
}

const Map<String, List<String>> _bilingualSynonyms = {
  'lux': ['লাক্স'],
  'soap': ['সাবান', 'সোপ'],
  'sugar': ['চিনি'],
  'rice': ['চাল', 'চাউল'],
  'dal': ['ডাল', 'ডাউল'],
  'oil': ['তেল', 'তৈল'],
  'coke': ['কোক', 'কোকা', 'কোলা'],
  'coca': ['কোকা'],
  'cola': ['কোলা'],
  'biscuit': ['বিস্কুট', 'বিস্কিট'],
  'tea': ['চা'],
  'milk': ['দুধ'],
  'egg': ['ডিম'],
  'water': ['पानी', 'পানি', 'জল'],
  'potato': ['আলু'],
  'onion': ['পেঁয়াজ', 'পেয়াজ'],
  'garlic': ['রসুন'],
  'salt': ['লবণ', 'লবন'],
  'honey': ['মধু'],
  'flour': ['আটা', 'ময়দা'],
  'chicken': ['মুরগি', 'মুরগী'],
  'meat': ['মাংস'],
  'fish': ['মাছ'],
  'banana': ['কলা'],
  'apple': ['আপেল'],
  'orange': ['কমলা'],
  'mango': ['আম'],
  'shampoo': ['শ্যাম্পু'],
  'toothpaste': ['টুথপেস্ট'],
  'brush': ['ব্রাশ'],
};

String _toPhonetic(String input) {
  var s = input.trim().toLowerCase();
  if (s.isEmpty) return '';

  // If already pure alphanumeric, normalize common English phonetics
  if (RegExp(r'^[a-z0-9\s\-]+$').hasMatch(s)) {
    s = s.replaceAll('ph', 'f')
         .replaceAll('ch', 'c')
         .replaceAll('sh', 's')
         .replaceAll('z', 'j')
         .replaceAll('x', 'ks')
         .replaceAll('c', 'k')
         .replaceAll('q', 'k')
         .replaceAll('y', 'i')
         .replaceAll('w', 'o');
    return s;
  }

  final sb = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final char = s[i];
    switch (char) {
      // Consonants
      case 'ক': case 'খ': sb.write('k'); break;
      case 'গ': case 'ঘ': sb.write('g'); break;
      case 'চ': case 'ছ': sb.write('c'); break;
      case 'জ': case 'ঝ': case 'য': sb.write('j'); break;
      case 'ট': case 'ঠ': case 'ত': case 'থ': sb.write('t'); break;
      case 'ড': case 'ঢ': case 'দ': case 'ধ': sb.write('d'); break;
      case 'ন': case 'ণ': sb.write('n'); break;
      case 'প': case 'ফ': sb.write('p'); break;
      case 'ব': case 'ভ': sb.write('b'); break;
      case 'ম': sb.write('m'); break;
      case 'র': case 'ড়': case 'ঢ়': sb.write('r'); break;
      case 'ল': sb.write('l'); break;
      case 'শ': case 'ষ': case 'স': sb.write('s'); break;
      case 'হ': sb.write('h'); break;
      case 'ঙ': case 'ং': sb.write('ng'); break;

      // Vowels
      case 'া': case 'অ': case 'আ': sb.write('a'); break;
      case 'ি': case 'ী': case 'ই': case 'ঈ': sb.write('i'); break;
      case 'ু': case 'ূ': case 'উ': case 'ঊ': sb.write('u'); break;
      case 'ে': case 'এ': sb.write('e'); break;
      case 'ো': case 'ও': sb.write('o'); break;
      case 'ৈ': sb.write('oi'); break;
      case 'ৌ': sb.write('ou'); break;

      default:
        if (RegExp(r'[a-z0-9]').hasMatch(char)) {
          sb.write(char);
        }
    }
  }

  final res = sb.toString();
  // Remove duplicates (e.g. saakib -> sakib)
  var prev = '';
  final cleaned = StringBuffer();
  for (var i = 0; i < res.length; i++) {
    final char = res[i];
    if (char != prev) {
      cleaned.write(char);
      prev = char;
    }
  }
  return cleaned.toString();
}

String _toConsonantSkeleton(String phonetic) {
  return phonetic.replaceAll(RegExp(r'[aeiou]'), '');
}
