part of 'product_screens.dart';

class DokanBarcodeScannerScreen extends ConsumerStatefulWidget {
  const DokanBarcodeScannerScreen({super.key});

  @override
  ConsumerState<DokanBarcodeScannerScreen> createState() =>
      _DokanBarcodeScannerScreenState();
}

class _DokanBarcodeScannerScreenState
    extends ConsumerState<DokanBarcodeScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanLineController;

  bool _cameraReady = true;
  bool _cameraPermissionGranted = true;
  bool _handlingResult = false;
  bool _torchEnabled = false;
  String _statusText = 'কোড ফ্রেমের মধ্যে ধরুন';
  String? _errorText;
  DokanCatalogProduct? _resolvedProduct;
  DokanQrAction? _resolvedAction;
  String? _lastRejectedCode;

  @override
  void initState() {
    super.initState();
    ref.read(dokanLastScannedProductProvider.notifier).state = null;
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  Future<void> _closeScanner() async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _toggleTorch() async {
    if (!mounted) return;
    setState(() => _torchEnabled = !_torchEnabled);
  }

  Future<void> _handleCodeInput(String code) async {
    if (_handlingResult || _resolvedProduct != null) return;
    if (code.trim().isEmpty) return;

    final flow = ref.read(dokanAppFlowProvider);
    final scanService = ref.read(dokanScanServiceProvider);

    final result = scanService.resolve(code);
    debugPrint(
      '[SCAN] manually typed code="$code" normalized="${result.normalizedCode}" role=${flow.currentRole.name}',
    );

    if (!result.isResolved || result.product == null) {
      if (!mounted) return;
      if (_lastRejectedCode != result.normalizedCode) {
        setState(() {
          _lastRejectedCode = result.normalizedCode;
          _statusText = 'প্রোডাক্ট পাওয়া যায়নি';
          _errorText = 'এই কোডটি shared catalog-এ নেই';
        });
      }
      return;
    }

    _handlingResult = true;
    ref.read(dokanLastScannedProductProvider.notifier).state = result.product;

    final action = ref.read(dokanQrActionResolverProvider).resolve(
          flow.currentRole,
          result.product!,
        );

    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _resolvedProduct = result.product;
      _resolvedAction = action;
      _errorText = null;
      _statusText = action.description;
    });

    if (flow.isSalesman) {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      if (!mounted) return;
      ref.read(cartServiceProvider).addProduct(result.product!);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('${result.product!.name} কার্টে যোগ হয়েছে'),
            backgroundColor: const Color(0xFF0F766E),
            behavior: SnackBarBehavior.floating,
          ),
        );
      await Future<void>.delayed(const Duration(milliseconds: 180));
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _handlePrimaryAction() async {
    final product = _resolvedProduct;
    final action = _resolvedAction;
    if (product == null || action == null || _handlingResult) return;

    setState(() => _handlingResult = true);
    try {
      switch (action.type) {
        case DokanQrActionType.openInventory:
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DokanProductDetailScreen(product: product),
            ),
          );
          break;
        case DokanQrActionType.addToCart:
          ref.read(cartServiceProvider).addProduct(product);
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text('${product.name} কার্টে যোগ হয়েছে'),
                backgroundColor: const Color(0xFF0F766E),
                behavior: SnackBarBehavior.floating,
              ),
            );
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          break;
      }
    } finally {
      if (mounted) {
        setState(() => _handlingResult = false);
      }
    }
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: const Color(0xFF08111F),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF71F0B6),
            strokeWidth: 2.8,
          ),
          const SizedBox(height: 16),
          Text(
            _cameraReady ? 'স্ক্যানের জন্য প্রস্তুত' : 'ক্যামেরা চালু হচ্ছে...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay(DokanRole role) {
    final isOwner = role == DokanRole.owner;
    final accent = isOwner ? const Color(0xFF4ADE80) : const Color(0xFF71F0B6);
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF08111F).withValues(alpha: 0.68),
              const Color(0xFF08111F).withValues(alpha: 0.2),
              const Color(0xFF08111F).withValues(alpha: 0.72),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _ScannerIconButton(
                      icon: Icons.close_rounded,
                      onTap: _closeScanner,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOwner ? 'Owner scanner' : 'Salesman scanner',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Barcode বা QR code ফ্রেমের মধ্যে ধরুন',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _ScannerIconButton(
                      icon: _torchEnabled
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      onTap: _toggleTorch,
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: accent, width: 2.4),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _scanLineController,
                          builder: (context, child) {
                            final progress = _scanLineController.value;
                            return Stack(
                              children: [
                                Positioned(
                                  left: 20,
                                  right: 20,
                                  top: 20 + (progress * 260),
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(99),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accent.withValues(alpha: 0.35),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: _ScannerCorner(accent: accent, topLeft: true),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: _ScannerCorner(accent: accent, topLeft: false),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: _ScannerCorner(
                          accent: accent,
                          topLeft: false,
                          bottom: true,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: _ScannerCorner(
                          accent: accent,
                          topLeft: true,
                          bottom: true,
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _statusText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _errorText!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red.shade200,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              if (_resolvedProduct != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _resolvedProduct!.name,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'আইডি: ${_resolvedProduct!.productId}',
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _resolvedAction?.description ?? '',
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed:
                                _handlingResult ? null : _handlePrimaryAction,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF0F766E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              _resolvedAction?.buttonLabel ?? 'চালিয়ে যান',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else
                const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMockScannerView() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF08111F),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              const Icon(
                Icons.qr_code_2_rounded,
                size: 72,
                color: Color(0xFF71F0B6),
              ),
              const SizedBox(height: 16),
              const Text(
                'বারকোড / কিউআর কোড সিমুলেটর',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'সিমুলেটরের জন্য নিচে বারকোড লিখে সাবমিট করুন',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF102033),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF274060)),
                ),
                child: TextField(
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: 'বারকোড টাইপ করুন (যেমন: 1001, 1002)',
                    hintStyle: TextStyle(color: Colors.white30),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onSubmitted: _handleCodeInput,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(dokanAppFlowProvider).currentRole;

    return PopScope(
      canPop: true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: const Color(0xFF08111F),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFF08111F),
          body: SafeArea(
            child: Stack(
              children: [
                _buildMockScannerView(),
                _buildScannerOverlay(role),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScannerIconButton extends StatelessWidget {
  const _ScannerIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

class _ScannerCorner extends StatelessWidget {
  const _ScannerCorner({
    required this.accent,
    required this.topLeft,
    this.bottom = false,
  });

  final Color accent;
  final bool topLeft;
  final bool bottom;

  @override
  Widget build(BuildContext context) {
    final border = BorderSide(color: accent, width: 4);
    return SizedBox(
      width: 42,
      height: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: bottom ? BorderSide.none : border,
            left: topLeft ? border : BorderSide.none,
            right: topLeft ? BorderSide.none : border,
            bottom: bottom ? border : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
