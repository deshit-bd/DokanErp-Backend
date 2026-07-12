part of '../auth_screens.dart';

class DokanShopSetupScreen extends StatefulWidget {
  const DokanShopSetupScreen({
    super.key,
    this.onBack,
    this.onContinue,
  });

  final VoidCallback? onBack;
  final Future<void> Function(StoreDetails details)? onContinue;

  @override
  State<DokanShopSetupScreen> createState() => _DokanShopSetupScreenState();
}

class _DokanShopSetupScreenState extends State<DokanShopSetupScreen> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _tradeLicenseController = TextEditingController();
  final TextEditingController _tinController = TextEditingController();
  final TextEditingController _binController = TextEditingController();
  String? _category;
  double? _latitude;
  double? _longitude;
  bool _capturingLocation = false;

  void _tryParseLocation(String text) {
    try {
      final parts = text.split(',');
      if (parts.length == 2) {
        final latStr = parts[0].replaceAll(RegExp(r'[^0-9.-]'), '');
        final lngStr = parts[1].replaceAll(RegExp(r'[^0-9.-]'), '');
        final lat = double.tryParse(latStr);
        final lng = double.tryParse(lngStr);
        if (lat != null && lng != null) {
          setState(() {
            _latitude = lat;
            _longitude = lng;
          });
        }
      }
    } catch (_) {}
  }

  static const List<String> _categories = [
    'মুদি',
    'কসমেটিক',
    'ফার্মেসি',
    'স্টেশনারি',
    'ইলেকট্রনিক্স',
  ];

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _tradeLicenseController.dispose();
    _tinController.dispose();
    _binController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final details = StoreDetails(
      storeName: _shopNameController.text.trim(),
      address: _addressController.text.trim(),
      storeType: _category ?? '',
      tradeLicenseNo: _tradeLicenseController.text.trim(),
      tinNo: _tinController.text.trim(),
      binNo: _binController.text.trim(),
      liveLocation: _locationController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
    );

    if (details.storeName.isEmpty) {
      _showWarning(context, 'দোকানের নাম দিতে হবে।');
      return;
    }
    if (details.address.isEmpty) {
      _showWarning(context, 'ঠিকানা দিতে হবে।');
      return;
    }
    if (_category == null) {
      _showWarning(context, 'ক্যাটাগরি নির্বাচন করুন।');
      return;
    }
    if (details.liveLocation.isEmpty) {
      _showWarning(context, 'লোকেশন দিতে হবে।');
      return;
    }

    try {
      await widget.onContinue?.call(details);
    } on NetworkException catch (error) {
      if (mounted) _showWarning(context, error.message);
    } catch (_) {
      if (mounted) _showWarning(context, 'Shop setup failed. Try again.');
    }
  }

  Future<void> _captureCurrentLocation() async {
    if (_capturingLocation) return;
    setState(() => _capturingLocation = true);
    try {
      final result = await StoreLocationCapture.capture();
      if (!mounted) return;
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        _locationController.text = result.label;
      });
    } on StoreLocationException catch (error) {
      if (mounted) _showWarning(context, error.message);
    } catch (_) {
      if (mounted)
        _showWarning(context, 'লাইভ লোকেশন আনা যায়নি। আবার চেষ্টা করুন।');
    } finally {
      if (mounted) setState(() => _capturingLocation = false);
    }
  }

  Future<void> _pickDocument(TextEditingController controller) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }
    setState(() {
      controller.text = result.files.single.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _FlowScreen(
      onBack: widget.onBack,
      accent: const Color(0xFF0E8B69),
      background: const Color(0xFFF1FBFF),
      title: 'দোকান সেটআপ',
      subtitle:
          'দোকানের নাম, ঠিকানা, ক্যাটাগরি, ট্রেড লাইসেন্স, TIN, BIN এবং লাইভ লোকেশন সেট করুন।',
      icon: Icons.location_city_outlined,
      primaryLabel: 'সেটআপ শেষ করুন',
      onPrimary: _continue,
      children: [
        _FlowInputField(
          label: 'দোকানের নাম',
          hintText: 'আপনার দোকানের নাম',
          icon: Icons.storefront_outlined,
          controller: _shopNameController,
        ),
        const SizedBox(height: 16),
        _FlowInputField(
          label: 'ঠিকানা',
          hintText: 'দোকানের ঠিকানা লিখুন',
          icon: Icons.location_on_outlined,
          controller: _addressController,
        ),
        const SizedBox(height: 16),
        _FlowDocumentField(
          label: 'ট্রেড লাইসেন্স ডকুমেন্ট (ঐচ্ছিক)',
          icon: Icons.badge_outlined,
          value: _tradeLicenseController.text,
          onPick: () => _pickDocument(_tradeLicenseController),
        ),
        const SizedBox(height: 16),
        _FlowDocumentField(
          label: 'TIN ডকুমেন্ট (ঐচ্ছিক)',
          icon: Icons.confirmation_number_outlined,
          value: _tinController.text,
          onPick: () => _pickDocument(_tinController),
        ),
        const SizedBox(height: 16),
        _FlowDocumentField(
          label: 'BIN ডকুমেন্ট (ঐচ্ছিক)',
          icon: Icons.receipt_long_outlined,
          value: _binController.text,
          onPick: () => _pickDocument(_binController),
        ),
        const SizedBox(height: 16),
        _CategoryPicker(
          value: _category,
          items: _categories,
          onChanged: (value) => setState(() => _category = value),
        ),
        const SizedBox(height: 16),
        _FlowInputField(
          label: 'লোকেশন',
          hintText: 'মানচিত্র লোকেশন',
          icon: Icons.my_location_rounded,
          controller: _locationController,
          onChanged: (val) {
            setState(() {});
            _tryParseLocation(val);
          },
        ),
        if (_latitude != null && _longitude != null) ...[
          const SizedBox(height: 12),
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD6E4DE)),
            ),
            child: LocationPreviewMap(
              latitude: _latitude!,
              longitude: _longitude!,
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _capturingLocation ? null : _captureCurrentLocation,
            icon: Icon(
              _capturingLocation
                  ? Icons.hourglass_top_rounded
                  : Icons.gps_fixed_rounded,
            ),
            label: Text(
              _capturingLocation
                  ? 'লোকেশন আনা হচ্ছে...'
                  : 'বর্তমান লাইভ লোকেশন নিন',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0E8B69),
              side: const BorderSide(color: Color(0xFF0E8B69)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DokanWelcomeScreen extends StatelessWidget {
  const DokanWelcomeScreen({
    super.key,
    required this.accountName,
    this.onPopularProducts,
    this.onManualAddProduct,
    this.onStartSelling,
  });

  final String accountName;
  final VoidCallback? onPopularProducts;
  final VoidCallback? onManualAddProduct;
  final VoidCallback? onStartSelling;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FAF4),
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sheetTop = (constraints.maxHeight * 0.44).clamp(306.0, 348.0);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Color(0xFFF3FAF4)),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 50,
                  child: Center(
                    child: SizedBox(
                      width: 328,
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 276,
                            height: 276,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF7F0),
                              borderRadius: BorderRadius.circular(34),
                            ),
                          ),
                          Container(
                            width: 176,
                            height: 176,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCEDE4),
                              borderRadius: BorderRadius.circular(88),
                            ),
                          ),
                          Container(
                            width: 124,
                            height: 124,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E8B69),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF0E8B69).withOpacity(0.22),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 72,
                            ),
                          ),
                          Positioned(
                            left: 28,
                            top: 72,
                            child: _ConfettiMark(
                                color: Color(0xFF7ABEA7), size: 11),
                          ),
                          Positioned(
                            right: 48,
                            top: 54,
                            child: _ConfettiMark(
                                color: Color(0xFF2F8F73), size: 10),
                          ),
                          Positioned(
                            left: 82,
                            bottom: 32,
                            child: _ConfettiMark(
                                color: Color(0xFFFFB07A), size: 11),
                          ),
                          Positioned(
                            right: 74,
                            bottom: 58,
                            child: _ConfettiMark(
                                color: Color(0xFF7ABEA7), size: 9),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: sheetTop,
                  bottom: 0,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 32,
                          offset: Offset(0, -12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        'স্বাগতম, $accountName',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF131D21),
                                          height: 1.1,
                                          letterSpacing: -0.6,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'আপনার অ্যাকাউন্ট প্রস্তুত। এখন পরের ধাপগুলো শুরু করুন।',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 15,
                                          height: 1.45,
                                          color: Color(0xFF4A5A54),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _WelcomeActionTile(
                                  icon: Icons.storefront_rounded,
                                  title: 'পণ্যের ক্যাটালগ থেকে যোগ করুন',
                                  subtitle: 'ক্যাটালগ থেকে পণ্য বেছে যোগ করুন',
                                  badge: 'সহজ',
                                  onTap: onPopularProducts,
                                ),
                                const SizedBox(height: 14),
                                _WelcomeActionTile(
                                  icon: Icons.edit_note_rounded,
                                  title: 'নিজে পণ্য যোগ করুন',
                                  subtitle: 'ম্যানুয়ালি পণ্যের তথ্য দিন',
                                  onTap: onManualAddProduct,
                                ),
                                const SizedBox(height: 24),
                                if (onStartSelling != null) ...[
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: onStartSelling,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF0E8B69),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'ড্যাশবোর্ডে যান',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward_rounded,
                                              size: 22),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                ],
                                Text(
                                  'পরে সেটিংস থেকে আরও পণ্য যোগ করা যাবে',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
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
    );
  }
}

class _WelcomeActionTile extends StatelessWidget {
  const _WelcomeActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7ECE9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFE3EFE9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF00694C), size: 34),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C2C27),
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F2EE),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: Color(0xFF00694C),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Color(0xFF5B6A65),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF4F5A56),
            size: 30,
          ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: card,
      ),
    );
  }
}
