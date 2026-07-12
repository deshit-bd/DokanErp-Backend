abstract final class CalculationHelper {
  static num percentage(num amount, num percent) {
    return amount * percent / 100;
  }

  static num profit({
    required num sellingPrice,
    required num costPrice,
  }) {
    return sellingPrice - costPrice;
  }
}
