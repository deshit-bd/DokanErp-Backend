part of '../settings_screens.dart';

class DokanStoreDetailsScreen extends ConsumerStatefulWidget {
  const DokanStoreDetailsScreen({super.key});

  @override
  ConsumerState<DokanStoreDetailsScreen> createState() =>
      _DokanStoreDetailsScreenState();
}

class _DokanStoreDetailsScreenState
    extends ConsumerState<DokanStoreDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _tradeLicenseController = TextEditingController();
  final _tinController = TextEditingController();
  final _binController = TextEditingController();
  final _liveLocationController = TextEditingController();
  String _storeType = 'মুদি দোকান';
  bool _saving = false;
  bool _capturingLocation = false;
  double? _latitude;
  double? _longitude;
  Uint8List? _logoBytes;
  String _logoFileName = '';
  String _logoUrl = '';
  String? _storeNameError;
  String? _ownerNameError;
  String? _mobileError;
  String? _addressError;

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

  static const List<String> _storeTypes = <String>[
    'মুদি দোকান',
    'সুপার শপ',
    'ফার্মেসি',
    'স্টেশনারি',
    'অন্যান্য',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final details = await ref.read(storeDetailsProvider.future);
      if (!mounted) return;
      final parsedLocation = _parseLocation(details.liveLocation);
      setState(() {
        _storeNameController.text = details.storeName;
        _ownerNameController.text = details.ownerName;
        _mobileController.text = details.mobile;
        _addressController.text = details.address;
        _tradeLicenseController.text = details.tradeLicenseNo;
        _tinController.text = details.tinNo;
        _binController.text = details.binNo;
        _liveLocationController.text = details.liveLocation;
        _latitude = details.latitude ?? parsedLocation?.$1;
        _longitude = details.longitude ?? parsedLocation?.$2;
        _logoFileName = details.logoFileName;
        _logoUrl = details.logoUrl;
        _logoBytes = details.logoBase64.trim().isEmpty
            ? null
            : base64Decode(details.logoBase64);
        final type = details.storeType.trim();
        if (_storeTypes.contains(type)) {
          _storeType = type;
        } else {
          _storeType = 'অন্যান্য';
        }
      });
    });
  }

  (double, double)? _parseLocation(String text) {
    try {
      final parts = text.split(',');
      if (parts.length != 2) {
        return null;
      }
      final latStr = parts[0].replaceAll(RegExp(r'[^0-9.-]'), '');
      final lngStr = parts[1].replaceAll(RegExp(r'[^0-9.-]'), '');
      final lat = double.tryParse(latStr);
      final lng = double.tryParse(lngStr);
      if (lat == null || lng == null) {
        return null;
      }
      return (lat, lng);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _tradeLicenseController.dispose();
    _tinController.dispose();
    _binController.dispose();
    _liveLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FB),
        surfaceTintColor: const Color(0xFFF4F7FB),
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: _saving ? null : () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF16302E),
            ),
          ),
        ),
        leadingWidth: 72,
        title: const Text(
          'দোকানের বিস্তারিত তথ্য',
          style: TextStyle(
            color: Color(0xFF16302E),
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth =
                constraints.maxWidth > 760 ? 760.0 : constraints.maxWidth;
            final bottomPadding = MediaQuery.viewInsetsOf(context).bottom + 24;
            return Form(
              key: _formKey,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _StoreLogoCard(
                                onTap: _pickLogo,
                                logoBytes: _logoBytes,
                                fileName: _logoFileName,
                                logoUrl: _logoUrl,
                              ),
                              const SizedBox(height: 14),
                              _StoreSettingsCard(
                                title: 'দোকানের তথ্য',
                                child: Column(
                                  children: [
                                    _StoreTextField(
                                      label: 'দোকানের নাম',
                                      controller: _storeNameController,
                                      errorText: _storeNameError,
                                      onChanged: (_) => setState(
                                          () => _storeNameError = null),
                                    ),
                                    const SizedBox(height: 12),
                                    _StoreDropdownField(
                                      label: 'দোকানের ধরন',
                                      value: _storeType,
                                      items: _storeTypes,
                                      onChanged: (value) => setState(() =>
                                          _storeType = value ?? _storeType),
                                    ),
                                    const SizedBox(height: 12),
                                    _StoreTextField(
                                      label: 'মালিকের নাম',
                                      controller: _ownerNameController,
                                      errorText: _ownerNameError,
                                      onChanged: (_) => setState(
                                          () => _ownerNameError = null),
                                    ),
                                    const SizedBox(height: 12),
                                    _StoreTextField(
                                      label: 'মোবাইল নম্বর',
                                      controller: _mobileController,
                                      keyboardType: TextInputType.phone,
                                      errorText: _mobileError,
                                      onChanged: (_) =>
                                          setState(() => _mobileError = null),
                                    ),
                                    const SizedBox(height: 12),
                                    _StoreTextField(
                                      label: 'ঠিকানা',
                                      controller: _addressController,
                                      maxLines: 3,
                                      errorText: _addressError,
                                      onChanged: (_) =>
                                          setState(() => _addressError = null),
                                    ),
                                    const SizedBox(height: 12),
                                    _StoreDocumentField(
                                      label: 'ট্রেড লাইসেন্স ডকুমেন্ট (ঐচ্ছিক)',
                                      value: _tradeLicenseController.text,
                                      onTap: () => _pickDocument(
                                          _tradeLicenseController),
                                    ),
                                    const SizedBox(height: 12),
                                    _StoreDocumentField(
                                      label: 'TIN ডকুমেন্ট (ঐচ্ছিক)',
                                      value: _tinController.text,
                                      onTap: () =>
                                          _pickDocument(_tinController),
                                    ),
                                    const SizedBox(height: 12),
                                    _StoreDocumentField(
                                      label: 'BIN ডকুমেন্ট (ঐচ্ছিক)',
                                      value: _binController.text,
                                      onTap: () =>
                                          _pickDocument(_binController),
                                    ),
                                    const SizedBox(height: 12),
                                    _StoreTextField(
                                      label: 'লাইভ লোকেশন',
                                      controller: _liveLocationController,
                                      maxLines: 2,
                                      onChanged: (val) {
                                        setState(() {});
                                        _tryParseLocation(val);
                                      },
                                    ),
                                    if (_latitude != null &&
                                        _longitude != null) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        height: 180,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: const Color(0xFFD9E6E2)),
                                        ),
                                        child: LocationPreviewMap(
                                          latitude: _latitude!,
                                          longitude: _longitude!,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: OutlinedButton.icon(
                                        onPressed: _capturingLocation
                                            ? null
                                            : _captureCurrentLocation,
                                        icon: Icon(
                                          _capturingLocation
                                              ? Icons.hourglass_top_rounded
                                              : Icons.my_location_rounded,
                                        ),
                                        label: Text(
                                          _capturingLocation
                                              ? 'লোকেশন আনা হচ্ছে...'
                                              : 'বর্তমান লাইভ লোকেশন নিন',
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              const Color(0xFF0E8F5F),
                                          side: const BorderSide(
                                            color: Color(0xFF0E8F5F),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _saving ? null : _saveStoreDetails,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0E8F5F),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        const Color(0xFFB9C7C5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    _saving
                                        ? 'সংরক্ষণ করা হচ্ছে...'
                                        : 'সংরক্ষণ',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showInfoSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isBangladeshPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length == 11 && digits.startsWith('01');
  }

  bool _validate() {
    var valid = true;
    setState(() {
      _storeNameError = null;
      _ownerNameError = null;
      _mobileError = null;
      _addressError = null;

      if (_storeNameController.text.trim().isEmpty) {
        _storeNameError = 'এই ঘরটি পূরণ করা আবশ্যক';
        valid = false;
      }
      if (_ownerNameController.text.trim().isEmpty) {
        _ownerNameError = 'এই ঘরটি পূরণ করা আবশ্যক';
        valid = false;
      }
      if (_mobileController.text.trim().isEmpty) {
        _mobileError = 'এই ঘরটি পূরণ করা আবশ্যক';
        valid = false;
      } else if (!_isBangladeshPhone(_mobileController.text)) {
        _mobileError = 'সঠিক মোবাইল নম্বর দিন';
        valid = false;
      }
      if (_addressController.text.trim().isEmpty) {
        _addressError = 'এই ঘরটি পূরণ করা আবশ্যক';
        valid = false;
      }
    });
    return valid;
  }

  Future<void> _saveStoreDetails() async {
    if (!_validate()) {
      return;
    }
    setState(() => _saving = true);
    try {
      final repository = ref.read(businessSettingsRepositoryProvider);
      final logoBase64 = _logoBytes == null ? '' : base64Encode(_logoBytes!);
      await repository.saveStoreDetails(
        StoreDetails(
          storeName: _storeNameController.text.trim(),
          ownerName: _ownerNameController.text.trim(),
          mobile: _mobileController.text.trim(),
          address: _addressController.text.trim(),
          storeType: _storeType,
          tradeLicenseNo: _tradeLicenseController.text.trim(),
          tinNo: _tinController.text.trim(),
          binNo: _binController.text.trim(),
          liveLocation: _liveLocationController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          logoFileName: _logoFileName,
          logoBase64: logoBase64,
          logoUrl: _logoUrl,
        ),
      );
      if (_logoBytes != null && _logoFileName.trim().isNotEmpty) {
        final nextLogoUrl = await repository.uploadShopLogo(
          fileName: _logoFileName,
          contentType: _contentTypeForLogo(_logoFileName),
          base64Data: logoBase64,
        );
        if (mounted) {
          setState(() => _logoUrl = nextLogoUrl);
        }
      }
      ref.invalidate(storeDetailsProvider);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('দোকানের তথ্য সংরক্ষণ করা হয়েছে')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('তথ্য বা লোগো সংরক্ষণ করা যায়নি')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
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

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      withData: true,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('লোগো ফাইল পড়া যায়নি')),
      );
      return;
    }
    setState(() {
      _logoBytes = bytes;
      _logoFileName = file.name;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('লোগো নির্বাচন করা হয়েছে')),
    );
  }

  String _contentTypeForLogo(String fileName) {
    final normalized = fileName.trim().toLowerCase();
    if (normalized.endsWith('.png')) {
      return 'image/png';
    }
    if (normalized.endsWith('.webp')) {
      return 'image/webp';
    }
    if (normalized.endsWith('.svg')) {
      return 'image/svg+xml';
    }
    return 'image/jpeg';
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
        _liveLocationController.text = result.label;
      });
    } on StoreLocationException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('লাইভ লোকেশন আনা যায়নি')),
      );
    } finally {
      if (mounted) setState(() => _capturingLocation = false);
    }
  }
}

class _StoreSettingsCard extends StatelessWidget {
  const _StoreSettingsCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3EBE8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C21413C),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF16302E),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _StoreInfoSummaryCard extends StatelessWidget {
  const _StoreInfoSummaryCard({
    required this.borderColor,
    required this.accent,
    required this.textColor,
    required this.mutedColor,
    required this.onViewDetails,
    required this.storeName,
    required this.storeType,
    required this.logoUrl,
  });

  final Color borderColor;
  final Color accent;
  final Color textColor;
  final Color mutedColor;
  final VoidCallback onViewDetails;
  final String storeName;
  final String storeType;
  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C21413C),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: logoUrl.trim().isNotEmpty
                  ? Image.network(
                      logoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.storefront_rounded,
                            color: Color(0xFF0E8F5F), size: 28);
                      },
                    )
                  : const Icon(Icons.storefront_rounded,
                      color: Color(0xFF0E8F5F), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName.isNotEmpty ? storeName : 'দোকান',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    storeType.isNotEmpty ? storeType : 'দোকানের ধরন',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: onViewDetails,
                          style: TextButton.styleFrom(
                            foregroundColor: accent,
                            backgroundColor: accent.withOpacity(0.08),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'দেখুন / পরিবর্তন করুন',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
