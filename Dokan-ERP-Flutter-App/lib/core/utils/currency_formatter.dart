import '../theme/app_theme.dart';

abstract final class CurrencyFormatter {
  static String format(num amount) {
    return '${AppStrings.currencySymbol}${amount.toStringAsFixed(0)}';
  }
}
