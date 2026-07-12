abstract final class ApiEndpoints {
  static const apiVersion = '/app/api';

  static const login = '$apiVersion/auth/login';
  static const register = '$apiVersion/auth/register-owner';
  static const checkMobile = '$apiVersion/auth/check-mobile';
  static const sendOtp = '$apiVersion/auth/send-otp';
  static const verifyOtp = '$apiVersion/auth/verify-otp';
  static const refreshToken = '$apiVersion/auth/refresh';
  static const logout = '$apiVersion/auth/logout';
  static const profile = '$apiVersion/auth/me';
  static const dashboard = '$apiVersion/dashboard';
  static const stores = '$apiVersion/stores';
  static const products = '$apiVersion/products';
  static const shopProducts = '$apiVersion/shops/products';
  static const quickSetupCatalog = '$apiVersion/shops/quick-setup/catalog';
  static const quickSetupCatalogSelect =
      '$apiVersion/shops/quick-setup/catalog/select';
  static const quickSetupCatalogPricing =
      '$apiVersion/shops/quick-setup/catalog/pricing';
  static const categories = '$apiVersion/categories';
  static const units = '$apiVersion/units';
  static const inventory = '$apiVersion/inventory';
  static const inventoryMode = '$inventory/mode';
  static const inventoryLayoutTree = '$inventory/layout-tree';
  static const inventoryZones = '$inventory/zones';
  static const inventoryRacks = '$inventory/racks';
  static const inventoryShelves = '$inventory/shelves';
  static const inventoryBins = '$inventory/bins';
  static const stockMovements = '$inventory/stock-movements';
  static const purchases = '$apiVersion/purchases';
  static const customers = '$apiVersion/customers';
  static const sales = '$customers/sales';
  static const expenses = '$apiVersion/expenses';
  static const suppliers = '$apiVersion/suppliers';
  static const staff = '$apiVersion/staff';
  static const notifications = '$apiVersion/notifications';
  static const notificationPreferences = '$notifications/settings';
  static const settings = '$apiVersion/settings';
  static const reports = '$apiVersion/reports';
  static const subscriptions = '$apiVersion/subscriptions';
  static const mySubscription = '$subscriptions/me';
  static const subscriptionPayments = '$subscriptions/payments';
  static const shopLogo = '$apiVersion/shops/me/logo';

  static String product(String id) => '$products/${Uri.encodeComponent(id)}';
  static String purchase(String id) => '$purchases/${Uri.encodeComponent(id)}';
  static String sale(String id) => '$sales/${Uri.encodeComponent(id)}';
  static String expense(String id) => '$expenses/${Uri.encodeComponent(id)}';
  static String category(String id) => '$categories/${Uri.encodeComponent(id)}';
  static String customer(String id) => '$customers/${Uri.encodeComponent(id)}';
  static String supplier(String id) => '$suppliers/${Uri.encodeComponent(id)}';
  static String notification(String id) =>
      '$notifications/${Uri.encodeComponent(id)}';
  static String customerPayments(String id) => '${customer(id)}/payments';
  static String supplierLedger(String id) => '${supplier(id)}/ledger';
  static String supplierPayments(String id) => '${supplier(id)}/payments';
  static String inventoryZone(String id) =>
      '$inventoryZones/${Uri.encodeComponent(id)}';
  static String inventoryRack(String id) =>
      '$inventoryRacks/${Uri.encodeComponent(id)}';
  static String inventoryShelf(String id) =>
      '$inventoryShelves/${Uri.encodeComponent(id)}';
  static String inventoryBin(String id) =>
      '$inventoryBins/${Uri.encodeComponent(id)}';
}
