import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dokan_erp/core/security/dokan_access_control.dart';
import '../../domain/entities/dokan_role.dart';
import 'auth_dependencies.dart';
import '../../../settings/domain/entities/business_settings.dart';
import '../../../settings/presentation/providers/business_settings_provider.dart';
import '../../../../data/network/api_providers.dart';

enum DokanStartupStage {
  splash,
  onboarding,
  login,
  otpLogin,
  otpVerify,
  pinSetup,
  pinLogin,
  register,
  shopSetup,
  inventoryModeSetup,
  welcome,
  popularProducts,
  home,
}

class DokanAppFlowState {
  DokanRole get currentRole => currentUserRole.toDokanRole();
  bool get isOwner => currentRole == DokanRole.owner;
  bool get isSalesman => currentRole == DokanRole.salesman;
  bool get roleReady => initialized;

  const DokanAppFlowState({
    this.stage = DokanStartupStage.splash,
    this.progress = 0,
    this.initialized = false,
    this.hasSession = false,
    this.loginRole = 0,
    this.shopName = 'দোকান',
    this.registeredName = 'আপনার',
    this.isNewAccountFlow = false,
    this.currentUserRole = 0,
    this.currentSalesmanPhone,
    this.currentSalesmanName,
    this.ownerPhone = '01712345678',
    this.ownerPassword = '1234',
    this.shopId = '',
    this.shopCode = '',
    this.pendingOtpPhone,
    this.permissions = const {
      'canSell': true,
      'canViewStock': true,
      'canViewReports': true,
      'canChangePrice': true,
      'canCollectDue': true,
    },
    this.isSubscriptionBlocked = false,
  });

  final DokanStartupStage stage;
  final int progress;
  final bool initialized;
  final bool hasSession;
  final int loginRole;
  final String shopName;
  final String registeredName;
  final bool isNewAccountFlow;
  final int currentUserRole;
  final String? currentSalesmanPhone;
  final String? currentSalesmanName;
  final String ownerPhone;
  final String ownerPassword;
  final String shopId;
  final String shopCode;
  final String? pendingOtpPhone;
  final Map<String, bool> permissions;
  final bool isSubscriptionBlocked;

  bool can(DokanPermission permission) {
    if (isOwner) return true;
    if (!roleReady || !isSalesman) return true;
    switch (permission) {
      case DokanPermission.salesCreate:
        return permissions['canSell'] ?? false;
      case DokanPermission.stockView:
      case DokanPermission.stockAdjust:
        return permissions['canViewStock'] ?? false;
      case DokanPermission.reportsView:
        return permissions['canViewReports'] ?? false;
      case DokanPermission.settingsManage:
        return permissions['canChangePrice'] ?? false;
      case DokanPermission.salesManage:
        return permissions['canCollectDue'] ?? false;
      default:
        return true;
    }
  }

  DokanAppFlowState copyWith({
    DokanStartupStage? stage,
    int? progress,
    bool? initialized,
    bool? hasSession,
    int? loginRole,
    String? shopName,
    String? registeredName,
    bool? isNewAccountFlow,
    int? currentUserRole,
    String? currentSalesmanPhone,
    String? currentSalesmanName,
    String? ownerPhone,
    String? ownerPassword,
    String? shopId,
    String? shopCode,
    String? pendingOtpPhone,
    Map<String, bool>? permissions,
    bool? isSubscriptionBlocked,
  }) {
    return DokanAppFlowState(
      stage: stage ?? this.stage,
      progress: progress ?? this.progress,
      initialized: initialized ?? this.initialized,
      hasSession: hasSession ?? this.hasSession,
      loginRole: loginRole ?? this.loginRole,
      shopName: shopName ?? this.shopName,
      registeredName: registeredName ?? this.registeredName,
      isNewAccountFlow: isNewAccountFlow ?? this.isNewAccountFlow,
      currentUserRole: currentUserRole ?? this.currentUserRole,
      currentSalesmanPhone: currentSalesmanPhone ?? this.currentSalesmanPhone,
      currentSalesmanName: currentSalesmanName ?? this.currentSalesmanName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerPassword: ownerPassword ?? this.ownerPassword,
      shopId: shopId ?? this.shopId,
      shopCode: shopCode ?? this.shopCode,
      pendingOtpPhone: pendingOtpPhone ?? this.pendingOtpPhone,
      permissions: permissions ?? this.permissions,
      isSubscriptionBlocked: isSubscriptionBlocked ?? this.isSubscriptionBlocked,
    );
  }
}

class DokanAppFlowNotifier extends Notifier<DokanAppFlowState> {
  Timer? _transitionTimer;

