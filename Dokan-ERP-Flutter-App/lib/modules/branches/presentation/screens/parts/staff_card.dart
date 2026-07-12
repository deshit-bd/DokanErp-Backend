part of '../business_screens.dart';

class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.staff,
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  final _StaffSummary staff;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final dueColor =
        staff.active ? const Color(0xFF0C8C67) : const Color(0xFFB3261E);
    final borderColor =
        selected ? const Color(0xFF0C8C67) : const Color(0xFFD9E5E1);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: selected ? 1.4 : 1),
            color: selected ? const Color(0xFFF1FBF6) : Colors.white,
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F5EF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _staffInitials(staff.name),
                      style: const TextStyle(
                          color: Color(0xFF0C8C67),
                          fontSize: 16,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  if (selectionMode)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color:
                              selected ? const Color(0xFF0C8C67) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF0C8C67), width: 1.5),
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            staff.name,
                            style: const TextStyle(
                                color: Color(0xFF163732),
                                fontSize: 16,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        _Pill(
                          label: staff.active ? 'Active' : 'Inactive',
                          background: staff.active
                              ? const Color(0xFFE7F5EF)
                              : const Color(0xFFFDECEC),
                          textColor: dueColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _staffMaskedPhone(staff.phone),
                      style: const TextStyle(
                          color: Color(0xFF6B7B79),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetricPill(label: 'ভূমিকা', value: staff.role),
                        _MetricPill(
                            label: 'সর্বশেষ সক্রিয়',
                            value: _formatShortTime(staff.lastActiveAt)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF7C8C8A)),
            ],
          ),
        ),
      ),
    );
  }
}

class DokanStaffPermissionsScreen extends ConsumerStatefulWidget {
  const DokanStaffPermissionsScreen({super.key, required this.staffKey});

  final String staffKey;

  @override
  ConsumerState<DokanStaffPermissionsScreen> createState() =>
      _DokanStaffPermissionsScreenState();
}

class _DokanStaffPermissionsScreenState
    extends ConsumerState<DokanStaffPermissionsScreen> {
  late final Set<String> _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final staff = _findStaff(ref.read(dokanPosProvider), widget.staffKey);
    _selected = staff == null ? <String>{} : staff.permissions.toSet();
  }

  Future<void> _save() async {
    final staff = _findStaff(ref.read(dokanPosProvider), widget.staffKey);
    if (staff == null) return;
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('আপনি কি নিশ্চিত?'),
            content: Text('${staff.name} এর অনুমতি সংরক্ষণ করবেন?'),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('বাতিল')),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0C8C67),
                    foregroundColor: Colors.white),
                child: const Text('সংরক্ষণ'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    setState(() => _saving = true);
    ref.read(dokanPosProvider.notifier).updateStaffPermissions(
        widget.staffKey, _selected.toList(growable: false));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final staff = _findStaff(ref.watch(dokanPosProvider), widget.staffKey);
    if (staff == null) {
      return const _SupplierErrorScreen(message: 'কর্মচারীর তথ্য পাওয়া যায়নি');
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F6),
      body: SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                _HeaderButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).maybePop()),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'অনুমতি',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF163732),
                        fontSize: 18,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 14),
            _DetailSection(
              title: staff.name,
              child: Text(
                '${staff.role} • ${staff.active ? 'Active' : 'Inactive'}',
                style: const TextStyle(
                    color: Color(0xFF6B7B79), fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 14),
            ..._staffPermissionSections.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DetailSection(
                  title: section.label,
                  child: Column(
                    children: section.options.map((option) {
                      return SwitchListTile(
                        value: _selected.contains(option.key),
                        onChanged: (value) {
                          setState(() {
                            if (value) {
                              _selected.add(option.key);
                            } else {
                              _selected.remove(option.key);
                            }
                          });
                        },
                        title: Text(option.label,
                            style: const TextStyle(
                                color: Color(0xFF163732),
                                fontWeight: FontWeight.w600)),
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF0C8C67),
                      );
                    }).toList(growable: false),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0C8C67),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white),
                      )
                    : const Text('সংরক্ষণ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DokanStaffPinSetupScreen extends ConsumerStatefulWidget {
  const DokanStaffPinSetupScreen({super.key, required this.staffKey});

  final String staffKey;

  @override
  ConsumerState<DokanStaffPinSetupScreen> createState() =>
      _DokanStaffPinSetupScreenState();
}

class _DokanStaffPinSetupScreenState
    extends ConsumerState<DokanStaffPinSetupScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isSubmitting = false;
  String? _pinError;
  String? _confirmError;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  bool _isValidPin(String value) =>
      RegExp(r'^[0-9]{4}$').hasMatch(value.trim());

  void _validate() {
    setState(() {
      _pinError = _pinController.text.trim().isEmpty
          ? 'PIN দিন'
          : _isValidPin(_pinController.text)
              ? null
              : 'PIN দিন';
      _confirmError = _confirmPinController.text.trim().isEmpty ||
              _confirmPinController.text.trim() == _pinController.text.trim()
          ? null
          : 'PIN মিলছে না';
    });
  }

  bool get _canSubmit =>
      !_isSubmitting &&
      _isValidPin(_pinController.text) &&
      _pinController.text.trim() == _confirmPinController.text.trim();

  Future<void> _save() async {
    _validate();
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);
    ref.read(dokanPosProvider.notifier).setStaffPin(
          staffKey: widget.staffKey,
          pinCode: _pinController.text.trim(),
        );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final staff = _findStaff(ref.watch(dokanPosProvider), widget.staffKey);
    if (staff == null) {
      return const _SupplierErrorScreen(message: 'কর্মচারীর তথ্য পাওয়া যায়নি');
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F6),
      body: SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                _HeaderButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).maybePop()),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'PIN সেটআপ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF163732),
                        fontSize: 18,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 14),
            _DetailSection(
              title: staff.name,
              child: Text(
                'নিরাপদ PIN তৈরি করুন',
                style: const TextStyle(
                    color: Color(0xFF6B7B79), fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD9E5E1)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4)
                    ],
                    onChanged: (_) => _validate(),
                    style: const TextStyle(color: Color(0xFF111111)),
                    decoration: InputDecoration(
                      labelText: '4-digit PIN *',
                      errorText: _pinError,
                      filled: true,
                      fillColor: const Color(0xFFF8FAF9),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmPinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4)
                    ],
                    onChanged: (_) => _validate(),
                    style: const TextStyle(color: Color(0xFF111111)),
                    decoration: InputDecoration(
                      labelText: 'Confirm PIN *',
                      errorText: _confirmError,
                      filled: true,
                      fillColor: const Color(0xFFF8FAF9),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _canSubmit ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0C8C67),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white),
                      )
                    : const Text('সংরক্ষণ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
