import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/modules/branches/branches.dart';
import 'package:dokan_erp/modules/products/products.dart';
import 'package:dokan_erp/modules/reports/reports.dart';
import 'package:dokan_erp/modules/sales/sales.dart';
import 'package:dokan_erp/modules/settings/settings.dart';
import 'package:dokan_erp/modules/purchases/domain/entities/purchase_order.dart';
import 'package:dokan_erp/modules/purchases/presentation/providers/purchase_product_catalog_provider.dart';
import 'package:dokan_erp/modules/purchases/presentation/providers/purchase_provider.dart';

part 'parts/purchase_list_screen.dart';
part 'parts/purchase_detail_screen.dart';
part 'parts/new_purchase_screen.dart';
part 'parts/purchase_presentation_models.dart';

// Utility function to format numbers in Bengali digits
String _bn(dynamic value) {
  if (value == null) return '';
  final String english = value.toString();
  const digits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  final buffer = StringBuffer();
  for (var i = 0; i < english.length; i++) {
    final code = english.codeUnitAt(i) - 48;
    if (code >= 0 && code <= 9) {
      buffer.write(digits[code]);
    } else {
      buffer.write(english[i]);
    }
  }
  return buffer.toString();
}
