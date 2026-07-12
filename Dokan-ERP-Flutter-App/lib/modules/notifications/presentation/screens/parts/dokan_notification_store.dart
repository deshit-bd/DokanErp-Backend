part of '../notification_center_screen.dart';

NotificationSnapshotRepository? _notificationSnapshotRepository;
_DokanNotificationStore? _notificationStore;

_DokanNotificationStore get _dokanNotificationStore => _notificationStore ??=
    _DokanNotificationStore(_notificationSnapshotRepository);

void configureNotificationSnapshotRepository(
  NotificationSnapshotRepository repository,
) {
  _notificationSnapshotRepository = repository;
}

void dokanNotificationAttachRemote(NotificationRepository? remote) {
  _dokanNotificationStore.attachRemote(remote);
}

final _DokanNotificationPreferences _dokanNotificationPreferences =
    _DokanNotificationPreferences();

int get dokanNotificationUnreadCount => _dokanNotificationStore.unreadCount;

Listenable get dokanNotificationListenable => _dokanNotificationStore;

void addIncomingNotificationToStore(Map<String, dynamic> json) {
  _dokanNotificationStore.handleIncomingSocketNotification(json);
}

void addSalesmanLowStockNotification({
  required String productName,
  required int stock,
  required int lowStockLimit,
  required String salesmanId,
  required String salesmanName,
}) {
  _dokanNotificationStore.addLowStockAlert(
    productName: productName,
    currentStock: stock,
    salesmanName: salesmanName,
  );
}

void addSaleTransactionNotification({
  required String transactionId,
  required String salesmanName,
  required String customerName,
  required String itemsSummary,
  required int totalAmount,
  required int paidAmount,
  required int dueAmount,
  required String paymentMethod,
  required DateTime timestamp,
}) {
  _dokanNotificationStore.addSaleTransactionAlert(
    transactionId: transactionId,
    salesmanName: salesmanName,
    customerName: customerName,
    itemsSummary: itemsSummary,
    totalAmount: totalAmount,
    paidAmount: paidAmount,
    dueAmount: dueAmount,
    paymentMethod: paymentMethod,
    timestamp: timestamp,
  );
}

void syncLowStockAlert({
  required String productName,
  required int stock,
  required int lowStockLimit,
  required String senderId,
  required String senderName,
}) {
  final item = StockItem(
    productId: productName.toLowerCase(),
    productName: productName,
    quantity: stock,
    lowStockLimit: lowStockLimit,
  );
  final alert = StockAlertNotification.fromStockItem(
    item,
    senderId: senderId,
    senderName: senderName,
  );
  if (_dokanNotificationStore._groups.isEmpty) {
    return;
  }
  _dokanNotificationStore._groups.first.items.insert(
    0,
    _NotificationEntry(
      title: 'Low stock alert',
      subtitle:
          '${alert.senderName} reported ${alert.productName} at ${alert.currentStock}/${alert.lowStockLimit}.',
      timeLabel:
          '${alert.createdAt.hour.toString().padLeft(2, '0')}:${alert.createdAt.minute.toString().padLeft(2, '0')}',
      icon: Icons.inventory_2_rounded,
      iconBackground: const Color(0xFFD1FAE5),
      iconColor: alert.urgency == StockUrgency.high
          ? const Color(0xFFD43B3B)
          : alert.urgency == StockUrgency.medium
              ? const Color(0xFFF49B1A)
              : const Color(0xFF16A34A),
      unread: true,
      accent: alert.urgency == StockUrgency.high
          ? const Color(0xFFD43B3B)
          : alert.urgency == StockUrgency.medium
              ? const Color(0xFFF49B1A)
              : const Color(0xFF16A34A),
      category: _NotificationCategory.inventory,
    ),
  );
}

void clearLowStockAlert(String productName) {
  _dokanNotificationStore.removeLowStockAlert(productName);
}

Future<void> showDokanNotificationPreviewSheet(BuildContext context) {
  final flow = ProviderScope.containerOf(context, listen: false)
      .read(dokanAppFlowProvider);
  if (!flow.can(
    DokanPermission.notificationsView,
  )) {
    return Future<void>.value();
  }
  _dokanNotificationStore.markAllAsRead();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (sheetContext) {
      return _NotificationPreviewSheet(
        onSeeAll: () {
          Navigator.of(sheetContext).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DokanNotificationCenterScreen(),
            ),
          );
        },
      );
    },
  );
}

