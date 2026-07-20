import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/data/data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _RecordingApiClient client;

  setUp(() => client = _RecordingApiClient());

  test('auth endpoint contracts', () async {
    final source = AuthRemoteDataSource(client, _MemorySessionStore());
    await _verify(
        client,
        () => source.login(
              phone: '01700000000',
              password: 'secret',
              role: 0,
            ),
        'POST',
        ApiEndpoints.login,
        authenticated: false);
    await _verify(client, () => source.register({'name': 'Owner'}), 'POST',
        ApiEndpoints.register,
        authenticated: false);
    await _verify(client, () => source.checkMobile('01700000000'), 'POST',
        ApiEndpoints.checkMobile,
        authenticated: false);
    await _verify(client, () => source.sendOtp('01700000000'), 'POST',
        ApiEndpoints.sendOtp,
        authenticated: false);
    await _verify(
      client,
      () => source.verifyOtp(phone: '01700000000', code: '1234'),
      'POST',
      ApiEndpoints.verifyOtp,
      authenticated: false,
    );
    await _verify(client, source.profile, 'GET', ApiEndpoints.profile);
    await _verify(client, source.logout, 'POST', ApiEndpoints.logout);
  });

  test('product endpoint contracts', () async {
    final source = ProductRemoteDataSource(client);
    await _verify(client, source.list, 'GET', ApiEndpoints.products);
    await _verify(client, source.shopCatalog, 'GET', ApiEndpoints.shopProducts);
    await _verify(
        client, () => source.find('p/1'), 'GET', ApiEndpoints.product('p/1'));
    await _verify(client, () => source.create({'name': 'Rice'}), 'POST',
        ApiEndpoints.products);
    await _verify(client, () => source.update('p/1', {'name': 'Rice'}), 'PATCH',
        ApiEndpoints.product('p/1'));
    await _verify(client, () => source.delete('p/1'), 'DELETE',
        ApiEndpoints.product('p/1'));
    await _verify(
      client,
      () => source.adjustStock(
        productId: 'p1',
        quantity: 2,
        type: 'purchase',
      ),
      'POST',
      ApiEndpoints.stockMovements,
    );
    await _verify(client, source.categories, 'GET', ApiEndpoints.categories);
    await _verify(client, () => source.createCategory('Food'), 'POST',
        ApiEndpoints.categories);
    await _verify(client, () => source.deleteCategory('c/1'), 'DELETE',
        ApiEndpoints.category('c/1'));
    await _verify(client, source.inventorySettings, 'GET',
        '${ApiEndpoints.settings}/inventory');
    await _verify(client, () => source.saveInventoryThreshold(5), 'PATCH',
        '${ApiEndpoints.settings}/inventory');
  });

  test('purchase, sales and expense endpoint contracts', () async {
    final purchases = PurchaseRemoteDataSource(client);
    await _verify(client, purchases.list, 'GET', ApiEndpoints.purchases);
    await _verify(client, () => purchases.create({}, idempotencyKey: 'k'),
        'POST', ApiEndpoints.purchases);
    await _verify(client, () => purchases.update('po/1', {}), 'PATCH',
        ApiEndpoints.purchase('po/1'));
    await _verify(
        client,
        () => purchases.receive('po/1', {}, idempotencyKey: 'k'),
        'POST',
        '${ApiEndpoints.purchase('po/1')}/receive');
    await _verify(client, () => purchases.cancel('po/1'), 'POST',
        '${ApiEndpoints.purchase('po/1')}/cancel');

    final sales = SalesRemoteDataSource(client);
    await _verify(client, sales.list, 'GET', ApiEndpoints.sales);
    await _verify(client, () => sales.create({}, idempotencyKey: 'k'), 'POST',
        ApiEndpoints.sales);
    await _verify(
        client,
        () => sales.addPayment('s/1', {}, idempotencyKey: 'k'),
        'POST',
        '${ApiEndpoints.sale('s/1')}/payments');
    await _verify(client, () => sales.cancel('s/1', reason: 'test'), 'POST',
        '${ApiEndpoints.sale('s/1')}/cancel');

    final expenses = ExpenseRemoteDataSource(client);
    await _verify(client, expenses.list, 'GET', ApiEndpoints.expenses);
    await _verify(
        client, () => expenses.create({}), 'POST', ApiEndpoints.expenses);
    await _verify(client, () => expenses.update('e/1', {}), 'PATCH',
        ApiEndpoints.expense('e/1'));
    await _verify(client, () => expenses.delete('e/1'), 'DELETE',
        ApiEndpoints.expense('e/1'));
  });

  test('customer and supplier endpoint contracts', () async {
    final customers = CustomerRemoteDataSource(client);
    await _verify(client, customers.list, 'GET', ApiEndpoints.customers);
    await _verify(client, () => customers.create({}, idempotencyKey: 'k'),
        'POST', ApiEndpoints.customers);

    final suppliers = SupplierRemoteDataSource(client);
    await _verify(client, suppliers.list, 'GET', ApiEndpoints.suppliers);
    await _verify(client, () => suppliers.ledger('sp/1'), 'GET',
        ApiEndpoints.supplierLedger('sp/1'));
    await _verify(client, () => suppliers.create({}, idempotencyKey: 'k'),
        'POST', ApiEndpoints.suppliers);
    await _verify(client, () => suppliers.delete('sp/1'), 'DELETE',
        ApiEndpoints.supplier('sp/1'));
    await _verify(client, () => suppliers.recordPayment('sp/1', {}, 'k'),
        'POST', ApiEndpoints.supplierPayments('sp/1'));
  });

  test('settings, subscription and inventory endpoint contracts', () async {
    final settings = BusinessSettingsRemoteDataSource(client);
    await _verify(client, settings.inventorySettings, 'GET',
        '${ApiEndpoints.settings}/inventory');
    await _verify(client, () => settings.saveInventorySettings({}), 'PATCH',
        '${ApiEndpoints.settings}/inventory');
    await _verify(
        client, settings.storeDetails, 'GET', '${ApiEndpoints.apiVersion}/shops/me/settings');
    await _verify(client, () => settings.saveStoreDetails({}), 'PATCH',
        '${ApiEndpoints.apiVersion}/shops/me/settings');

    final subscription = SubscriptionRemoteDataSource(client);
    await _verify(client, subscription.loadSubscriptionInfo, 'GET',
        ApiEndpoints.mySubscription);
    await _verify(
      client,
      () => subscription.paySubscription(
        amount: 100,
        method: 'bkash',
        trxId: 'trx',
      ),
      'POST',
      ApiEndpoints.subscriptionPayments,
    );

    final inventory = InventoryLayoutRemoteDataSource(client);
    await _verify(
        client, inventory.getInventoryMode, 'GET', ApiEndpoints.inventoryMode);
    await _verify(client, () => inventory.updateInventoryMode({'mode': 'RACK'}),
        'POST', ApiEndpoints.inventoryMode);
    await _verify(client, inventory.getLayoutTree, 'GET',
        ApiEndpoints.inventoryLayoutTree);
    await _verify(client, () => inventory.createZone({'name': 'Z'}), 'POST',
        ApiEndpoints.inventoryZones);
    await _verify(client, () => inventory.updateZone('z/1', {'name': 'Z'}),
        'PATCH', ApiEndpoints.inventoryZone('z/1'));
    await _verify(client, () => inventory.deleteZone('z/1'), 'DELETE',
        ApiEndpoints.inventoryZone('z/1'));
    await _verify(
        client,
        () => inventory.createRack({'zoneId': 'z1', 'name': 'R'}),
        'POST',
        ApiEndpoints.inventoryRacks);
    await _verify(client, () => inventory.updateRack('r/1', {'name': 'R'}),
        'PATCH', ApiEndpoints.inventoryRack('r/1'));
    await _verify(client, () => inventory.deleteRack('r/1'), 'DELETE',
        ApiEndpoints.inventoryRack('r/1'));
    await _verify(
      client,
      () => inventory.createShelf({
        'zone_id': 'z1',
        'rack_id': 'r1',
        'name': 'S',
        'direction': 'top',
      }),
      'POST',
      ApiEndpoints.inventoryShelves,
    );
    await _verify(
      client,
      () => inventory.updateShelf('s/1', {'name': 'S', 'direction': 'top'}),
      'PATCH',
      ApiEndpoints.inventoryShelf('s/1'),
    );
    await _verify(client, () => inventory.deleteShelf('s/1'), 'DELETE',
        ApiEndpoints.inventoryShelf('s/1'));
    await _verify(
      client,
      () => inventory.createBin({
        'zone_id': 'z1',
        'rack_id': 'r1',
        'shelf_id': 's1',
        'code': 'B',
        'quantity': 1,
      }),
      'POST',
      ApiEndpoints.inventoryBins,
    );
    await _verify(
      client,
      () => inventory.updateBin('b/1', {'code': 'B', 'quantity': 1}),
      'PATCH',
      ApiEndpoints.inventoryBin('b/1'),
    );
    await _verify(client, () => inventory.deleteBin('b/1'), 'DELETE',
        ApiEndpoints.inventoryBin('b/1'));
  });

  test('ERP read endpoint contracts', () async {
    final source = ErpRemoteDataSource(client);
    await _verify(client, source.dashboard, 'GET', ApiEndpoints.dashboard);
    await _verify(client, source.customers, 'GET', ApiEndpoints.customers);
    await _verify(client, source.staff, 'GET', ApiEndpoints.staff);
    await _verify(client, () => source.report('profit/loss'), 'GET',
        '${ApiEndpoints.reports}/profit-loss');
    await _verify(
        client, source.notifications, 'GET', ApiEndpoints.notifications);
  });
}

