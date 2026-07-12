part of '../notification_center_screen.dart';

class _PreferenceToggleRow extends StatelessWidget {
  const _PreferenceToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: const Color(0xFF00694C),
      title: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF131D21),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DokanNotificationPreferences {
  bool lowStockAlert = true;
  bool newSale = true;
  bool newCustomer = true;
  bool paymentReceived = true;
  bool dailyReport = false;
  bool weeklyReport = false;
  bool staffActivity = true;
  bool systemUpdate = true;
  bool sound = true;
  bool vibration = true;
  bool pushNotification = true;
  bool email = false;
  bool sms = false;

  int get unreadCount => 3;

  Map<String, dynamic> toJson() {
    return {
      'events': {
        'low_stock': lowStockAlert,
        'new_sale': newSale,
        'new_customer': newCustomer,
        'payment_received': paymentReceived,
        'daily_report': dailyReport,
        'weekly_report': weeklyReport,
        'staff_activity': staffActivity,
        'system_update': systemUpdate,
      },
      'channels': {
        'push': pushNotification,
        'email': email,
        'sms': sms,
        'sound': sound,
        'vibration': vibration,
      },
    };
  }

  void applyJson(Map<String, dynamic> json) {
    final events = _object(json['events']) ?? json;
    final channels = _object(json['channels']) ?? json;
    lowStockAlert =
        _bool(events, const ['low_stock', 'lowStockAlert'], lowStockAlert);
    newSale = _bool(events, const ['new_sale', 'newSale'], newSale);
    newCustomer =
        _bool(events, const ['new_customer', 'newCustomer'], newCustomer);
    paymentReceived = _bool(
        events, const ['payment_received', 'paymentReceived'], paymentReceived);
    dailyReport =
        _bool(events, const ['daily_report', 'dailyReport'], dailyReport);
    weeklyReport =
        _bool(events, const ['weekly_report', 'weeklyReport'], weeklyReport);
    staffActivity =
        _bool(events, const ['staff_activity', 'staffActivity'], staffActivity);
    systemUpdate =
        _bool(events, const ['system_update', 'systemUpdate'], systemUpdate);
    pushNotification =
        _bool(channels, const ['push', 'pushNotification'], pushNotification);
    email = _bool(channels, const ['email'], email);
    sms = _bool(channels, const ['sms'], sms);
    sound = _bool(channels, const ['sound'], sound);
    vibration = _bool(channels, const ['vibration'], vibration);
  }

  static Map<String, dynamic>? _object(Object? value) {
    if (value is! Map) return null;
    return value.map((key, item) => MapEntry('$key', item));
  }

  static bool _bool(
    Map<String, dynamic> json,
    List<String> keys,
    bool fallback,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value != null) {
        return switch ('$value'.toLowerCase()) {
          'true' || '1' || 'yes' => true,
          'false' || '0' || 'no' => false,
          _ => fallback,
        };
      }
    }
    return fallback;
  }
}

class _FilterChipData {
  const _FilterChipData({
    required this.label,
    required this.selected,
    required this.category,
  });

  final String label;
  final bool selected;
  final _NotificationCategory category;
}

class _NotificationGroup {
  _NotificationGroup({
    required this.title,
    required this.style,
    required this.items,
  });

  final String title;
  final _SectionStyle style;
  final List<_NotificationEntry> items;
}

class _NotificationEntry {
  _NotificationEntry({
    this.id,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.unread,
    required this.accent,
    required this.category,
  });

  final String? id;
  final String title;
  final String subtitle;
  final String timeLabel;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final bool unread;
  final Color accent;
  final _NotificationCategory category;

  _NotificationEntry copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? timeLabel,
    IconData? icon,
    Color? iconBackground,
    Color? iconColor,
    bool? unread,
    Color? accent,
    _NotificationCategory? category,
  }) {
    return _NotificationEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      timeLabel: timeLabel ?? this.timeLabel,
      icon: icon ?? this.icon,
      iconBackground: iconBackground ?? this.iconBackground,
      iconColor: iconColor ?? this.iconColor,
      unread: unread ?? this.unread,
      accent: accent ?? this.accent,
      category: category ?? this.category,
    );
  }
}

enum _NotificationCategory {
  all,
  unread,
  sale,
  inventory,
  report,
  general,
}

enum _SectionStyle {
  primary,
  secondary;

  Color get headingColor =>
      this == primary ? const Color(0xFF3D4943) : const Color(0xFF3D4943);
}

class _RowStyle {
  const _RowStyle({
    required this.backgroundColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.timeColor,
    required this.titleWeight,
  });

  final Color backgroundColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color timeColor;
  final FontWeight titleWeight;

  static const primary = _RowStyle(
    backgroundColor: Color(0xFFF4FAF7),
    titleColor: Color(0xFF131D21),
    subtitleColor: Color(0xFF3D4943),
    timeColor: Color(0xFF6D7A73),
    titleWeight: FontWeight.w400,
  );

  static const secondary = _RowStyle(
    backgroundColor: Colors.transparent,
    titleColor: Color(0xFF131D21),
    subtitleColor: Color(0xFF3D4943),
    timeColor: Color(0xFF6D7A73),
    titleWeight: FontWeight.w700,
  );
}