class _DokanNotificationStore extends ChangeNotifier {
  _DokanNotificationStore(this._snapshotRepository)
      : _groups = [
          _NotificationGroup(
            title: 'সাম্প্রতিক',
            style: _SectionStyle.primary,
            items: [
              _NotificationEntry(
                title: 'কম স্টক সতর্কতা',
                subtitle: 'একটি পণ্যের স্টক নির্ধারিত সীমার নিচে নেমে গেছে।',
                timeLabel: '২ মিনিট আগে',
                icon: Icons.warning_amber_rounded,
                iconBackground: Color(0xFFFFF0C2),
                iconColor: Color(0xFFD97706),
                unread: true,
                accent: Color(0xFF00694C),
                category: _NotificationCategory.inventory,
              ),
              _NotificationEntry(
                title: 'নতুন বিক্রয় হয়েছে',
                subtitle: 'আপনার দোকানে একটি নতুন বিক্রয় সম্পন্ন হয়েছে।',
                timeLabel: '১০ মিনিট আগে',
                icon: Icons.check_circle_rounded,
                iconBackground: Color(0xFFD1FAE5),
                iconColor: Color(0xFF059669),
                unread: true,
                accent: Color(0xFF00694C),
                category: _NotificationCategory.sale,
              ),
              _NotificationEntry(
                title: 'নতুন গ্রাহক যুক্ত হয়েছে',
                subtitle: 'একজন নতুন গ্রাহক আপনার কাস্টমার তালিকায় যোগ হয়েছে।',
                timeLabel: '২৫ মিনিট আগে',
                icon: Icons.person_add_alt_1_rounded,
                iconBackground: Color(0xFFE8F1FF),
                iconColor: Color(0xFF2563EB),
                unread: true,
                accent: Color(0xFF0E7B58),
                category: _NotificationCategory.general,
              ),
            ],
          ),
          _NotificationGroup(
            title: 'পুরোনো',
            style: _SectionStyle.secondary,
            items: [
              _NotificationEntry(
                title: 'পেমেন্ট গ্রহণ হয়েছে',
                subtitle: 'একটি ইনভয়েসের পেমেন্ট সফলভাবে গ্রহণ করা হয়েছে।',
                timeLabel: 'গতকাল',
                icon: Icons.credit_card_rounded,
                iconBackground: Color(0xFFDCEBFF),
                iconColor: Color(0xFF2563EB),
                unread: false,
                accent: Color(0xFF2563EB),
                category: _NotificationCategory.sale,
              ),
              _NotificationEntry(
                title: 'স্টক আপডেট হয়েছে',
                subtitle: 'একটি পণ্যের স্টক তথ্য সফলভাবে আপডেট করা হয়েছে।',
                timeLabel: 'গতকাল',
                icon: Icons.inventory_2_rounded,
                iconBackground: Color(0xFFF2E7FE),
                iconColor: Color(0xFF9333EA),
                unread: false,
                accent: Color(0xFF9333EA),
                category: _NotificationCategory.inventory,
              ),
              _NotificationEntry(
                title: 'সাপ্তাহিক রিপোর্ট প্রস্তুত',
                subtitle: 'আপনার সাপ্তাহিক বিক্রয় রিপোর্ট প্রস্তুত হয়েছে।',
                timeLabel: 'গতকাল',
                icon: Icons.assessment_rounded,
                iconBackground: Color(0xFFE2F3E8),
                iconColor: Color(0xFF0E7B58),
                unread: false,
                accent: Color(0xFF0E7B58),
                category: _NotificationCategory.report,
              ),
            ],
          ),
        ] {
    unawaited(_hydrate());
  }

  final List<_NotificationGroup> _groups;
  final NotificationSnapshotRepository? _snapshotRepository;
  NotificationRepository? _remote;
  bool _remoteHydrated = false;

  void attachRemote(NotificationRepository? remote) {
    _remote = remote;
    if (remote != null && !_remoteHydrated) {
      _remoteHydrated = true;
      unawaited(_hydrateRemote());
    }
  }

  Future<void> _hydrateRemote() async {
    final remote = _remote;
    if (remote == null) return;
    try {
      final payload = await remote.list();
      final entries = payload.map(_remoteEntryFromJson).toList(growable: false);
      _replaceEntries(entries);
      final prefs = await remote.loadPreferences();
      if (prefs.isNotEmpty) {
        _dokanNotificationPreferences.applyJson(prefs);
      }
      notifyListeners();
      unawaited(_persist());
    } catch (_) {
      // Keep local notifications when the backend is unavailable.
    }
  }

