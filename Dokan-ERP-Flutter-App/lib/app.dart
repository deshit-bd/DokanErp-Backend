import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/di/app_dependency_overrides.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/loading/dokan_api_loader_overlay.dart';
import 'core/widgets/dokan_buttons.dart';
import 'data/network/api_providers.dart';
import 'core/routing/app_routes.dart';
import 'modules/auth/presentation/providers/app_flow_provider.dart';
import 'modules/auth/presentation/screens/splash_screen.dart';
import 'modules/products/presentation/screens/product_screens.dart';
import 'modules/products/presentation/providers/popular_products_provider.dart';
import 'modules/sales/presentation/providers/cart_provider.dart';
import 'modules/notifications/notifications.dart';
import 'modules/dashboard/presentation/providers/dashboard_providers.dart';
import 'core/network/socket_service.dart';
import 'core/providers/language_provider.dart';

class DokanErpApp extends StatelessWidget {
  const DokanErpApp({super.key, this.overrides = const <Override>[]});

  final List<Override> overrides;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        ...appDependencyOverrides,
        ...overrides,
      ],
      child: const _AppBootstrap(),
    );
  }
}

class _AppBootstrap extends ConsumerWidget {
  const _AppBootstrap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    final flow = ref.watch(dokanAppFlowProvider);
    ref.read(dokanInventoryCatalogProvider);
    ref.read(dokanPosProvider);
    final inventoryReady = ref.watch(dokanInventoryCatalogReadyProvider);
    final salesHistoryReady = ref.watch(dokanSalesHistoryReadyProvider);

    if (!flow.roleReady || !inventoryReady || !salesHistoryReady) {
      debugPrint(
          '[BOOTSTRAP] flow.roleReady: ${flow.roleReady}, inventoryReady: $inventoryReady, salesHistoryReady: $salesHistoryReady');
      return const Directionality(
        textDirection: TextDirection.ltr,
        child: DokanSplashScreen(progress: 0),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: AppTheme.darkTheme,
      builder: (context, child) {
        return Consumer(
          builder: (context, ref, _) {
            final activeRequests =
                ref.watch(apiActivityCountProvider).valueOrNull ?? 0;
            return DokanApiLoaderOverlay(
              loading: activeRequests > 0,
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
      home: const _AppRoot(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}

class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot();

  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  bool _socketInitialized = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..addListener(() {
        ref.read(dokanAppFlowProvider.notifier).setProgress(
              (_progressController.value * 100).round(),
            );
      });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(dokanAppFlowProvider.notifier).startSplash();
      _progressController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(dokanAppFlowProvider);

    if (!_socketInitialized && flow.shopId.isNotEmpty) {
      _socketInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(apiConfiguredProvider)) {
          dokanNotificationAttachRemote(
            ref.read(notificationRepositoryProvider),
          );
        }
        ref.read(socketServiceProvider).connect(
              shopId: flow.shopId,
              onNewNotification: (data) {
                Future.microtask(() {
                  addIncomingNotificationToStore(data);

                  final type = data['type'] ?? '';
                  if (type == 'SALE') {
                    ref.invalidate(salesHistoryOrdersProvider);
                    ref.invalidate(dashboardSummaryProvider);
                    ref.invalidate(salesmanDashboardSummaryProvider);
                    ref.invalidate(dokanInventoryCatalogProvider);
                    return;
                  }

                  final title = data['title'] ?? 'নতুন নোটিফিকেশন';
                  final message = data['message'] ?? '';

                  _showNotificationSnackBar('$title', '$message');
                });
              },
            );
      });
    }

    ref.listen<String>(
      dokanAppFlowProvider.select((s) => s.shopId),
      (prev, next) {
        if (next.isNotEmpty) {
          if (ref.read(apiConfiguredProvider)) {
            dokanNotificationAttachRemote(
              ref.read(notificationRepositoryProvider),
            );
          }
          ref.read(socketServiceProvider).connect(
                shopId: next,
                onNewNotification: (data) {
                  Future.microtask(() {
                    addIncomingNotificationToStore(data);

                    final type = data['type'] ?? '';
                    if (type == 'SALE') {
                      ref.invalidate(salesHistoryOrdersProvider);
                      ref.invalidate(dashboardSummaryProvider);
                      ref.invalidate(salesmanDashboardSummaryProvider);
                      ref.invalidate(dokanInventoryCatalogProvider);
                      return;
                    }

                    final rawTitle = data['title'] ?? 'নতুন নোটিফিকেশন';
                    final rawMessage = data['message'] ?? '';
                    final title = tr(
                        rawTitle,
                        rawTitle == 'নতুন নোটিফিকেশন'
                            ? 'New Notification'
                            : rawTitle);
                    final message = tr(rawMessage, rawMessage);

                    _showNotificationSnackBar(title, message);
                  });
                },
              );
        } else {
          ref.read(socketServiceProvider).disconnect();
        }
      },
    );

    return AppRoutes.getWidgetForStage(context, ref, flow);
  }

  void _showNotificationSnackBar(String title, String message) {
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    const duration = Duration(seconds: 2);

    scaffoldMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (message.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ],
          ),
          backgroundColor: const Color(0xFF00694C),
          behavior: SnackBarBehavior.floating,
          duration: duration,
          action: ref.read(dokanAppFlowProvider).currentUserRole == 0
              ? SnackBarAction(
                  label: 'দেখুন',
                  textColor: Colors.amber,
                  onPressed: () {
                    scaffoldMessenger.hideCurrentSnackBar();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DokanNotificationCenterScreen(),
                      ),
                    );
                  },
                )
              : null,
        ),
      );

    Future<void>.delayed(duration, () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }
}
