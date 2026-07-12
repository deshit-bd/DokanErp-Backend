import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dokan_erp/modules/dashboard/dashboard.dart';
import 'package:dokan_erp/modules/auth/auth.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/modules/inventory/inventory.dart';
import 'package:dokan_erp/modules/notifications/domain/entities/stock_alert_notification.dart';
import 'package:dokan_erp/modules/products/products.dart';
import 'package:dokan_erp/modules/reports/reports.dart';
import 'package:dokan_erp/modules/settings/settings.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/modules/notifications/domain/repositories/notification_snapshot_repository.dart';
import 'package:dokan_erp/modules/notifications/domain/repositories/notification_repository.dart';
import 'package:dokan_erp/modules/notifications/presentation/providers/notification_providers.dart';
import 'package:dokan_erp/core/core.dart';

part 'parts/dokan_notification_store.dart';
part 'parts/header_bar.dart';
part 'parts/bottom_nav_bar.dart';
part 'parts/notification_detail_sheet.dart';
part 'parts/preference_toggle_row.dart';