Future<void> _verify(
  _RecordingApiClient client,
  Future<Object?> Function() action,
  String method,
  String path, {
  bool authenticated = true,
}) async {
  client.calls.clear();
  await action();
  expect(client.calls, hasLength(1));
  expect(client.calls.single.method, method);
  expect(client.calls.single.path, path);
  expect(client.calls.single.authenticated, authenticated);
}

class _ApiCall {
  const _ApiCall(this.method, this.path, this.authenticated);

  final String method;
  final String path;
  final bool authenticated;
}

class _RecordingApiClient implements ApiClient {
  final calls = <_ApiCall>[];

  ApiResponse<Map<String, dynamic>> _response(
      String method, String path, bool authenticated) {
    calls.add(_ApiCall(method, path, authenticated));
    return const ApiResponse(data: {'data': []}, statusCode: 200);
  }

  @override
  void close({bool force = false}) {}

  @override
  Future<ApiResponse<Map<String, dynamic>>> get(String path,
          {Map<String, dynamic>? query,
          Map<String, String>? headers,
          bool authenticated = true}) async =>
      _response('GET', path, authenticated);

  @override
  Future<ApiResponse<Map<String, dynamic>>> post(String path,
          {Object? body,
          Map<String, dynamic>? query,
          Map<String, String>? headers,
          bool authenticated = true}) async =>
      _response('POST', path, authenticated);

  @override
  Future<ApiResponse<Map<String, dynamic>>> put(String path,
          {Object? body,
          Map<String, dynamic>? query,
          Map<String, String>? headers,
          bool authenticated = true}) async =>
      _response('PUT', path, authenticated);

  @override
  Future<ApiResponse<Map<String, dynamic>>> patch(String path,
          {Object? body,
          Map<String, dynamic>? query,
          Map<String, String>? headers,
          bool authenticated = true}) async =>
      _response('PATCH', path, authenticated);

  @override
  Future<ApiResponse<Map<String, dynamic>>> delete(String path,
          {Object? body,
          Map<String, dynamic>? query,
          Map<String, String>? headers,
          bool authenticated = true}) async =>
      _response('DELETE', path, authenticated);
}

class _MemorySessionStore implements ApiSessionStore {
  ApiSession? session;

  @override
  Future<void> clear() async => session = null;

  @override
  Future<ApiSession?> read() async => session;

  @override
  Future<void> write(ApiSession value) async => session = value;
}
