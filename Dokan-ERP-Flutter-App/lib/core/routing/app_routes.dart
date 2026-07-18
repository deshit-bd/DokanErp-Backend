import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/auth/presentation/providers/app_flow_provider.dart';
import '../../modules/auth/presentation/screens/auth_screens.dart';
import '../../modules/auth/presentation/screens/onboarding_screen.dart';
import '../../modules/auth/presentation/screens/splash_screen.dart';
import '../../modules/auth/presentation/widgets/dokan_phone_shell.dart';
import '../../modules/dashboard/presentation/screens/dashboard_screen.dart';
import '../../modules/products/presentation/screens/product_screens.dart';
import '../../modules/products/presentation/providers/product_dependencies.dart';
import '../../modules/products/presentation/providers/popular_products_provider.dart';
import '../../modules/salesman/presentation/screens/salesman_dashboard_screen.dart';
import '../../modules/sales/presentation/providers/cart_provider.dart';
import '../../modules/settings/presentation/providers/subscription_provider.dart';
import '../../modules/settings/presentation/screens/settings_screens.dart';
import '../../modules/reports/presentation/screens/reports_screens.dart';
import '../../modules/sales/presentation/screens/sales_screens.dart';
import '../../modules/sales/presentation/screens/salesman_sales_screen.dart';
import '../../modules/settings/domain/entities/subscription_info.dart';
import '../../data/network/api_providers.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const products = '/products';
  static const sales = '/sales';
  static const reports = '/reports';
  static const settings = '/settings';

  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (_) => const DokanSplashScreen(progress: 100),
        );
      case onboarding:
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (_) => OnboardingFlow(onFinished: () {}),
        );
      case login:
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (_) => DokanLoginScreen(
            onBack: () {},
            onLogin: () {},
            onOtpLogin: () {},
            onAccountOpen: () {},
          ),
        );
      case dashboard:
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (_) => const DokanHomeDashboardScreen(),
        );
      case products:
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (_) => const DokanProductListScreen(),
        );
      case sales:
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (_) => const SalesRouteGuard(),
        );
      case reports:
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (_) => const DokanReportsHomeScreen(),
        );
      case settings:
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (_) => const DokanAroOptionScreen(),
        );
      default:
        return null;
    }
  }

  static Widget getWidgetForStage(
      BuildContext context, WidgetRef ref, DokanAppFlowState flow) {
    final flowController = ref.read(dokanAppFlowProvider.notifier);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: switch (flow.stage) {
        DokanStartupStage.splash => DokanPhoneShell(
            key: const ValueKey('splash'),
            child: DokanSplashScreen(progress: flow.progress),
          ),
        DokanStartupStage.onboarding => DokanPhoneShell(
            key: const ValueKey('onboarding'),
            child: OnboardingFlow(onFinished: flowController.finishOnboarding),
          ),
        DokanStartupStage.login => DokanPhoneShell(
            key: const ValueKey('login'),
            child: DokanLoginScreen(
              onBack: flowController.goToOnboarding,
              onLogin: flowController.goToHome,
              onOtpLogin: flowController.goToOtpLogin,
              onAccountOpen: flowController.goToRegister,
              initialRole: flow.loginRole,
              onRoleChanged: flowController.setLoginRole,
            ),
          ),
        DokanStartupStage.otpLogin => DokanPhoneShell(
            key: const ValueKey('otpLogin'),
            child: DokanOtpLoginScreen(
              onBack: flowController.goToLogin,
              onSendOtp: flowController.sendLoginOtp,
            ),
          ),
        DokanStartupStage.otpVerify => DokanPhoneShell(
            key: const ValueKey('otpVerify'),
            child: DokanOtpVerificationScreen(
              onBack: flowController.goToOtpLogin,
              onVerified: flowController.verifyOtp,
            ),
          ),
        DokanStartupStage.pinSetup => DokanPhoneShell(
            key: const ValueKey('pinSetup'),
            child: DokanPinSetupScreen(
              onBack: flowController.goToOtpVerify,
              onContinue: flowController.goToPinLogin,
            ),
          ),
        DokanStartupStage.pinLogin => DokanPhoneShell(
            key: const ValueKey('pinLogin'),
            child: DokanPinLoginScreen(
              onBack: flowController.goToPinSetup,
              onLogin: flowController.completePinLogin,
            ),
          ),
        DokanStartupStage.register => DokanPhoneShell(
            key: const ValueKey('register'),
            child: DokanRegisterScreen(
              onBack: flowController.goToLogin,
              onContinue: (name, phone, password) {
                return flowController.registerAccount(
                  name: name,
                  phone: phone,
                  password: password,
                );
              },
            ),
          ),
        DokanStartupStage.shopSetup => DokanPhoneShell(
            key: const ValueKey('shopSetup'),
            child: DokanShopSetupScreen(
              onBack: flowController.goToRegister,
              onContinue: flowController.completeShopSetup,
            ),
          ),
        DokanStartupStage.inventoryModeSetup => DokanPhoneShell(
            key: const ValueKey('inventoryModeSetup'),
            child: DokanInventoryModeSelectionScreen(
              showBackButton: false,
              oneTimeSetup: true,
              onCompleted: flowController.goToWelcome,
            ),
          ),
        DokanStartupStage.welcome => DokanPhoneShell(
            key: const ValueKey('welcome'),
            child: Builder(
              builder: (context) {
                Future<void> openInventoryModeThen(VoidCallback nextStep) async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (routeContext) =>
                          DokanInventoryModeSelectionScreen(
                        showBackButton: true,
                        oneTimeSetup: false,
                        onCompleted: () {
                          Navigator.of(routeContext).pop();
                          nextStep();
                        },
                      ),
                    ),
                  );
                }

                return DokanWelcomeScreen(
                  accountName: flow.registeredName,
                  onPopularProducts: () {
                    openInventoryModeThen(flowController.goToPopularProducts);
                  },
                  onManualAddProduct: () {
                    openInventoryModeThen(() {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DokanAddProductMasterDbScreen(),
                        ),
                      );
                    });
                  },
                  onStartSelling: () {
                    openInventoryModeThen(flowController.goToHome);
                  },
                );
              },
            ),
          ),
        DokanStartupStage.popularProducts => DokanPhoneShell(
            key: const ValueKey('popularProducts'),
            child: DokanPopularProductsScreen(
              shopName: flow.shopName,
              ownerName: flow.registeredName,
              onBack: flowController.goToWelcome,
              onContinue: () async {
                await ref
                    .read(dokanInventoryCatalogProvider.notifier)
                    .refreshFromRepository();
                flowController.goToHome();
              },
            ),
          ),
        DokanStartupStage.home => flow.hasSession
            ? (flow.isSubscriptionBlocked
                ? (flow.isSalesman
                    ? const KeyedSubtree(
                        key: ValueKey('blockedSalesman'),
                        child: SalesmanBlockedScreen(),
                      )
                    : const KeyedSubtree(
                        key: ValueKey('subscriptionBlocked'),
                        child: DokanNotificationSubscriptionSettingsScreen(lockedMode: true),
                      ))
                : (flow.isSalesman
                    ? const KeyedSubtree(
                        key: ValueKey('dashboardSalesman'),
                        child: DokanSalesmanDashboardScreen(),
                      )
                    : const KeyedSubtree(
                        key: ValueKey('dashboardOwner'),
                        child: OwnerSubscriptionGate(),
                      )))
            : DokanLoginScreen(
                key: const ValueKey('loginNoSession'),
                onBack: flowController.goToOnboarding,
                onLogin: flowController.goToHome,
                onOtpLogin: flowController.goToOtpLogin,
                onAccountOpen: flowController.goToRegister,
                initialRole: flow.loginRole,
                onRoleChanged: flowController.setLoginRole,
              ),
      },
    );
  }
}

