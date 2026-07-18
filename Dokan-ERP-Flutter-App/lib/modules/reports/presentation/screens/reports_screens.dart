import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:bangla_pdf_fixer/bangla_pdf_fixer.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore_for_file: deprecated_member_use, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, argument_type_not_assignable, unused_element, non_exhaustive_switch_expression
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/modules/dashboard/dashboard.dart';
import 'package:dokan_erp/modules/expenses/expenses.dart';
import 'package:dokan_erp/modules/products/products.dart';
import 'package:dokan_erp/modules/purchases/purchases.dart';
import 'package:dokan_erp/modules/sales/sales.dart';
import 'package:dokan_erp/modules/settings/settings.dart';
import 'package:dokan_erp/modules/reports/domain/repositories/report_repository.dart';
import 'package:dokan_erp/modules/reports/presentation/providers/report_providers.dart';

part 'parts/dokan_report_time_filter.dart';
part 'parts/dokan_reports_home_screen.dart';
part 'parts/section_card.dart';
part 'parts/ranked_product_card.dart';
part 'parts/dokan_daily_sales_report_page.dart';
part 'parts/dokan_daily_purchase_report_screen.dart';
part 'parts/dokan_stock_value_report_page.dart';
part 'parts/dokan_stock_report_page.dart';
part 'parts/expense_summary_kpi.dart';
part 'parts/expense_trend_chart.dart';
part 'parts/stock_category_value.dart';
part 'parts/daily_hero_metric.dart';
part 'parts/value_line_item.dart';
part 'parts/reports_nav_item.dart';
