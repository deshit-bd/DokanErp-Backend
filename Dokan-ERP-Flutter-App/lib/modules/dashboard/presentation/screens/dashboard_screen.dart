import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/modules/auth/auth.dart';
import 'package:dokan_erp/modules/branches/branches.dart';
import 'package:dokan_erp/modules/expenses/expenses.dart';
import 'package:dokan_erp/modules/dashboard/presentation/widgets/dokan_voice_assistant_button.dart';
import 'package:dokan_erp/modules/notifications/notifications.dart';
import 'package:dokan_erp/modules/products/products.dart';
import 'package:dokan_erp/modules/purchases/purchases.dart';
import 'package:dokan_erp/modules/reports/reports.dart';
import 'package:dokan_erp/modules/sales/sales.dart';
import 'package:dokan_erp/modules/settings/settings.dart';
import 'package:dokan_erp/modules/dashboard/presentation/providers/dashboard_providers.dart';
import 'parts/dokan_salesman_transactions_screen.dart';

part 'parts/dokan_home_dashboard_screen.dart';
part 'parts/header_icon_button.dart';
part 'parts/product_card.dart';
