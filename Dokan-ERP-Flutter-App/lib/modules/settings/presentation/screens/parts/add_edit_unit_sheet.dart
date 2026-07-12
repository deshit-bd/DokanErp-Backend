part of '../settings_screens.dart';

class _AddEditUnitSheet extends ConsumerStatefulWidget {
  const _AddEditUnitSheet({this.existing, required this.onSaved});
  final DokanUnit? existing;
  final VoidCallback onSaved;

  @override
  ConsumerState<_AddEditUnitSheet> createState() => _AddEditUnitSheetState();
}

class _AddEditUnitSheetState extends ConsumerState<_AddEditUnitSheet> {
  static const Color _text = Color(0xFF16302E);
  static const Color _muted = Color(0xFF6F8280);

  late final TextEditingController _banglaCtrl;
  late final TextEditingController _englishCtrl;
  String? _banglaError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _banglaCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _englishCtrl =
        TextEditingController(text: widget.existing?.shortName ?? '');
  }

  @override
  void dispose() {
    _banglaCtrl.dispose();
    _englishCtrl.dispose();
    super.dispose();
  }

  String _resolveUnitType(String name) {
    final clean = name.trim().toLowerCase();
    if (clean.contains('পিস') ||
        clean.contains('pcs') ||
        clean.contains('piece') ||
        clean.contains('ডজন') ||
        clean.contains('dozen') ||
        clean.contains('বাক্স') ||
        clean.contains('box') ||
        clean.contains('বান্ডিল') ||
        clean.contains('bundle')) {
      return 'COUNTABLE';
    }
    if (clean.contains('কেজি') ||
        clean.contains('kg') ||
        clean.contains('kilogram') ||
        clean.contains('গ্রাম') ||
        clean.contains('gram') ||
        clean.contains('g')) {
      return 'WEIGHT';
    }
    if (clean.contains('লিটার') ||
        clean.contains('liter') ||
        clean.contains('l') ||
        clean.contains('মিলি') ||
        clean.contains('ml')) {
      return 'VOLUME';
    }
    return 'COUNTABLE';
  }

  Future<void> _save() async {
    final name = _banglaCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _banglaError = 'বাংলা নাম আবশ্যক');
      return;
    }
    final shortName = _englishCtrl.text.trim();
    final type = _resolveUnitType(name.isNotEmpty ? name : shortName);

    setState(() {
      _isSaving = true;
      _banglaError = null;
    });

    try {
      if (widget.existing != null) {
        await ref.read(dokanUnitListProvider.notifier).updateUnit(
              widget.existing!.id,
              name,
              shortName.isEmpty ? name : shortName,
              widget.existing!.type,
              null,
            );
      } else {
        await ref.read(dokanUnitListProvider.notifier).addUnit(
              name,
              shortName.isEmpty ? name : shortName,
              type,
              null,
            );
      }
      widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _banglaError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 24,
                  offset: Offset(0, -4)),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'ইউনিট সম্পাদনা' : 'নতুন ইউনিট যোগ করুন',
                      style: const TextStyle(
                          color: _text,
                          fontSize: 17,
                          fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(foregroundColor: _muted),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _StoreTextField(
                  label: 'বাংলা নাম *',
                  controller: _banglaCtrl,
                  onChanged: (_) => setState(() => _banglaError = null),
                  errorText: _banglaError,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 14),
                  child: Text('যেমন: পিস',
                      style: const TextStyle(color: _muted, fontSize: 11.5)),
                ),
                _StoreTextField(
                  label: 'ইংরেজি নাম / শর্ট কোড',
                  controller: _englishCtrl,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.only(left: 2, bottom: 20),
                  child: Text('যেমন: Pcs, KG',
                      style: TextStyle(color: _muted, fontSize: 11.5)),
                ),
                _isSaving
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _StoreActionButton(
                        label:
                            isEdit ? 'পরিবর্তন সংরক্ষণ করুন' : 'ইউনিট যোগ করুন',
                        icon: isEdit ? Icons.save_rounded : Icons.add_rounded,
                        onPressed: _save,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _InventoryModeType {
  basic,
  advanced;

  String get title => switch (this) {
        _InventoryModeType.basic => 'সাধারণ ইনভেন্টরি মোড',
        _InventoryModeType.advanced => 'অ্যাডভান্সড র‍্যাক ইনভেন্টরি মোড',
      };

  String get description => switch (this) {
        _InventoryModeType.basic => 'র‍্যাক বা বিন ব্যবহার করা হয় না',
        _InventoryModeType.advanced =>
          'জোন, র‍্যাক, শেলফ এবং বিন ব্যবহার করা হয়',
      };

  String get summary => switch (this) {
        _InventoryModeType.basic => 'সব স্টক মেইন স্টোরে রাখা হবে',
        _InventoryModeType.advanced => 'লোকেশন অনুযায়ী স্টক ট্র‍্যাক করা হবে',
      };

  IconData get icon => switch (this) {
        _InventoryModeType.basic => Icons.inventory_2_outlined,
        _InventoryModeType.advanced => Icons.dashboard_customize_rounded,
      };

  List<String> get benefits => switch (this) {
        _InventoryModeType.basic => const [
            'সরল, দ্রুত সেটআপ',
            'ছোট ব্যবসার জন্য উপযোগী',
            'অতিরিক্ত লোকেশন কনফিগারেশন লাগে না',
          ],
        _InventoryModeType.advanced => const [
            'জোন, র‍্যাক, শেলফ এবং বিন যোগ করা যাবে',
            'নির্দিষ্ট লোকেশনে স্টক অ্যাসাইন করা যাবে',
            'প্রতি শেলফ/বিন অনুযায়ী লো স্টক অ্যালার্ট পাওয়া যাবে',
          ],
      };
}

class DokanInventoryModeSelectionScreen extends ConsumerStatefulWidget {
  const DokanInventoryModeSelectionScreen({
    super.key,
    this.showBackButton = true,
    this.oneTimeSetup = false,
    this.onCompleted,
  });

  final bool showBackButton;
  final bool oneTimeSetup;
  final VoidCallback? onCompleted;

  @override
  ConsumerState<DokanInventoryModeSelectionScreen> createState() =>
      _DokanInventoryModeSelectionScreenState();
}

class _DokanInventoryModeSelectionScreenState
    extends ConsumerState<DokanInventoryModeSelectionScreen> {
  static const Color _bg = Color(0xFFF4F7FB);
  static const Color _text = Color(0xFF16302E);
  static const Color _muted = Color(0xFF6F8280);
  static const Color _accent = Color(0xFF0E8F5F);

  _InventoryModeType? _selectedMode;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadCurrentMode);
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedMode != null;
    final summary = _selectedMode == null
        ? null
        : (_selectedMode == _InventoryModeType.basic
            ? 'Basic mode: মোট quantity ট্র্যাক হবে। Zone, Rack, Shelf, Bin লাগবে না।'
            : 'Advanced mode: Zone → Rack → Shelf → Bin অনুযায়ী stock assign হবে।');
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: _bg,
        elevation: 0,
        centerTitle: false,
        leading: widget.showBackButton
            ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _text,
                  ),
                ),
              )
            : null,
        leadingWidth: widget.showBackButton ? 72 : 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ইনভেন্টরি মোড',
              style: TextStyle(
                color: _text,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.oneTimeSetup
                  ? 'স্টোর সেটআপের পর একবার ইনভেন্টরি মোড নির্বাচন করুন'
                  : 'আপনার ইনভেন্টরি কীভাবে পরিচালনা করবেন তা নির্বাচন করুন',
              style: const TextStyle(
                color: _muted,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE3EBE8)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedMode == null
                          ? Icons.touch_app_rounded
                          : (_selectedMode == _InventoryModeType.basic
                              ? Icons.inventory_2_outlined
                              : Icons.dashboard_customize_rounded),
                      color: _accent,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        hasSelection
                            ? 'নির্বাচিত: ${_selectedMode!.title}'
                            : widget.oneTimeSetup
                                ? 'একটি মোড নির্বাচন করুন। স্টোর সেটআপে এটি একবারই সংরক্ষণ হবে।'
                                : 'একটি মোড নির্বাচন করুন।',
                        style: const TextStyle(
                          color: _text,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: (_selectedMode == null || _isSaving)
                      ? null
                      : _saveSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFB9C8C2),
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'পছন্দ সংরক্ষণ করুন',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.oneTimeSetup
                    ? 'দ্রষ্টব্য: এই পছন্দটি স্টোর সেটআপে একবার নেওয়া হবে। ছোট দোকানের জন্য Basic mode, আর zone/rack/shelf/bin দরকার হলে Advanced mode বেছে নিন।'
                    : 'দ্রষ্টব্য: ছোট দোকানের জন্য Basic mode, আর zone/rack/shelf/bin দরকার হলে Advanced mode সবচেয়ে উপযোগী।',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth =
                constraints.maxWidth > 760 ? 760.0 : constraints.maxWidth;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildIntroCard(),
                            const SizedBox(height: 14),
                            _buildCompareRow(),
                            const SizedBox(height: 14),
                            _InventoryModeOptionCard(
                              mode: _InventoryModeType.basic,
                              selected:
                                  _selectedMode == _InventoryModeType.basic,
                              onTap: () => setState(() {
                                _selectedMode = _InventoryModeType.basic;
                                _loadError = null;
                              }),
                            ),
                            const SizedBox(height: 14),
                            _InventoryModeOptionCard(
                              mode: _InventoryModeType.advanced,
                              selected:
                                  _selectedMode == _InventoryModeType.advanced,
                              onTap: () => setState(() {
                                _selectedMode = _InventoryModeType.advanced;
                                _loadError = null;
                              }),
                            ),
                            const SizedBox(height: 14),
                            _buildSummaryCard(summary),
                            const SizedBox(height: 14),
                            _buildSelectionHint(),
                          ],
                        ),
                      ),
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

  void _saveSelection() {
    final selected = _selectedMode;
    if (selected == null) {
      return;
    }
    unawaited(_persistSelection(selected));
  }

  Future<void> _loadCurrentMode() async {
    try {
      final repo = ref.read(inventoryLayoutRepositoryProvider);
      final data = await repo.getInventoryMode();
      final configured = data['configured'] == true;
      final rawMode = '${data['mode'] ?? ''}'.trim().toUpperCase();
      if (!mounted) return;
      setState(() {
        _selectedMode = configured
            ? (rawMode == 'RACK'
                ? _InventoryModeType.advanced
                : _InventoryModeType.basic)
            : null;
        _isLoading = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError =
            'সেভ করা inventory mode পাওয়া যায়নি। আপনি নতুন করে নির্বাচন করতে পারেন।';
      });
    }
  }

  Future<void> _persistSelection(_InventoryModeType selected) async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(inventoryLayoutRepositoryProvider);
      final mode = selected == _InventoryModeType.advanced ? 'RACK' : 'GENERAL';
      await repo.updateInventoryMode({'mode': mode});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selected.title} সংরক্ষণ করা হয়েছে'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _accent,
        ),
      );
      if (widget.onCompleted != null) {
        widget.onCompleted!.call();
      } else if (selected == _InventoryModeType.advanced) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const DokanStoreLayoutManagementScreen(),
          ),
        );
      } else {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inventory mode সংরক্ষণ করা যায়নি'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFFC2410C),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E8F5F), Color(0xFF0A6F4A)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220B5B40),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.precision_manufacturing_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'দ্রুত, পরিষ্কার সিদ্ধান্ত নিন',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'আপনার দোকানের জন্য সঠিক inventory mode বেছে নিন: সরল সেটআপ, না কি লোকেশনভিত্তিক গভীর কন্ট্রোল।',
                  style: TextStyle(
                    color: Color(0xE6FFFFFF),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareRow() {
    return const Row(
      children: [
        Expanded(
          child: _InventoryModePill(
            title: 'Basic',
            subtitle: 'ছোট দোকান',
            icon: Icons.inventory_2_outlined,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _InventoryModePill(
            title: 'Advanced',
            subtitle: 'জোন/র‍্যাক',
            icon: Icons.dashboard_customize_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionHint() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3EBE8)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded,
              size: 18, color: Color(0xFF0E8F5F)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tip: Basic mode দ্রুত শুরু করার জন্য ভালো। Advanced mode বেছে নিলে Zone, Rack, Shelf এবং Bin management চালু হবে।',
              style: TextStyle(
                color: _text,
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String? summary) {
    final selected = _selectedMode;
    final isAdvanced = selected == _InventoryModeType.advanced;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAdvanced ? const Color(0xFFF1FBF6) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAdvanced ? const Color(0xFFB7E7D3) : const Color(0xFFE3EBE8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAdvanced
                    ? Icons.dashboard_customize_rounded
                    : Icons.inventory_2_outlined,
                color: _accent,
                size: 18,
              ),
              const SizedBox(width: 10),
              const Text(
                'Selected mode summary',
                style: TextStyle(
                  color: _text,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (!_isLoading && _loadError == null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isAdvanced ? 'Advanced' : 'Basic',
                    style: const TextStyle(
                      color: _accent,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary ?? 'একটি মোড নির্বাচন করলে এখানে workflow summary দেখাবে।',
            style: const TextStyle(
              color: _text,
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          if (selected != null)
            Text(
              isAdvanced
                  ? 'Workflow: Save → create Zone → Rack → Shelf → Bin → assign stock'
                  : 'Workflow: Save → track total quantity only → no location structure',
              style: const TextStyle(
                color: _muted,
                fontSize: 11.8,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (_loadError != null) ...[
            const SizedBox(height: 10),
            Text(
              _loadError!,
              style: const TextStyle(
                color: Color(0xFFC2410C),
                fontSize: 11.8,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InventoryModePill extends StatelessWidget {
  const _InventoryModePill({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3EBE8)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0E8F5F), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF16302E),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6F8280),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