  @override
  DokanAppFlowState build() {
    ref.onDispose(() => _transitionTimer?.cancel());

    Future.microtask(() async {
      try {
        ref.read(authSessionRepositoryProvider);
        final session =
            await ref.read(authSessionRepositoryProvider).loadSession();
        state = state.copyWith(
          initialized: true,
          hasSession: session.hasSession,
          currentUserRole: session.roleIndex,
          currentSalesmanPhone: session.salesmanPhone,
          currentSalesmanName: session.salesmanName,
          ownerPhone: session.ownerPhone,
          ownerPassword: session.ownerPassword,
          shopId: session.shopId,
          shopName: session.shopName,
          registeredName: session.registeredName,
          shopCode: session.shopCode,
          permissions: session.permissions,
        );
      } catch (e) {
        // Keep error logs for safety, but in production formatting if needed
      }
    });

    return const DokanAppFlowState();
  }

  Future<void> _persistStage(DokanStartupStage stage) async {
    await ref.read(authSessionRepositoryProvider).saveStartupStage(stage.name);
  }

  void _setStage(DokanStartupStage stage) {
    state = state.copyWith(
      stage: stage,
      progress: stage == DokanStartupStage.splash ? state.progress : 100,
    );
    unawaited(_persistStage(stage));
  }

  void setProgress(int progress) {
    state = state.copyWith(progress: progress);
  }

  void startSplash() {
    _transitionTimer?.cancel();
    _transitionTimer = Timer(const Duration(milliseconds: 2300), () {
      if (state.hasSession) {
        _setStage(DokanStartupStage.home);
      } else {
        _setStage(DokanStartupStage.onboarding);
      }
    });

    state = state.copyWith(
      stage: DokanStartupStage.splash,
      progress: 0,
    );
  }

  void finishOnboarding() => _setStage(DokanStartupStage.login);
  void goToOnboarding() => _setStage(DokanStartupStage.onboarding);

  void goToLogin() {
    state = state.copyWith(isNewAccountFlow: false);
    _setStage(DokanStartupStage.login);
  }

  void setLoginRole(int roleIndex) {
    state = state.copyWith(loginRole: roleIndex);
  }

  void goToOtpLogin() => _setStage(DokanStartupStage.otpLogin);

  Future<void> sendLoginOtp(String phone) async {
    await ref.read(authGatewayProvider)?.sendOtp(phone);
    state = state.copyWith(pendingOtpPhone: phone);
    _setStage(DokanStartupStage.otpVerify);
  }

  Future<void> verifyOtp(String code) async {
    final gateway = ref.read(authGatewayProvider);
    final phone = state.pendingOtpPhone ?? state.ownerPhone;
    if (gateway != null) {
      final user = await gateway.verifyOtp(phone: phone, code: code);
      state = state.copyWith(
        currentUserRole: user.role.index,
        registeredName: user.name?.trim().isNotEmpty == true
            ? user.name
            : state.registeredName,
        shopName: user.shopName?.trim().isNotEmpty == true
            ? user.shopName
            : state.shopName,
        shopId:
            user.shopId?.trim().isNotEmpty == true ? user.shopId : state.shopId,
      );
    }
    _setStage(DokanStartupStage.pinSetup);
  }

  void goToOtpVerify() => _setStage(DokanStartupStage.otpVerify);
  void goToPinSetup() => _setStage(DokanStartupStage.pinSetup);
  void goToPinLogin() => _setStage(DokanStartupStage.pinLogin);

  void goToRegister() {
    state = state.copyWith(isNewAccountFlow: true);
    _setStage(DokanStartupStage.register);
  }

  Future<void> registerAccount({
    required String name,
    required String phone,
    required String password,
  }) async {
    final gateway = ref.read(authGatewayProvider);
    if (gateway != null) {
      await gateway.checkMobile(phone);
    }

    state = state.copyWith(
      registeredName: name,
      ownerPhone: phone,
      ownerPassword: password,
      isNewAccountFlow: true,
    );
    await ref.read(authSessionRepositoryProvider).saveOwner(
          name: name,
          phone: phone,
          password: password,
        );
    _setStage(DokanStartupStage.shopSetup);
  }

  Future<void> completeShopSetup(StoreDetails details) async {
    final gateway = ref.read(authGatewayProvider);
    var registeredShopId = state.shopId;
    var registeredShopName = details.storeName;
    if (gateway != null) {
      final user = await gateway.register(
        name: state.registeredName,
        phone: state.ownerPhone,
        password: state.ownerPassword,
        shopName: details.storeName,
        shopAddress: details.address,
        shopCategory: details.storeType,
        shopLocation: details.liveLocation,
        tradeLicenseNo: details.tradeLicenseNo,
        tinNo: details.tinNo,
        binNo: details.binNo,
        latitude: details.latitude,
        longitude: details.longitude,
      );
      if (user.shopId?.trim().isNotEmpty == true) {
        registeredShopId = user.shopId!.trim();
      }
      if (user.shopName?.trim().isNotEmpty == true) {
        registeredShopName = user.shopName!.trim();
      }
    }
    state = state.copyWith(
      shopId: registeredShopId,
      shopName: registeredShopName,
    );
    try {
      await ref.read(businessSettingsRepositoryProvider).saveStoreDetails(
            details.copyWith(
              storeName: registeredShopName,
              ownerName: state.registeredName,
              mobile: state.ownerPhone,
            ),
          );
    } catch (_) {
      // Ignored: Remote saving might fail since the user is not authenticated yet.
      // The local database was still updated, and the remote details were already
      // saved on registration.
    }
    await ref.read(authSessionRepositoryProvider).saveShopIdentity(
          shopId: registeredShopId,
          shopName: registeredShopName,
        );

    await ref.read(authGatewayProvider)?.sendOtp(state.ownerPhone);
    state = state.copyWith(pendingOtpPhone: state.ownerPhone);
    _setStage(DokanStartupStage.otpVerify);
  }

