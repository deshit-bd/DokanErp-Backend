import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/repositories/report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => throw UnimplementedError('Override reportRepositoryProvider'),
);

final reportConfiguredProvider = Provider<bool>(
  (ref) => AppConfig.isApiConfigured,
);