  void _replaceEntries(List<_NotificationEntry> entries) {
    final unread = entries.where((item) => item.unread).toList();
    final read = entries.where((item) => !item.unread).toList();
    final recent =
        unread.isEmpty ? entries.take(3).toList() : unread;
    final earlier = unread.isEmpty
        ? entries.skip(recent.length).toList()
        : read;
    _groups
      ..clear()
      ..addAll([
        _NotificationGroup(
          title: 'Recent',
          style: _SectionStyle.primary,
          items: recent,
        ),
        _NotificationGroup(
          title: 'Earlier',
          style: _SectionStyle.secondary,
          items: earlier,
        ),
      ]);
  }

  Future<void> _hydrate() async {
    final raw = await _snapshotRepository?.readSnapshot();
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final entries = decoded.whereType<Map>().map((rawItem) {
        final item = rawItem.map((key, value) => MapEntry('$key', value));
        final category = _NotificationCategory.values.firstWhere(
          (value) => value.name == item['category'],
          orElse: () => _NotificationCategory.general,
        );
        final style = _styleForCategory(category);
        return _NotificationEntry(
          id: item['id'] as String?,
          title: item['title'] as String? ?? '',
          subtitle: item['subtitle'] as String? ?? '',
          timeLabel: item['timeLabel'] as String? ?? '',
          icon: style.icon,
          iconBackground: Color((item['iconBackground'] as num?)?.toInt() ??
              style.background.value),
          iconColor: Color(
              (item['iconColor'] as num?)?.toInt() ?? style.foreground.value),
          unread: item['unread'] as bool? ?? false,
          accent: Color(
              (item['accent'] as num?)?.toInt() ?? style.foreground.value),
          category: category,
        );
      }).toList(growable: false);
      if (entries.isEmpty || _groups.isEmpty) return;
      _groups.first.items
        ..clear()
        ..addAll(entries);
      notifyListeners();
    } catch (_) {
      // Keep the safe bootstrap notifications when persisted data is invalid.
    }
  }

  Future<void> _persist() {
    final entries = _groups.expand((group) => group.items).map(
          (item) => <String, dynamic>{
            'title': item.title,
            if (item.id != null) 'id': item.id,
            'subtitle': item.subtitle,
            'timeLabel': item.timeLabel,
            'icon': item.icon.codePoint,
            'iconBackground': item.iconBackground.value,
            'iconColor': item.iconColor.value,
            'unread': item.unread,
            'accent': item.accent.value,
            'category': item.category.name,
          },
        );
    return _snapshotRepository?.writeSnapshot(
          jsonEncode(entries.toList(growable: false)),
        ) ??
        Future<void>.value();
  }

  void _notifyAndPersist() {
    notifyListeners();
    unawaited(_persist());
  }

  List<_NotificationGroup> get groups => _groups;

  int get unreadCount {
    return _groups
        .expand((group) => group.items)
        .where((item) => item.unread)
        .length;
  }

  List<_NotificationEntry> previewEntries({int limit = 8}) {
    return _groups
        .expand((group) => group.items)
        .take(limit)
        .toList(growable: false);
  }

  void addLowStockAlert({
    required String productName,
    required int currentStock,
    required String salesmanName,
  }) {
    if (_groups.isEmpty) return;

    _groups.first.items.insert(
      0,
      _NotificationEntry(
        title: 'স্টক কমেছে',
        subtitle:
            '$salesmanName জানিয়েছেন: $productName এর স্টক কমে $currentStock এ নেমেছে।',
        timeLabel: 'এখন',
        icon: Icons.inventory_2_rounded,
        iconBackground: const Color(0xFFD1FAE5),
        iconColor: const Color(0xFF16A34A),
        unread: true,
        accent: const Color(0xFF16A34A),
        category: _NotificationCategory.inventory,
      ),
    );

    _notifyAndPersist();
    final remote = _remote;
    if (remote != null) {
      unawaited(remote.create(
        type: 'INVENTORY',
        title: 'স্টক কমেছে',
        message:
            '$salesmanName জানিয়েছেন: $productName এর স্টক কমে $currentStock এ নেমেছে।',
      ));
    }
  }

  void addSaleTransactionAlert({
    required String transactionId,
    required String salesmanName,
    required String customerName,
    required String itemsSummary,
    required int totalAmount,
    required int paidAmount,
    required int dueAmount,
    required String paymentMethod,
    required DateTime timestamp,
  }) {
    if (_groups.isEmpty) return;

    _groups.first.items.insert(
      0,
      _NotificationEntry(
        title: 'Sale completed',
        subtitle:
            'TXN $transactionId | $salesmanName sold $customerName | $itemsSummary | Total ৳$totalAmount | $paymentMethod | Paid ৳$paidAmount | Due ৳$dueAmount',
        timeLabel:
            '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
        icon: Icons.point_of_sale_rounded,
        iconBackground: const Color(0xFFDCEBFF),
        iconColor: const Color(0xFF1D4ED8),
        unread: true,
        accent: const Color(0xFF1D4ED8),
        category: _NotificationCategory.sale,
      ),
    );

    _notifyAndPersist();
    final remote = _remote;
    if (remote != null) {
      unawaited(remote.create(
        type: 'SALE',
        title: 'Sale completed',
        message:
            'TXN $transactionId | $salesmanName sold $customerName | $itemsSummary | Total ৳$totalAmount | $paymentMethod | Paid ৳$paidAmount | Due ৳$dueAmount',
      ));
    }
  }

  void removeLowStockAlert(String productName) {
    if (_groups.isEmpty) return;

    final target = productName.trim().toLowerCase();
    var changed = false;
    for (final group in _groups) {
      final before = group.items.length;
      group.items.removeWhere(
        (item) =>
            item.category == _NotificationCategory.inventory &&
            item.title == 'Low stock alert' &&
            item.subtitle.toLowerCase().contains(target),
      );
      if (group.items.length != before) {
        changed = true;
      }
    }
    if (changed) {
      _notifyAndPersist();
    }
  }

  void markAsRead(_NotificationEntry target) {
    var changed = false;
    for (final group in _groups) {
      for (var i = 0; i < group.items.length; i++) {
        final item = group.items[i];
        if (identical(item, target) && item.unread) {
          group.items[i] = item.copyWith(unread: false);
          changed = true;
        }
      }
    }
    if (changed) {
      _notifyAndPersist();
      final id = target.id;
      if (id != null && id.isNotEmpty) {
        unawaited(_remote?.markAsRead(id));
      }
    }
  }

  void markAllAsRead() {
    var changed = false;
    for (final group in _groups) {
      for (var i = 0; i < group.items.length; i++) {
        final item = group.items[i];
        if (item.unread) {
          group.items[i] = item.copyWith(unread: false);
          changed = true;
        }
      }
    }
    if (changed) {
      _notifyAndPersist();
      unawaited(_remote?.markAllAsRead());
    }
  }

  void deleteNotification(_NotificationEntry target) {
    var changed = false;
    for (final group in _groups) {
      final before = group.items.length;
      group.items.removeWhere((item) => identical(item, target));
      changed = changed || before != group.items.length;
    }
    if (changed) {
      _notifyAndPersist();
      final id = target.id;
      if (id != null && id.isNotEmpty) {
        unawaited(_remote?.delete(id));
      }
    }
  }

  void savePreferences(_DokanNotificationPreferences prefs) {
    notifyListeners();
    unawaited(_remote?.updatePreferences(prefs.toJson()));
  }

  void handleIncomingSocketNotification(Map<String, dynamic> json) {
    try {
      final entry = _remoteEntryFromJson(json);
      final exists =
          _groups.expand((g) => g.items).any((item) => item.id == entry.id);
      if (exists) return;

      if (_groups.isEmpty) {
        _groups.add(
          _NotificationGroup(
            title: 'Recent',
            style: _SectionStyle.primary,
            items: [entry],
          ),
        );
      } else {
        _groups.first.items.insert(0, entry);
      }

      _notifyAndPersist();
    } catch (e) {
      debugPrint('[SOCKET] Failed to handle incoming socket notification: $e');
    }
  }

  _NotificationEntry _remoteEntryFromJson(Map<String, dynamic> json) {
    final title = _string(json, const ['title', 'heading', 'name']);
    final body = _string(json, const ['body', 'message', 'subtitle', 'text']);
    final categoryValue = _string(
      json,
      const ['category', 'type', 'event', 'event_type'],
    ).toLowerCase();
    final category = _categoryFromRemote(categoryValue);
    final createdAt = DateTime.tryParse(
      _string(json, const ['createdAt', 'created_at', 'time', 'timestamp']),
    )?.toLocal();
    final readAt = _string(json, const ['readAt', 'read_at']);
    final unread = json['unread'] is bool
        ? json['unread'] as bool
        : readAt.isEmpty && json['read'] != true && json['isRead'] != true;
    final colors = _styleForCategory(category);
    return _NotificationEntry(
      id: _string(json, const ['id', 'uuid', 'notificationId']),
      title: title.isEmpty ? 'Notification' : title,
      subtitle: body,
      timeLabel: _timeLabel(createdAt),
      icon: colors.icon,
      iconBackground: colors.background,
      iconColor: colors.foreground,
      unread: unread,
      accent: colors.foreground,
      category: category,
    );
  }

  static String _string(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) return '$value';
    }
    return '';
  }

  static _NotificationCategory _categoryFromRemote(String value) {
    if (value.contains('sale') || value.contains('payment')) {
      return _NotificationCategory.sale;
    }
    if (value.contains('stock') ||
        value.contains('inventory') ||
        value.contains('expiry')) {
      return _NotificationCategory.inventory;
    }
    if (value.contains('report')) return _NotificationCategory.report;
    return _NotificationCategory.general;
  }

  static _RemoteNotificationStyle _styleForCategory(
    _NotificationCategory category,
  ) {
    return switch (category) {
      _NotificationCategory.sale => const _RemoteNotificationStyle(
          icon: Icons.point_of_sale_rounded,
          background: Color(0xFFDCEBFF),
          foreground: Color(0xFF1D4ED8),
        ),
      _NotificationCategory.inventory => const _RemoteNotificationStyle(
          icon: Icons.inventory_2_rounded,
          background: Color(0xFFD1FAE5),
          foreground: Color(0xFF16A34A),
        ),
      _NotificationCategory.report => const _RemoteNotificationStyle(
          icon: Icons.assessment_rounded,
          background: Color(0xFFE2F3E8),
          foreground: Color(0xFF0E7B58),
        ),
      _ => const _RemoteNotificationStyle(
          icon: Icons.notifications_rounded,
          background: Color(0xFFE8F1FF),
          foreground: Color(0xFF2563EB),
        ),
    };
  }

  static String _timeLabel(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }
}

