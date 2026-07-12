part of '../product_screens.dart';

class _PriceChangeResult {
  const _PriceChangeResult({
    required this.purchasePrice,
    required this.salePrice,
  });

  final int purchasePrice;
  final int salePrice;
}

List<_ProductHistoryEntry> _historyFor(DokanCatalogProduct product) {
  switch (product.barcode) {
    case '880001':
      return const [
        _ProductHistoryEntry(
            label: 'বিক্রয়',
            amount: '-২টি',
            timeLabel: 'আজ ৯:৪১ AM',
            color: Color(0xFFD43B3B)),
        _ProductHistoryEntry(
            label: 'বিক্রয়',
            amount: '-১টি',
            timeLabel: 'আজ ৮:৩০ AM',
            color: Color(0xFFD43B3B)),
        _ProductHistoryEntry(
            label: 'ক্রয়',
            amount: '+২৫টি',
            timeLabel: 'গতকাল',
            color: Color(0xFF0C8C67)),
      ];
    case '880004':
      return const [
        _ProductHistoryEntry(
            label: 'বিক্রয়',
            amount: '-২টি',
            timeLabel: 'আজ ৯:৪১ AM',
            color: Color(0xFFD43B3B)),
        _ProductHistoryEntry(
            label: 'বিক্রয়',
            amount: '-১টি',
            timeLabel: 'আজ ৮:৩০ AM',
            color: Color(0xFFD43B3B)),
        _ProductHistoryEntry(
            label: 'ক্রয়',
            amount: '+১২টি',
            timeLabel: 'গতকাল',
            color: Color(0xFF0C8C67)),
      ];
    case '880005':
      return const [
        _ProductHistoryEntry(
            label: 'বিক্রয়',
            amount: '-৩টি',
            timeLabel: 'আজ ১১:১০ AM',
            color: Color(0xFFD43B3B)),
        _ProductHistoryEntry(
            label: 'বিক্রয়',
            amount: '-২টি',
            timeLabel: 'আজ ৯:১৫ AM',
            color: Color(0xFFD43B3B)),
        _ProductHistoryEntry(
            label: 'ক্ষতি',
            amount: '+৩০টি',
            timeLabel: 'গতকাল',
            color: Color(0xFFF49B1A)),
      ];
    case '880002':
      return const [
        _ProductHistoryEntry(
            label: 'বিক্রয়',
            amount: '-১টি',
            timeLabel: 'গতকাল',
            color: Color(0xFFD43B3B)),
        _ProductHistoryEntry(
            label: 'ক্ষতি',
            amount: '-৫টি',
            timeLabel: 'গতকাল',
            color: Color(0xFFF49B1A)),
        _ProductHistoryEntry(
            label: 'ক্রয়',
            amount: '+১০টি',
            timeLabel: 'গত মঙ্গলবার',
            color: Color(0xFF0C8C67)),
      ];
    default:
      return const [
        _ProductHistoryEntry(
            label: 'বিক্রয়',
            amount: '-১টি',
            timeLabel: 'আজ',
            color: Color(0xFFD43B3B)),
        _ProductHistoryEntry(
            label: 'ক্রয়',
            amount: '+১০টি',
            timeLabel: 'গতকাল',
            color: Color(0xFF0C8C67)),
        _ProductHistoryEntry(
            label: 'ক্ষতি',
            amount: '-২টি',
            timeLabel: 'গত সপ্তাহ',
            color: Color(0xFFF49B1A)),
      ];
  }
}