  Future<void> completePinLogin() async {
    await loginUser(
      role: state.currentUserRole,
      shopId: state.shopId,
      shopName: state.shopName,
    );
    if (state.isNewAccountFlow) {
      _setStage(DokanStartupStage.inventoryModeSetup);
      return;
    }
    _setStage(DokanStartupStage.home);
  }

  Future<void> loginUser({
    required int role,
    String? salesmanPhone,
    String? salesmanName,
    String? shopId,
    String? shopName,
    String? shopCode,
    Map<String, bool> permissions = const {
      'canSell': true,
      'canViewStock': true,
      'canViewReports': true,
      'canChangePrice': true,
      'canCollectDue': true,
    },
  }) async {
    await ref.read(authSessionRepositoryProvider).saveUser(
          role: role,
          salesmanPhone: salesmanPhone,
          salesmanName: salesmanName,
          shopId: shopId,
          shopName: shopName,
          shopCode: shopCode,
          permissions: permissions,
        );
    state = state.copyWith(
      stage: DokanStartupStage.home,
      progress: 100,
      loginRole: role,
      currentUserRole: role,
      currentSalesmanPhone: salesmanPhone,
      currentSalesmanName: salesmanName,
      shopId: shopId ?? state.shopId,
      shopName: shopName ?? state.shopName,
      shopCode: shopCode ?? state.shopCode,
      hasSession: true,
      permissions: permissions,
    );
    unawaited(_persistStage(DokanStartupStage.home));
  }

  Future<void> updatePermissions(Map<String, bool> permissions) async {
    await ref.read(authSessionRepositoryProvider).saveUser(
          role: state.currentUserRole,
          salesmanPhone: state.currentSalesmanPhone,
          salesmanName: state.currentSalesmanName,
          shopId: state.shopId,
          shopName: state.shopName,
          shopCode: state.shopCode,
          permissions: permissions,
        );
    state = state.copyWith(permissions: permissions);
  }

  Future<void> refreshPermissions() async {
    if (!state.isSalesman || state.shopId.isEmpty) return;
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get('/app/api/auth/me');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final permissionsMap = data['permissions'] is Map
            ? (data['permissions'] as Map).map((k, v) => MapEntry('$k', v == true))
            : const <String, bool>{};

        final permissions = <String, bool>{
          'canSell': permissionsMap['canSell'] ?? true,
          'canViewStock': permissionsMap['canViewStock'] ?? true,
          'canViewReports': permissionsMap['canViewReports'] ?? true,
          'canChangePrice': permissionsMap['canChangePrice'] ?? true,
          'canCollectDue': permissionsMap['canCollectDue'] ?? true,
        };

        await updatePermissions(permissions);
      }
    } catch (_) {}
  }

  Future<bool> verifyOwnerPassword(String password) {
    return ref
        .read(authSessionRepositoryProvider)
        .verifyOwnerPassword(password);
  }

  void setSubscriptionBlocked(bool blocked) {
    if (state.isSubscriptionBlocked != blocked) {
      state = state.copyWith(isSubscriptionBlocked: blocked);
    }
  }

  Future<void> logout() async {
    final previousRole = state.currentUserRole;
    try {
      await ref.read(authGatewayProvider)?.logout();
    } catch (_) {
      // Ignore network/auth errors during remote logout so we always clear local state
    } finally {
      await ref.read(authSessionRepositoryProvider).clearUser();
    }

    state = state.copyWith(
      stage: DokanStartupStage.login,
      progress: 100,
      loginRole: previousRole,
      isNewAccountFlow: false,
      hasSession: false,
      currentUserRole: 0,
      currentSalesmanPhone: null,
      currentSalesmanName: null,
      isSubscriptionBlocked: false,
      shopId: '',
      shopName: 'দোকান',
      shopCode: '',
    );
    unawaited(_persistStage(DokanStartupStage.login));
  }

  void goToWelcome() => _setStage(DokanStartupStage.welcome);
  void goToInventoryModeSetup() =>
      _setStage(DokanStartupStage.inventoryModeSetup);
  void goToHome() => _setStage(DokanStartupStage.home);
  void goToPopularProducts() => _setStage(DokanStartupStage.popularProducts);
}

final dokanAppFlowProvider =
    NotifierProvider<DokanAppFlowNotifier, DokanAppFlowState>(
  DokanAppFlowNotifier.new,
);
