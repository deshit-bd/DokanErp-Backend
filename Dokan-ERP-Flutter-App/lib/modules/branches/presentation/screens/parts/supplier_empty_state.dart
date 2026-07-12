part of '../business_screens.dart';

class _SupplierEmptyState extends StatelessWidget {
  const _SupplierEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E5E1)),
      ),
      child: const Column(
        children: [
          Icon(Icons.local_shipping_outlined,
              color: Color(0xFF0C8C67), size: 52),
          SizedBox(height: 12),
          Text(
            'কোনো সরবরাহকারী পাওয়া যায়নি',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF163732),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'নতুন সরবরাহকারী যোগ করলে তালিকা এখানে দেখা যাবে।',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7B79),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupplierSectionEmptyState extends StatelessWidget {
  const _SupplierSectionEmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD9E5E1)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF6B7B79),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SupplierListTile extends StatelessWidget {
  const _SupplierListTile({
    required this.supplier,
    required this.onTap,
    required this.onLongPress,
    required this.selected,
    required this.selectionMode,
  });

  final _SupplierSummary supplier;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool selected;
  final bool selectionMode;

  @override
  Widget build(BuildContext context) {
    final dueColor = supplier.totalDue > 0
        ? const Color(0xFFB3261E)
        : const Color(0xFF0C8C67);
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
                      _supplierInitials(supplier.name),
                      style: const TextStyle(
                        color: Color(0xFF0C8C67),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
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
                    Text(
                      supplier.name,
                      style: const TextStyle(
                        color: Color(0xFF163732),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _supplierMaskedPhone(supplier.phone),
                      style: const TextStyle(
                        color: Color(0xFF6B7B79),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'সর্বশেষ ${_formatDateTime(supplier.lastTransactionAt)}',
                      style: const TextStyle(
                        color: Color(0xFF7C8C8A),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    supplier.totalDue > 0 ? 'বকেয়া' : 'পরিশোধ',
                    style: TextStyle(
                      color: dueColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(supplier.totalDue),
                    style: TextStyle(
                      color: dueColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF7C8C8A)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaffSummary {
  const _StaffSummary({
    required this.key,
    required this.name,
    required this.phone,
    required this.role,
    required this.address,
    required this.note,
    required this.active,
    required this.joinedAt,
    required this.lastActiveAt,
    required this.lastLoginAt,
    required this.recentSalesCount,
    required this.permissions,
    required this.pinCode,
    required this.createdAt,
    required this.updatedAt,
  });

  final String key;
  final String name;
  final String phone;
  final String role;
  final String address;
  final String note;
  final bool active;
  final DateTime joinedAt;
  final DateTime lastActiveAt;
  final DateTime lastLoginAt;
  final int recentSalesCount;
  final List<String> permissions;
  final String? pinCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get statusLabel => active ? 'Active' : 'Inactive';
}

class _ActivityEntry {
  const _ActivityEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _PermissionOption {
  const _PermissionOption(this.key, this.label);

  final String key;
  final String label;
}

class _PermissionCategory {
  const _PermissionCategory(this.label, this.options);

  final String label;
  final List<_PermissionOption> options;
}

const List<_PermissionCategory> _staffPermissionSections =
    <_PermissionCategory>[
  _PermissionCategory('বিক্রয় পরিচালনা', <_PermissionOption>[
    _PermissionOption('sales.create', 'বিক্রয় তৈরি'),
    _PermissionOption('sales.view', 'বিক্রয় দেখা'),
    _PermissionOption('sales.update', 'বিক্রয় সম্পাদনা'),
  ]),
  _PermissionCategory('পণ্য পরিচালনা', <_PermissionOption>[
    _PermissionOption('product.view', 'পণ্য দেখা'),
    _PermissionOption('product.add', 'পণ্য যোগ'),
    _PermissionOption('product.update', 'পণ্য সম্পাদনা'),
    _PermissionOption('stock.manage', 'স্টক পরিচালনা'),
  ]),
  _PermissionCategory('গ্রাহক পরিচালনা', <_PermissionOption>[
    _PermissionOption('customer.view', 'গ্রাহক দেখা'),
    _PermissionOption('customer.add', 'গ্রাহক যোগ'),
    _PermissionOption('customer.due', 'বাকি দেখা'),
  ]),
  _PermissionCategory('সরবরাহকারী পরিচালনা', <_PermissionOption>[
    _PermissionOption('supplier.view', 'সরবরাহকারী দেখা'),
    _PermissionOption('supplier.add', 'সরবরাহকারী যোগ'),
    _PermissionOption('supplier.payment', 'সরবরাহকারী পেমেন্ট'),
  ]),
  _PermissionCategory('রিপোর্ট দেখা', <_PermissionOption>[
    _PermissionOption('reports.view', 'রিপোর্ট দেখা'),
    _PermissionOption('reports.sales', 'বিক্রয় রিপোর্ট'),
    _PermissionOption('reports.profit', 'লাভ-ক্ষতি রিপোর্ট'),
  ]),
  _PermissionCategory('হিসাব দেখা', <_PermissionOption>[
    _PermissionOption('accounts.view', 'হিসাব দেখা'),
    _PermissionOption('accounts.expense', 'খরচ দেখা'),
    _PermissionOption('accounts.payment', 'পেমেন্ট দেখা'),
  ]),
  _PermissionCategory('কর্মচারী পরিচালনা', <_PermissionOption>[
    _PermissionOption('staff.manage', 'কর্মচারী পরিচালনা'),
    _PermissionOption('staff.permissions', 'অনুমতি পরিচালনা'),
    _PermissionOption('staff.pin', 'PIN সেটআপ'),
  ]),
];

List<String> _defaultPermissionsForRole(String role) {
  switch (role) {
    case 'Manager':
      return _staffPermissionSections
          .expand((section) => section.options)
          .map((option) => option.key)
          .where((key) => key != 'staff.pin')
          .toList(growable: false);
    case 'Cashier':
      return <String>[
        'sales.view',
        'customer.view',
        'accounts.view',
        'accounts.payment',
      ];
    case 'Salesman':
      return <String>[
        'sales.create',
        'sales.view',
        'customer.view',
      ];
    default:
      return <String>[
        'sales.view',
        'customer.view',
      ];
  }
}

String _permissionLabel(String key) {
  for (final section in _staffPermissionSections) {
    for (final option in section.options) {
      if (option.key == key) {
        return option.label;
      }
    }
  }
  return key;
}

String _staffRoleDisplay(String role) {
  final clean = role.trim();
  final upper = clean.toUpperCase();
  if (upper == 'SALESMAN') return 'Salesman';
  if (upper == 'MANAGER') return 'Manager';
  if (upper == 'CASHIER') return 'Cashier';

  switch (clean) {
    case 'Salesman':
      return 'Salesman';
    case 'Manager':
      return 'Manager';
    case 'Cashier':
      return 'Cashier';
    default:
      return clean.isEmpty ? 'Other' : clean;
  }
}

String _staffInitials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return 'ক';
  }
  if (parts.length == 1) {
    return String.fromCharCode(parts.first.runes.first);
  }
  return '${String.fromCharCode(parts.first.runes.first)}${String.fromCharCode(parts.last.runes.first)}';
}

String _staffMaskedPhone(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) {
    return 'ফোন নেই';
  }
  if (digits.length <= 4) {
    return digits;
  }
  return '${digits.substring(0, 3)}••••${digits.substring(digits.length - 4)}';
}

_StaffSummary? _findStaff(DokanPosState state, String key) {
  final match = _buildStaffSummaries(state)
      .where((item) => item.key == key)
      .toList(growable: false);
  return match.isEmpty ? null : match.first;
}

List<_StaffSummary> _buildStaffSummaries(DokanPosState state) {
  final summaries = state.staffProfiles
      .where((profile) => !state.hiddenStaffKeys.contains(profile.key))
      .map(
        (profile) => _StaffSummary(
          key: profile.key,
          name: profile.name,
          phone: profile.phone,
          role: _staffRoleDisplay(profile.role),
          address: profile.address,
          note: profile.note,
          active: profile.active,
          joinedAt: profile.joinedAt,
          lastActiveAt: profile.lastActiveAt,
          lastLoginAt: profile.lastLoginAt,
          recentSalesCount: profile.recentSalesCount,
          permissions: profile.permissions,
          pinCode: profile.pinCode,
          createdAt: profile.createdAt,
          updatedAt: profile.updatedAt,
        ),
      )
      .toList(growable: false)
    ..sort((a, b) {
      if (a.active != b.active) {
        return b.active ? 1 : -1;
      }
      return b.lastActiveAt.compareTo(a.lastActiveAt);
    });
  return summaries;
}
