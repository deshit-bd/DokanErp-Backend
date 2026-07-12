class InventorySettings {
  const InventorySettings({
    this.lowStockLimit = 10,
    this.criticalStockLimit = 5,
    this.autoLowStockAlert = true,
    this.autoDeductOnSale = true,
    this.allowNegativeStock = false,
    this.binAssignmentRequired = true,
    this.showBinOnSale = true,
    this.trackExpiry = false,
    this.costingMethod = 'FIFO',
  });

  final int lowStockLimit;
  final int criticalStockLimit;
  final bool autoLowStockAlert;
  final bool autoDeductOnSale;
  final bool allowNegativeStock;
  final bool binAssignmentRequired;
  final bool showBinOnSale;
  final bool trackExpiry;
  final String costingMethod;

  Map<String, dynamic> toJson() => {
        'lowStockLimit': lowStockLimit,
        'criticalStockLimit': criticalStockLimit,
        'autoLowStockAlert': autoLowStockAlert,
        'autoDeductOnSale': autoDeductOnSale,
        'allowNegativeStock': allowNegativeStock,
        'binAssignmentRequired': binAssignmentRequired,
        'showBinOnSale': showBinOnSale,
        'trackExpiry': trackExpiry,
        'costingMethod': costingMethod,
      };

  factory InventorySettings.fromJson(Map<String, dynamic> json) {
    return InventorySettings(
      lowStockLimit: (json['lowStockLimit'] as num?)?.toInt() ?? 10,
      criticalStockLimit: (json['criticalStockLimit'] as num?)?.toInt() ?? 5,
      autoLowStockAlert: json['autoLowStockAlert'] as bool? ?? true,
      autoDeductOnSale: json['autoDeductOnSale'] as bool? ?? true,
      allowNegativeStock: json['allowNegativeStock'] as bool? ?? false,
      binAssignmentRequired: json['binAssignmentRequired'] as bool? ?? true,
      showBinOnSale: json['showBinOnSale'] as bool? ?? true,
      trackExpiry: json['trackExpiry'] as bool? ?? false,
      costingMethod: json['costingMethod'] as String? ?? 'FIFO',
    );
  }
}

class StoreDetails {
  const StoreDetails({
    this.storeName = '',
    this.ownerName = '',
    this.mobile = '',
    this.address = '',
    this.storeType = 'মুদি দোকান',
    this.tradeLicenseNo = '',
    this.tinNo = '',
    this.binNo = '',
    this.liveLocation = '',
    this.latitude,
    this.longitude,
    this.logoFileName = '',
    this.logoBase64 = '',
    this.logoUrl = '',
    this.receiptShowName = true,
    this.receiptShowPhone = true,
    this.receiptShowAddress = true,
    this.receiptShowLogo = false,
  });

  final String storeName;
  final String ownerName;
  final String mobile;
  final String address;
  final String storeType;
  final String tradeLicenseNo;
  final String tinNo;
  final String binNo;
  final String liveLocation;
  final double? latitude;
  final double? longitude;
  final String logoFileName;
  final String logoBase64;
  final String logoUrl;
  final bool receiptShowName;
  final bool receiptShowPhone;
  final bool receiptShowAddress;
  final bool receiptShowLogo;

  StoreDetails copyWith({
    String? storeName,
    String? ownerName,
    String? mobile,
    String? address,
    String? storeType,
    String? tradeLicenseNo,
    String? tinNo,
    String? binNo,
    String? liveLocation,
    double? latitude,
    double? longitude,
    String? logoFileName,
    String? logoBase64,
    String? logoUrl,
    bool? receiptShowName,
    bool? receiptShowPhone,
    bool? receiptShowAddress,
    bool? receiptShowLogo,
    bool clearLatitude = false,
    bool clearLongitude = false,
  }) {
    return StoreDetails(
      storeName: storeName ?? this.storeName,
      ownerName: ownerName ?? this.ownerName,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      storeType: storeType ?? this.storeType,
      tradeLicenseNo: tradeLicenseNo ?? this.tradeLicenseNo,
      tinNo: tinNo ?? this.tinNo,
      binNo: binNo ?? this.binNo,
      liveLocation: liveLocation ?? this.liveLocation,
      latitude: clearLatitude ? null : latitude ?? this.latitude,
      longitude: clearLongitude ? null : longitude ?? this.longitude,
      logoFileName: logoFileName ?? this.logoFileName,
      logoBase64: logoBase64 ?? this.logoBase64,
      logoUrl: logoUrl ?? this.logoUrl,
      receiptShowName: receiptShowName ?? this.receiptShowName,
      receiptShowPhone: receiptShowPhone ?? this.receiptShowPhone,
      receiptShowAddress: receiptShowAddress ?? this.receiptShowAddress,
      receiptShowLogo: receiptShowLogo ?? this.receiptShowLogo,
    );
  }

  Map<String, dynamic> toJson() => {
        'storeName': storeName,
        'ownerName': ownerName,
        'mobile': mobile,
        'address': address,
        'storeType': storeType,
        'tradeLicenseNo': tradeLicenseNo,
        'tinNo': tinNo,
        'binNo': binNo,
        'liveLocation': liveLocation,
        'latitude': latitude,
        'longitude': longitude,
        'logoFileName': logoFileName,
        'logoBase64': logoBase64,
        'logoUrl': logoUrl,
        'receiptShowName': receiptShowName,
        'receiptShowPhone': receiptShowPhone,
        'receiptShowAddress': receiptShowAddress,
        'receiptShowLogo': receiptShowLogo,
      };

  factory StoreDetails.fromJson(Map<String, dynamic> json) {
    return StoreDetails(
      storeName: json['storeName'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      address: json['address'] as String? ?? '',
      storeType: json['storeType'] as String? ?? 'মুদি দোকান',
      tradeLicenseNo: json['tradeLicenseNo'] as String? ?? '',
      tinNo: json['tinNo'] as String? ?? '',
      binNo: json['binNo'] as String? ?? '',
      liveLocation: json['liveLocation'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      logoFileName: json['logoFileName'] as String? ?? '',
      logoBase64: json['logoBase64'] as String? ?? '',
      logoUrl: json['logoUrl'] as String? ?? '',
      receiptShowName: json['receiptShowName'] as bool? ?? true,
      receiptShowPhone: json['receiptShowPhone'] as bool? ?? true,
      receiptShowAddress: json['receiptShowAddress'] as bool? ?? true,
      receiptShowLogo: json['receiptShowLogo'] as bool? ?? false,
    );
  }
}

enum StoreDocumentType { trade, tin, bin }

class StoreDocumentUpload {
  const StoreDocumentUpload({
    required this.fileName,
    required this.contentType,
    required this.base64Data,
  });

  final String fileName;
  final String contentType;
  final String base64Data;

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'contentType': contentType,
        'base64Data': base64Data,
      };
}

class StoreSetupSubmission {
  const StoreSetupSubmission({
    required this.details,
    this.tradeDocument,
    this.tinDocument,
    this.binDocument,
  });

  final StoreDetails details;
  final StoreDocumentUpload? tradeDocument;
  final StoreDocumentUpload? tinDocument;
  final StoreDocumentUpload? binDocument;
}