class _RemoteNotificationStyle {
  const _RemoteNotificationStyle({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
}

class DokanNotificationCenterScreen extends StatefulWidget {
  const DokanNotificationCenterScreen({super.key});

  @override
  State<DokanNotificationCenterScreen> createState() =>
      _DokanNotificationCenterScreenState();
}

class _DokanNotificationCenterScreenState
    extends State<DokanNotificationCenterScreen> {
  List<_NotificationGroup> get _groups => _dokanNotificationStore.groups;

  final List<_FilterChipData> _filters = const [
    _FilterChipData(
        label: 'সব', selected: true, category: _NotificationCategory.all),
    _FilterChipData(
        label: 'অপঠিত',
        selected: false,
        category: _NotificationCategory.unread),
    _FilterChipData(
        label: 'বিক্রয়', selected: false, category: _NotificationCategory.sale),
    _FilterChipData(
        label: 'স্টক',
        selected: false,
        category: _NotificationCategory.inventory),
    _FilterChipData(
        label: 'রিপোর্ট',
        selected: false,
        category: _NotificationCategory.report),
  ];

  int _selectedFilterIndex = 0;
  final _DokanNotificationPreferences _prefs = _dokanNotificationPreferences;
  bool _remoteAttached = false;

  @override
  void initState() {
    super.initState();
    _dokanNotificationStore.addListener(_handleStoreChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_remoteAttached) return;
    _remoteAttached = true;
    final container = ProviderScope.containerOf(context, listen: false);
    _dokanNotificationStore.attachRemote(
      container.read(notificationRepositoryProvider),
    );
  }

  @override
  void dispose() {
    _dokanNotificationStore.removeListener(_handleStoreChanged);
    super.dispose();
  }

  void _handleStoreChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _HeaderBar(
              onBack: () => Navigator.of(context).pop(),
              onMarkAllRead: _markAllAsRead,
            ),
            _FilterStrip(
              selectedIndex: _selectedFilterIndex,
              filters: _filters,
              onSelected: (index) {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_visibleGroups().isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_off_outlined,
                                size: 54,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'কোনো নোটিফিকেশন নেই',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      for (final group in _visibleGroups()) ...[
                        _NotificationGroupView(
                          group: group,
                          onItemTap: (item) => _openNotification(context, item),
                        ),
                        const SizedBox(height: 16),
                      ],
                    _UpdatePromoCard(
                      onTap: () => _showInfoSheet(
                        context,
                        title: 'নতুন আপডেট!',
                        message:
                            'এখন আরও দ্রুত নোটিফিকেশন দেখা, পড়া এবং ফিল্টার করা যাবে।',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _NotificationPreferencesCard(
                      prefs: _prefs,
                      onChanged: () {
                        _dokanNotificationStore.savePreferences(_prefs);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _BottomNavBar(
              onHomeTap: () => Navigator.of(context).pushReplacementNamed(
                AppRoutes.dashboard,
              ),
              onSalesTap: () =>
                  Navigator.of(context).pushReplacementNamed(AppRoutes.sales),
              onProductsTap: () => Navigator.of(context).pushReplacementNamed(
                AppRoutes.products,
              ),
              onReportsTap: () => Navigator.of(context).pushReplacementNamed(
                AppRoutes.reports,
              ),
              onMoreTap: () => Navigator.of(context).pushReplacementNamed(
                AppRoutes.settings,
              ),
              bottomPadding: bottomPadding,
            ),
          ],
        ),
      ),
    );
  }

  List<_NotificationGroup> _visibleGroups() {
    final selectedCategory = _filters[_selectedFilterIndex].category;

    if (selectedCategory == _NotificationCategory.unread) {
      return _groups
          .map(
            (group) => _NotificationGroup(
              title: group.title,
              style: group.style,
              items: group.items.where((item) => item.unread).toList(),
            ),
          )
          .where((group) => group.items.isNotEmpty)
          .toList();
    }
    if (selectedCategory != _NotificationCategory.all) {
      return _groups
          .map(
            (group) => _NotificationGroup(
              title: group.title,
              style: group.style,
              items: group.items
                  .where((item) => item.category == selectedCategory)
                  .toList(),
            ),
          )
          .where((group) => group.items.isNotEmpty)
          .toList();
    }
    return _groups.where((group) => group.items.isNotEmpty).toList();
  }

  void _markAllAsRead() {
    _dokanNotificationStore.markAllAsRead();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('সব নোটিফিকেশন পড়া হয়েছে'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openNotification(BuildContext context, _NotificationEntry item) async {
    await _openDokanNotification(context, item);
    setState(() {});
  }

  void _showInfoSheet(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _InfoSheet(title: title, message: message);
      },
    );
  }
}

Future<void> _openDokanNotification(BuildContext context, _NotificationEntry item) async {
  _dokanNotificationStore.markAsRead(item);

  String? productName;
  final isStockAlert = item.title.contains('স্টক') ||
      item.title.contains('Stock') ||
      item.subtitle.contains('স্টক কমে');

  if (isStockAlert) {
    final cleanMessage = item.subtitle.replaceAll('\n', ' ');
    final colonIndex = cleanMessage.indexOf(':');
    if (colonIndex != -1) {
      final rightPart = cleanMessage.substring(colonIndex + 1).trim();
      final nameParts = rightPart.split(' এর স্টক কমে');
      if (nameParts.isNotEmpty) {
        productName = nameParts[0].trim();
      }
    }
  }

  DokanCatalogProduct? product;
  if (productName != null) {
    final container = ProviderScope.containerOf(context, listen: false);
    final catalog = container.read(dokanInventoryCatalogProvider);
    for (final p in catalog) {
      if (p.name.trim().toLowerCase() == productName.toLowerCase()) {
        product = p;
        break;
      }
    }
  }

  if (product != null) {
    final container = ProviderScope.containerOf(context, listen: false);
    final dynamic result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DokanProductStockAddScreen(product: product!),
      ),
    );

    if (result != null) {
      try {
        await container.read(productInventoryGatewayProvider).adjustStock(
              barcode: product.barcode,
              amount: result.addAmount as int,
              referenceText: result.referenceText as String,
              note: result.note as String,
              purchasePrice: result.purchasePrice as int,
            );
        container.invalidate(productStockHistoryProvider(product.barcode));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} এর স্টক সফলভাবে রিস্টোর করা হয়েছে।'),
              backgroundColor: const Color(0xFF00694C),
            ),
          );
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('স্টক সার্ভারে সংরক্ষণ করা যায়নি'),
            ),
          );
        }
      }
    }
    return;
  }

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return _NotificationDetailSheet(
        title: item.title,
        subtitle: item.subtitle,
        timeLabel: item.timeLabel,
        accent: item.accent,
        icon: item.icon,
        onDelete: () {
          Navigator.of(context).pop();
          _dokanNotificationStore.deleteNotification(item);
        },
      );
    },
  );
}
