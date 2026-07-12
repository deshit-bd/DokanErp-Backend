part of '../business_screens.dart';

class DokanStaffListScreen extends ConsumerStatefulWidget {
  const DokanStaffListScreen({super.key});

  @override
  ConsumerState<DokanStaffListScreen> createState() =>
      _DokanStaffListScreenState();
}

class _DokanStaffListScreenState extends ConsumerState<DokanStaffListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedKeys = <String>{};
  bool _selectionMode = false;
  bool _ready = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _ready = true);
        ref.read(dokanPosProvider.notifier).fetchStaff();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(dokanPosProvider.notifier).fetchStaff();
    if (mounted) setState(() {});
  }

  void _enterSelectionMode(_StaffSummary staff) {
    setState(() {
      _selectionMode = true;
      _selectedKeys.add(staff.key);
    });
  }

  void _toggleSelection(_StaffSummary staff) {
    setState(() {
      if (_selectedKeys.contains(staff.key)) {
        _selectedKeys.remove(staff.key);
      } else {
        _selectedKeys.add(staff.key);
        _selectionMode = true;
      }
      if (_selectedKeys.isEmpty) {
        _selectionMode = false;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedKeys.clear();
      _selectionMode = false;
    });
  }

  Future<void> _deleteSelected(
      BuildContext context, WidgetRef ref, List<_StaffSummary> selected) async {
    if (selected.isEmpty) return;
    final confirmed = await _showBulkDeleteDialog(
      context: context,
      entityLabel: 'কর্মচারী',
      names: selected.map((e) => e.name).toList(growable: false),
    );
    if (!confirmed) return;
    for (final item in selected) {
      ref.read(dokanPosProvider.notifier).deleteStaff(item.key);
    }
    if (mounted) {
      _clearSelection();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const _SupplierLoadingScreen();
    }

    final state = ref.watch(dokanPosProvider);
    final staff = _buildStaffSummaries(state);
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? staff
        : staff
            .where((item) =>
                item.name.toLowerCase().contains(q) ||
                item.phone.toLowerCase().contains(q))
            .toList(growable: false);
    final total = staff.length;
    final active = staff.where((item) => item.active).length;
    final inactive = total - active;
    final selected = staff
        .where((item) => _selectedKeys.contains(item.key))
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F6),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DokanAddNewStaffScreen())),
        backgroundColor: const Color(0xFF0C8C67),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('কর্মচারী যোগ করুন'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBar: _selectionMode
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: selected.isEmpty
                        ? null
                        : () => _deleteSelected(context, ref, selected),
                    icon: const Icon(Icons.delete_rounded),
                    label: Text(
                        'ডিলিট করুন (${_banglaDigits(selected.length.toString())})'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD6453A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFF0C8C67),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics()),
            padding: EdgeInsets.fromLTRB(16, 12, 16, _selectionMode ? 144 : 96),
            children: [
              Row(
                children: [
                  _HeaderButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).maybePop()),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'কর্মচারী',
                          style: TextStyle(
                              color: Color(0xFF163732),
                              fontSize: 22,
                              fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'কর্মচারীর তথ্য, ভূমিকা ও অনুমতি',
                          style: TextStyle(
                              color: Color(0xFF6B7B79),
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _HeaderButton(icon: Icons.refresh_rounded, onTap: _onRefresh),
                ],
              ),
              const SizedBox(height: 14),
              _SearchField(
                controller: _searchController,
                query: _query,
                onChanged: (value) => setState(() => _query = value),
                onClear: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.people_alt_rounded,
                      iconColor: const Color(0xFF0E855D),
                      iconBackground: const Color(0xFFE7F5EF),
                      title: 'মোট কর্মচারী',
                      value: _banglaDigits(total.toString()),
                      subtitle: 'সকল স্টাফ',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.verified_user_rounded,
                      iconColor: const Color(0xFF1B62D3),
                      iconBackground: const Color(0xFFE8F0FF),
                      title: 'সক্রিয় কর্মচারী',
                      value: _banglaDigits(active.toString()),
                      subtitle: 'এখন সক্রিয়',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                icon: Icons.do_not_disturb_on_rounded,
                iconColor: const Color(0xFFB3261E),
                iconBackground: const Color(0xFFFDECEC),
                title: 'নিষ্ক্রিয় কর্মচারী',
                value: _banglaDigits(inactive.toString()),
                subtitle: 'অস্থায়ীভাবে বন্ধ',
                valueColor: const Color(0xFFB3261E),
              ),
              const SizedBox(height: 14),
              if (filtered.isEmpty)
                const _SupplierSectionEmptyState(
                    label: 'কোনো কর্মচারী পাওয়া যায়নি')
              else
                ...filtered.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StaffCard(
                      staff: item,
                      selected: _selectedKeys.contains(item.key),
                      selectionMode: _selectionMode,
                      onTap: () {
                        if (_selectionMode) {
                          _toggleSelection(item);
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    DokanStaffDetailScreen(staffKey: item.key)),
                          );
                        }
                      },
                      onLongPress: () {
                        if (_selectionMode) {
                          _toggleSelection(item);
                        } else {
                          _enterSelectionMode(item);
                        }
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DokanStaffDetailScreen extends ConsumerWidget {
  const DokanStaffDetailScreen({super.key, required this.staffKey});

  final String staffKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = _findStaff(ref.watch(dokanPosProvider), staffKey);
    if (staff == null) {
      return const _SupplierErrorScreen(message: 'কর্মচারীর তথ্য পাওয়া যায়নি');
    }

    final granted = staff.permissions.toSet();
    final recentActivities = <_ActivityEntry>[
      _ActivityEntry(
          title: 'শেষ লগইন',
          subtitle: _formatDateTime(staff.lastLoginAt),
          icon: Icons.login_rounded),
      _ActivityEntry(
          title: 'শেষ সক্রিয়তা',
          subtitle: _formatDateTime(staff.lastActiveAt),
          icon: Icons.access_time_rounded),
      _ActivityEntry(
          title: 'সাম্প্রতিক বিক্রয়',
          subtitle: '${_banglaDigits(staff.recentSalesCount.toString())} টি',
          icon: Icons.point_of_sale_rounded),
    ];

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
                    'কর্মচারী বিস্তারিত',
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD9E5E1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F5EF),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _staffInitials(staff.name),
                          style: const TextStyle(
                              color: Color(0xFF0C8C67),
                              fontSize: 18,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(staff.name,
                                style: const TextStyle(
                                    color: Color(0xFF163732),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text(staff.role,
                                style: const TextStyle(
                                    color: Color(0xFF6B7B79),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _miniInfoChip(
                          icon: Icons.call_rounded, text: staff.phone),
                      _miniInfoChip(
                          icon: Icons.badge_rounded, text: staff.role),
                      _miniInfoChip(
                          icon: Icons.verified_user_rounded,
                          text: staff.active ? 'Active' : 'Inactive'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.calendar_month_rounded,
                          iconColor: const Color(0xFF0E855D),
                          iconBackground: const Color(0xFFE7F5EF),
                          title: 'যোগদানের তারিখ',
                          value: _formatDate(staff.joinedAt),
                          subtitle: 'কর্মজীবনের শুরু',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.check_circle_rounded,
                          iconColor: staff.active
                              ? const Color(0xFF0C8C67)
                              : const Color(0xFFB3261E),
                          iconBackground: staff.active
                              ? const Color(0xFFE7F5EF)
                              : const Color(0xFFFDECEC),
                          title: 'Status',
                          value: staff.active ? 'Active' : 'Inactive',
                          subtitle: 'বর্তমান অবস্থা',
                          valueColor: staff.active
                              ? const Color(0xFF0C8C67)
                              : const Color(0xFFB3261E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                DokanAddNewStaffScreen(staffKey: staff.key))),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('সম্পাদনা করুন'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0C8C67),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ref
                        .read(dokanPosProvider.notifier)
                        .toggleStaffStatus(staff.key),
                    icon: Icon(staff.active
                        ? Icons.pause_circle_rounded
                        : Icons.play_circle_rounded),
                    label:
                        Text(staff.active ? 'নিষ্ক্রিয় করুন' : 'সক্রিয় করুন'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF163732),
                      side: const BorderSide(color: Color(0xFFD9E5E1)),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _DetailSection(
              title: 'কর্মচারী তথ্য',
              child: Column(
                children: [
                  _InfoRow(label: 'নাম', value: staff.name),
                  const Divider(height: 24),
                  _InfoRow(label: 'ফোন নম্বর', value: staff.phone),
                  const Divider(height: 24),
                  _InfoRow(label: 'ভূমিকা', value: staff.role),
                  const Divider(height: 24),
                  _InfoRow(
                      label: 'ঠিকানা',
                      value: staff.address.isEmpty
                          ? 'সংরক্ষিত নেই'
                          : staff.address),
                  const Divider(height: 24),
                  _InfoRow(
                      label: 'নোট',
                      value: staff.note.isEmpty ? 'সংরক্ষিত নেই' : staff.note),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _DetailSection(
              title: 'কার্যক্রম',
              child: Column(
                children: recentActivities
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAF9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2ECE8)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE7F5EF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(entry.icon,
                                    color: const Color(0xFF0C8C67), size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.title,
                                        style: const TextStyle(
                                            color: Color(0xFF163732),
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 3),
                                    Text(entry.subtitle,
                                        style: const TextStyle(
                                            color: Color(0xFF6B7B79),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
            const SizedBox(height: 14),
            _DetailSection(
              title: 'অনুমতি',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: granted.isEmpty
                        ? const [Chip(label: Text('কোনো অনুমতি নেই'))]
                        : granted
                            .map((permission) =>
                                Chip(label: Text(_permissionLabel(permission))))
                            .toList(growable: false),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => DokanStaffPermissionsScreen(
                                staffKey: staff.key))),
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('অনুমতি পরিচালনা'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF163732),
                      side: const BorderSide(color: Color(0xFFD9E5E1)),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                DokanStaffPinSetupScreen(staffKey: staff.key))),
                    icon: const Icon(Icons.pin_rounded),
                    label: const Text('PIN সেট করুন'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF163732),
                      side: const BorderSide(color: Color(0xFFD9E5E1)),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
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