class SalesRouteGuard extends ConsumerWidget {
  const SalesRouteGuard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(dokanAppFlowProvider);
    return flow.isSalesman
        ? const SalesmanSalesScreen()
        : const DokanPosMainScreen();
  }
}

class OwnerSubscriptionGate extends ConsumerWidget {
  const OwnerSubscriptionGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasActiveApiSession = ref.watch(hasActiveApiSessionProvider);

    return hasActiveApiSession.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF4F7FB),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0E8F5F)),
        ),
      ),
      error: (_, __) {
        Future.microtask(() async {
          await ref.read(dokanAppFlowProvider.notifier).logout();
        });
        return const Scaffold(
          backgroundColor: Color(0xFFF4F7FB),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF0E8F5F)),
          ),
        );
      },
      data: (hasSession) {
        if (!hasSession) {
          Future.microtask(() async {
            await ref.read(dokanAppFlowProvider.notifier).logout();
          });
          return const Scaffold(
            backgroundColor: Color(0xFFF4F7FB),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF0E8F5F)),
            ),
          );
        }

        final subscriptionInfo = ref.watch(subscriptionInfoProvider);

        return subscriptionInfo.when(
          loading: () => const Scaffold(
            backgroundColor: Color(0xFFF4F7FB),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF0E8F5F)),
            ),
          ),
          error: (error, stack) => Scaffold(
            backgroundColor: const Color(0xFFF4F7FB),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFE15241),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'সাবস্ক্রিপশন অবস্থা যাচাই করা যায়নি।',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF16302E),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF6F8280),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () {
                        ref.invalidate(hasActiveApiSessionProvider);
                        ref.invalidate(subscriptionInfoProvider);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0E8F5F),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('আবার চেষ্টা করুন'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          ref.read(dokanAppFlowProvider.notifier).logout(),
                      child: const Text('লগআউট'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          data: (info) {
            if (info.allowed) {
              Future.microtask(() {
                ref.read(dokanAppFlowProvider.notifier).setSubscriptionBlocked(false);
              });
              return const DokanHomeDashboardScreen();
            } else {
              Future.microtask(() {
                ref.read(dokanAppFlowProvider.notifier).setSubscriptionBlocked(true);
              });
              return const DokanNotificationSubscriptionSettingsScreen(
                lockedMode: true,
              );
            }
          },
        );
      },
    );
  }
}

class SalesmanBlockedScreen extends ConsumerWidget {
  const SalesmanBlockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_clock_rounded,
                color: Color(0xFFE15241),
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'দোকানের সাবস্ক্রিপশন মেয়াদ শেষ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF16302E),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'আপনার দোকানের সাবস্ক্রিপশন ফি পরিশোধ করার মেয়াদ শেষ হয়ে গেছে। অনুগ্রহ করে দোকান মালিকের সাথে যোগাযোগ করে বকেয়া পরিশোধ করতে বলুন।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6F8280),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () async {
                  try {
                    final client = ref.read(apiClientProvider);
                    await client.get('/app/api/auth/me');
                    ref.read(dokanAppFlowProvider.notifier).setSubscriptionBlocked(false);
                  } catch (_) {}
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('আবার চেষ্টা করুন'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0E8F5F),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 48),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => ref.read(dokanAppFlowProvider.notifier).logout(),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('লগআউট'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE15241),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
