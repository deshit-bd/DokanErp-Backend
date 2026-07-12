part of '../notification_center_screen.dart';

class _NotificationDetailSheet extends ConsumerWidget {
  const _NotificationDetailSheet({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.accent,
    required this.icon,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final Color accent;
  final IconData icon;
  final VoidCallback onDelete;

  static String _toBn(String input) {
    const digits = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
    };
    return input.split('').map((char) => digits[char] ?? char).join();
  }

  void _showRestockDialog(
    BuildContext context,
    WidgetRef ref,
    DokanCatalogProduct product,
  ) {
    final amountController = TextEditingController(text: '10');
    final priceController =
        TextEditingController(text: product.purchasePrice.toString());

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            '${product.name} রিস্টোর করুন',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('বর্তমান স্টক: ${_toBn(product.stock.toString())} টি'),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'নতুন স্টক পরিমাণ',
                  border: OutlineInputBorder(),
                  suffixText: 'টি',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                readOnly: !ref.read(dokanAppFlowProvider).can(DokanPermission.settingsManage),
                decoration: const InputDecoration(
                  labelText: 'ক্রয় মূল্য (প্রতিটি)',
                  border: OutlineInputBorder(),
                  prefixText: '৳',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(amountController.text.trim()) ?? 0;
                final price = int.tryParse(priceController.text.trim()) ??
                    product.purchasePrice;
                if (amount > 0) {
                  ref
                      .read(dokanInventoryCatalogProvider.notifier)
                      .applyStockAdd(
                        product,
                        addAmount: amount,
                        purchasePrice: price,
                        referenceText: 'restore-from-alert',
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${product.name} এর স্টক ${_toBn(amount.toString())} টি বাড়ানো হয়েছে।'),
                      backgroundColor: const Color(0xFF00694C),
                    ),
                  );
                }
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00694C),
                foregroundColor: Colors.white,
              ),
              child: const Text('নিশ্চিত করুন'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? productName;
    final cleanMessage = subtitle.replaceAll('\n', ' ');
    final parts = cleanMessage.split(RegExp(r'জani(?:য়ে|য়ে)ছেন:\s*|জানি(?:য়ে|য়ে)ছেন:\s*'));
    if (parts.length > 1) {
      final rightPart = parts[1];
      final nameParts = rightPart.split(' এর স্টক কমে');
      if (nameParts.isNotEmpty) {
        productName = nameParts[0].trim();
      }
    }

    DokanCatalogProduct? product;
    if (productName != null) {
      final catalog = ref.watch(dokanInventoryCatalogProvider);
      for (final p in catalog) {
        if (p.name.trim().toLowerCase() == productName.toLowerCase()) {
          product = p;
          break;
        }
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5FAF7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD9E3DF),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF131D21),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6D7A73),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: Color(0xFF3D4943),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (product != null) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showRestockDialog(context, ref, product!);
                    },
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: const Text(
                      'রিস্টোর করুন',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00694C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'ঠিক আছে',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSheet extends StatelessWidget {
  const _InfoSheet({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5FAF7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD9E3DF),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF131D21),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: Color(0xFF3D4943),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00694C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'ঠিক আছে',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationPreferencesCard extends StatelessWidget {
  const _NotificationPreferencesCard({
    required this.prefs,
    required this.onChanged,
  });

  final _DokanNotificationPreferences prefs;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0E9E4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
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
            const Text(
              'নোটিফিকেশন সেটিংস',
              style: TextStyle(
                color: Color(0xFF131D21),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'আপনার পছন্দমতো সতর্কতা নিয়ন্ত্রণ করুন',
              style: TextStyle(
                color: Color(0xFF5F6E68),
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            _PreferenceToggleRow(
              label: 'কম স্টক হলে সতর্ক করুন',
              value: prefs.lowStockAlert,
              onChanged: (value) {
                prefs.lowStockAlert = value;
                onChanged();
              },
            ),
            _PreferenceToggleRow(
              label: 'নতুন বিক্রয়',
              value: prefs.newSale,
              onChanged: (value) {
                prefs.newSale = value;
                onChanged();
              },
            ),
            _PreferenceToggleRow(
              label: 'নতুন গ্রাহক',
              value: prefs.newCustomer,
              onChanged: (value) {
                prefs.newCustomer = value;
                onChanged();
              },
            ),
            _PreferenceToggleRow(
              label: 'পেমেন্ট গ্রহণ',
              value: prefs.paymentReceived,
              onChanged: (value) {
                prefs.paymentReceived = value;
                onChanged();
              },
            ),
            _PreferenceToggleRow(
              label: 'দৈনিক রিপোর্ট',
              value: prefs.dailyReport,
              onChanged: (value) {
                prefs.dailyReport = value;
                onChanged();
              },
            ),
            _PreferenceToggleRow(
              label: 'সাপ্তাহিক রিপোর্ট',
              value: prefs.weeklyReport,
              onChanged: (value) {
                prefs.weeklyReport = value;
                onChanged();
              },
            ),
            _PreferenceToggleRow(
              label: 'স্টাফ কার্যক্রম',
              value: prefs.staffActivity,
              onChanged: (value) {
                prefs.staffActivity = value;
                onChanged();
              },
            ),
            _PreferenceToggleRow(
              label: 'সিস্টেম আপডেট',
              value: prefs.systemUpdate,
              onChanged: (value) {
                prefs.systemUpdate = value;
                onChanged();
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'শব্দ সেটিংস',
              style: TextStyle(
                color: Color(0xFF131D21),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _PreferenceToggleRow(
              label: 'সাউন্ড',
              value: prefs.sound,
              onChanged: (value) {
                prefs.sound = value;
                onChanged();
              },
            ),
            _PreferenceToggleRow(
              label: 'ভাইব্রেশন',
              value: prefs.vibration,
              onChanged: (value) {
                prefs.vibration = value;
                onChanged();
              },
            ),
            _PreferenceToggleRow(
              label: 'পুশ নোটিফিকেশন',
              value: prefs.pushNotification,
              onChanged: (value) {
                prefs.pushNotification = value;
                onChanged();
              },
            ),
            _PreferenceToggleRow(
              label: 'ইমেইল',
              value: prefs.email,
              onChanged: (value) {
                prefs.email = value;
                onChanged();
              },
            ),
            _PreferenceToggleRow(
              label: 'এসএমএস',
              value: prefs.sms,
              onChanged: (value) {
                prefs.sms = value;
                onChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}
