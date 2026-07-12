import '../../../../core/network/json_value.dart';
import '../../domain/entities/business_settings.dart';

abstract final class BusinessSettingsApiMapper {
  static InventorySettings inventoryFromJson(Map<String, dynamic> json) {
    return InventorySettings(
      lowStockLimit: JsonValue.integer(
        json,
        const ['low_stock_limit', 'lowStockLimit'],
        fallback: 10,
      ),
      criticalStockLimit: JsonValue.integer(
        json,
        const ['critical_stock_limit', 'criticalStockLimit'],
        fallback: 5,
      ),
      autoLowStockAlert: JsonValue.boolean(
        json,
        const ['auto_low_stock_alert', 'autoLowStockAlert'],
        fallback: true,
      ),
      autoDeductOnSale: JsonValue.boolean(
        json,
        const ['auto_deduct_on_sale', 'autoDeductOnSale'],
        fallback: true,
      ),
      allowNegativeStock: JsonValue.boolean(
        json,
        const ['allow_negative_stock', 'allowNegativeStock'],
      ),
      binAssignmentRequired: JsonValue.boolean(
        json,
        const ['bin_assignment_required', 'binAssignmentRequired'],
        fallback: true,
      ),
      showBinOnSale: JsonValue.boolean(
        json,
        const ['show_bin_on_sale', 'showBinOnSale'],
        fallback: true,
      ),
      trackExpiry: JsonValue.boolean(
        json,
        const ['track_expiry', 'trackExpiry'],
      ),
      costingMethod: JsonValue.string(
        json,
        const ['costing_method', 'costingMethod'],
        fallback: 'FIFO',
      ),
    );
  }

  static Map<String, dynamic> inventoryToJson(InventorySettings settings) {
    return {
      'low_stock_limit': settings.lowStockLimit,
      'critical_stock_limit': settings.criticalStockLimit,
      'auto_low_stock_alert': settings.autoLowStockAlert,
      'auto_deduct_on_sale': settings.autoDeductOnSale,
      'allow_negative_stock': settings.allowNegativeStock,
      'bin_assignment_required': settings.binAssignmentRequired,
      'show_bin_on_sale': settings.showBinOnSale,
      'track_expiry': settings.trackExpiry,
      'costing_method': settings.costingMethod,
    };
  }

  static StoreDetails storeFromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> shop =
        (json['shop'] is Map) ? json['shop'] as Map<String, dynamic> : json;
    final Map<String, dynamic> owner =
        (json['owner'] is Map) ? json['owner'] as Map<String, dynamic> : json;
    final Map<String, dynamic> receipt = (json['receiptSetting'] is Map)
        ? json['receiptSetting'] as Map<String, dynamic>
        : ((json['receipt'] is Map)
            ? json['receipt'] as Map<String, dynamic>
            : <String, dynamic>{});

    return StoreDetails(
      storeName:
          JsonValue.string(shop, const ['store_name', 'storeName', 'shopName']),
      ownerName:
          JsonValue.string(owner, const ['owner_name', 'ownerName', 'name']),
      mobile: JsonValue.string(shop, const ['mobile', 'phone']),
      address: JsonValue.string(shop, const ['address']),
      storeType: JsonValue.string(
          shop, const ['store_type', 'storeType', 'businessType']),
      tradeLicenseNo: JsonValue.string(
        shop,
        const ['trade_license_no', 'tradeLicenseNo'],
      ),
      tinNo: JsonValue.string(shop, const ['tin_no', 'tinNo']),
      binNo: JsonValue.string(
        shop,
        const ['bin_no', 'bin_no_number', 'vat_reg_no', 'binNo'],
      ),
      liveLocation: JsonValue.string(
        shop,
        const ['live_location', 'shop_location', 'location', 'area'],
      ),
      latitude: (shop['latitude'] as num?)?.toDouble(),
      longitude: (shop['longitude'] as num?)?.toDouble(),
      logoFileName: JsonValue.string(
        shop,
        const ['logo_file_name', 'logoFileName'],
      ),
      logoBase64: JsonValue.string(
        shop,
        const ['logo_base64', 'logoBase64'],
      ),
      logoUrl: JsonValue.string(
        shop,
        const ['logo_url', 'logoUrl'],
      ),
      receiptShowName: JsonValue.boolean(
          receipt, const ['showVatInfo', 'show_vat_info'],
          fallback: true),
      receiptShowPhone: JsonValue.boolean(
          receipt, const ['showPhone', 'show_phone'],
          fallback: true),
      receiptShowAddress: JsonValue.boolean(
          receipt, const ['showAddress', 'show_address'],
          fallback: true),
      receiptShowLogo: JsonValue.boolean(
          receipt, const ['showLogo', 'show_logo'],
          fallback: false),
    );
  }

  static Map<String, dynamic> storeToJson(StoreDetails details) {
    return {
      'store_name': details.storeName,
      'shopName': details.storeName,
      'owner_name': details.ownerName,
      'ownerName': details.ownerName,
      'mobile': details.mobile,
      'phone': details.mobile,
      'address': details.address,
      'store_type': details.storeType,
      'businessType': details.storeType,
      'trade_license_no': details.tradeLicenseNo,
      'tradeLicenseNo': details.tradeLicenseNo,
      'tin_no': details.tinNo,
      'tinNo': details.tinNo,
      'bin_no': details.binNo,
      'binNo': details.binNo,
      'live_location': details.liveLocation,
      'liveLocation': details.liveLocation,
      'latitude': details.latitude,
      'longitude': details.longitude,
      'logo_file_name': details.logoFileName,
      'logoFileName': details.logoFileName,
      'logo_base64': details.logoBase64,
      'logoBase64': details.logoBase64,
      'logo_url': details.logoUrl,
      'logoUrl': details.logoUrl,
      'receipt': {
        'showPhone': details.receiptShowPhone,
        'showAddress': details.receiptShowAddress,
        'showLogo': details.receiptShowLogo,
        'showVatInfo': details.receiptShowName,
      },
    };
  }
}
