abstract interface class CartRepository {
  void addItem(String productId, {required int stockLimit});

  void removeItem(String productId);

  void setItemQuantity(
    String productId,
    int quantity, {
    required int stockLimit,
  });
}
