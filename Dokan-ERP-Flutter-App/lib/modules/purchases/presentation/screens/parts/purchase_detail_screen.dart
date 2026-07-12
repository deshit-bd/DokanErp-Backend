part of '../purchase_screens.dart';

class DokanPurchaseDetailScreen extends ConsumerStatefulWidget {
  const DokanPurchaseDetailScreen({super.key, required this.order});

  final PurchaseOrder order;

  @override
  ConsumerState<DokanPurchaseDetailScreen> createState() =>
      _DokanPurchaseDetailScreenState();
}

class _DokanPurchaseDetailScreenState
    extends ConsumerState<DokanPurchaseDetailScreen> {
  bool _submitting = false;
  bool _inventoryLoading = true;
  bool _advancedInventoryMode = false;
  String? _inventoryLoadError;
  List<_InventoryZoneOption> _inventoryZones = const [];

  bool get _hasInventoryBins => _inventoryZones.any(
        (zone) => zone.racks.any(
          (rack) => rack.shelves.any((shelf) => shelf.bins.isNotEmpty),
        ),
      );

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadInventoryContext);
  }

  Future<void> _receiveOrder() async {
    final receiveResult = await _showReceiveDialog();
    if (receiveResult == null || receiveResult.lines.isEmpty) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(purchaseOrderProvider.notifier).recordReceipt(
            widget.order.id,
            receiveResult.lines,
            placements: receiveResult.placements,
            paidAmount: receiveResult.paidAmount,
            paymentMethod: receiveResult.paymentMethod,
            paymentDetails: receiveResult.paymentDetails,
          );
      await ref
          .read(dokanInventoryCatalogProvider.notifier)
          .refreshFromRepository();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('ক্রয় সফলভাবে রিসিভ করা হয়েছে এবং স্টক বাড়ানো হয়েছে।'),
            backgroundColor: Color(0xFF0E8F5F),
          ),
        );
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const DokanReportsDashboardScreen(
              initialFilter: DokanReportTimeFilter.thisMonth,
              initialBreakdownTab: 1,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ত্রুটি: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _showReturnDialog() async {
    final order = widget.order;
    final controllers = <String, TextEditingController>{};
    for (final line in order.lines) {
      controllers[line.productId] = TextEditingController(text: '0');
    }

    String refundMethod = 'ADJUST_WITH_DUE';
    final notesController = TextEditingController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6E3E1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Icon(Icons.keyboard_return, color: Color(0xFFE15241)),
                          const SizedBox(width: 8),
                          Text(
                            'ক্রয় ফেরত (Purchase Return)',
                            style: TextStyle(
                              color: Color(0xFF16302E),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...order.lines.map((line) {
                        final effectiveReceived = line.receivedQuantity > 0
                            ? line.receivedQuantity
                            : line.orderedQuantity;
                        final maxReturnable =
                            effectiveReceived - line.returnedQuantity;
                        if (maxReturnable <= 0) return const SizedBox.shrink();

                        final controller = controllers[line.productId]!;
                        int currentVal = int.tryParse(controller.text) ?? 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE8EFEF)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      line.productName,
                                      style: const TextStyle(
                                        color: Color(0xFF16302E),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'রিসিভড: ${_bn(effectiveReceived)} | ফেরত দেওয়া হয়েছে: ${_bn(line.returnedQuantity)}',
                                      style: const TextStyle(
                                        color: Color(0xFF5A7572),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        // ignore: deprecated_member_use
                                      ),
                                    ),
                                    Text(
                                      'সর্বোচ্চ ফেরতযোগ্য: ${_bn(maxReturnable)} টি',
                                      style: const TextStyle(
                                        color: Color(0xFFE15241),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: currentVal <= 0
                                        ? null
                                        : () {
                                            setSheetState(() {
                                              controller.text =
                                                  (currentVal - 1).toString();
                                            });
                                          },
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    color: const Color(0xFFE15241),
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      inputFormatters:
                                          NumericInputFormatters.wholeNumber,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (val) {
                                        final entered = int.tryParse(val) ?? 0;
                                        if (entered > maxReturnable) {
                                          setSheetState(() {
                                            controller.text =
                                                maxReturnable.toString();
                                          });
                                        } else if (entered < 0) {
                                          setSheetState(() {
                                            controller.text = '0';
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: currentVal >= maxReturnable
                                        ? null
                                        : () {
                                            setSheetState(() {
                                              controller.text =
                                                  (currentVal + 1).toString();
                                            });
                                          },
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: const Color(0xFF0E8F5F),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      const Text(
                        'ফেরত নেওয়ার মাধ্যম',
                        style: TextStyle(
                          color: Color(0xFF16302E),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE8EFEF)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: refundMethod,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'ADJUST_WITH_DUE',
                                child: Text('বকেয়া সমন্বয় (Adjust with Due)',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700)),
                              ),
                              DropdownMenuItem(
                                value: 'CASH',
                                child: Text('নগদ ফেরত (Cash Refund)',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setSheetState(() {
                                  refundMethod = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'নোট / কারণ',
                        style: TextStyle(
                          color: Color(0xFF16302E),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'ফেরত দেওয়ার কারণ লিখুন (ঐচ্ছিক)',
                          hintStyle: const TextStyle(
                              color: Color(0xFF94A8A6), fontSize: 13),
                          fillColor: const Color(0xFFF8FAFA),
                          filled: true,
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                const BorderSide(color: Color(0xFFE8EFEF)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                const BorderSide(color: Color(0xFFE8EFEF)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE15241),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('নিশ্চিত করুন',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (result != true) return;

    final returnItems = <Map<String, dynamic>>[];
    for (final line in order.lines) {
      final controller = controllers[line.productId]!;
      final qty = int.tryParse(controller.text.trim()) ?? 0;
      if (qty > 0) {
        returnItems.add({
          'purchaseItemId': line.purchaseItemId.isNotEmpty
              ? line.purchaseItemId
              : line.productId,
          'quantity': qty,
          'reason': notesController.text.trim().isNotEmpty
              ? notesController.text.trim()
              : null,
        });
      }
    }

    if (returnItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অন্তত একটি পণ্যের ফেরত সংখ্যা নির্ধারণ করুন।'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(purchaseOrderProvider.notifier).recordReturn(
            order.id,
            returnItems,
            refundMethod: refundMethod,
            notes: notesController.text.trim().isNotEmpty
                ? notesController.text.trim()
                : null,
          );
      await ref
          .read(dokanInventoryCatalogProvider.notifier)
          .refreshFromRepository();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ক্রয় ফেরত সফলভাবে সম্পন্ন হয়েছে।'),
            backgroundColor: Color(0xFF0E8F5F),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ত্রুটি: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _loadInventoryContext() async {
    try {
      final repo = ref.read(inventoryLayoutRepositoryProvider);
      final modePayload = await repo.getInventoryMode();
      final layoutPayload = await repo.getLayoutTree();
      final zones = (layoutPayload['zones'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (zone) => _InventoryZoneOption.fromJson(
              zone.map((key, value) => MapEntry('$key', value)),
            ),
          )
          .where((zone) => zone.id.isNotEmpty)
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _advancedInventoryMode =
            '${modePayload['mode'] ?? 'GENERAL'}'.trim().toUpperCase() ==
                'RACK';
        _inventoryZones = zones;
        _inventoryLoading = false;
        _inventoryLoadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _inventoryLoading = false;
        _inventoryLoadError = error.toString();
      });
    }
  }

  Future<_PurchaseReceiveDialogResult?> _showReceiveDialog() async {
    final physicalControllers = <TextEditingController>[];
    final buyingControllers = <TextEditingController>[];
    final sellingControllers = <TextEditingController>[];
    final batchControllers = <TextEditingController>[];
    for (final line in widget.order.lines) {
      physicalControllers.add(TextEditingController(
        text: line.receivedQuantity > 0
            ? line.receivedQuantity.toString()
            : line.orderedQuantity.toString(),
      ));
      buyingControllers
          .add(TextEditingController(text: line.unitCost.toString()));
      sellingControllers
          .add(TextEditingController(text: line.unitCost.toString()));
      batchControllers.add(TextEditingController(
          text: line.purchaseItemId.isNotEmpty ? '1' : '1'));
    }

    String paymentMethod = 'CASH';
    final paidAmountController = TextEditingController();
    final senderNumberController = TextEditingController();
    final transactionIdController = TextEditingController();
    bool hasCustomPaidAmount = false;

    int calculateTotalReceiveAmount() {
      int sum = 0;
      for (int i = 0; i < widget.order.lines.length; i++) {
        final qty = int.tryParse(physicalControllers[i].text.trim()) ?? 0;
        final unitCost = int.tryParse(buyingControllers[i].text.trim()) ??
            widget.order.lines[i].unitCost;
        sum += qty * unitCost;
      }
      return sum;
    }

    paidAmountController.text = calculateTotalReceiveAmount().toString();

    _InventoryZoneOption? zoneById(String? zoneId) {
      for (final zone in _inventoryZones) {
        if (zone.id == zoneId) {
          return zone;
        }
      }
      return null;
    }

    _InventoryRackOption? rackById(_InventoryZoneOption? zone, String? rackId) {
      if (zone == null) return null;
      for (final rack in zone.racks) {
        if (rack.id == rackId) {
          return rack;
        }
      }
      return null;
    }

    _InventoryShelfOption? shelfById(
        _InventoryRackOption? rack, String? shelfId) {
      if (rack == null) return null;
      for (final shelf in rack.shelves) {
        if (shelf.id == shelfId) {
          return shelf;
        }
      }
      return null;
    }

    _InventoryZoneOption? firstZone;
    _InventoryRackOption? firstRack;
    _InventoryShelfOption? firstShelf;
    _InventoryBinOption? firstBin;
    for (final zone in _inventoryZones) {
      for (final rack in zone.racks) {
        for (final shelf in rack.shelves) {
          if (shelf.bins.isNotEmpty) {
            firstZone = zone;
            firstRack = rack;
            firstShelf = shelf;
            firstBin = shelf.bins.first;
            break;
          }
        }
        if (firstBin != null) {
          break;
        }
      }
      if (firstBin != null) {
        break;
      }
    }

    final selectedZoneIds = List<String?>.filled(
      widget.order.lines.length,
      firstZone?.id,
    );
    final selectedRackIds = List<String?>.filled(
      widget.order.lines.length,
      firstRack?.id,
    );
    final selectedShelfIds = List<String?>.filled(
      widget.order.lines.length,
      firstShelf?.id,
    );
    final selectedBinIds = List<String?>.filled(
      widget.order.lines.length,
      firstBin?.id,
    );

    try {
      return await showModalBottomSheet<_PurchaseReceiveDialogResult>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return SafeArea(
            child: StatefulBuilder(
              builder: (context, setSheetState) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.88,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9E6E2),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'পণ্য গ্রহণ করুন',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF16302E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _advancedInventoryMode
                                  ? 'প্রকৃত সংখ্যা, বিক্রয় মূল্য এবং Zone, Rack, Shelf, Bin নির্বাচন করুন।'
                                  : 'প্রতিটি পণ্যের জন্য প্রকৃত সংখ্যা এবং বিক্রয় মূল্য লিখুন।',
                              style: const TextStyle(
                                color: Color(0xFF71827F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      if (_inventoryLoadError != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4E5),
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: const Color(0xFFF6D3A6)),
                            ),
                            child: Text(
                              'স্টোরেজ ডেটা লোড করতে সমস্যা হয়েছে: $_inventoryLoadError',
                              style: const TextStyle(
                                color: Color(0xFF9A5B00),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      if (_advancedInventoryMode)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1FBF6),
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: const Color(0xFFB7E7D3)),
                            ),
                            child: Text(
                              _inventoryLoading
                                  ? 'স্টোরেজ লেআউট লোড হচ্ছে...'
                                  : 'Advanced mode সক্রিয়: প্রতিটি পণ্যের জন্য Zone → Rack → Shelf → Bin নির্বাচন করুন।',
                              style: const TextStyle(
                                color: Color(0xFF0D6B55),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          itemCount: widget.order.lines.length + 1,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final totalReceiveAmount =
                                calculateTotalReceiveAmount();
                            int paidAmountValue = 0;
                            if (paymentMethod != 'DUE') {
                              final text = paidAmountController.text.trim();
                              paidAmountValue = int.tryParse(text) ?? 0;
                            }
                            final dueAmountValue =
                                (totalReceiveAmount - paidAmountValue) < 0
                                    ? 0
                                    : (totalReceiveAmount - paidAmountValue);

                            if (index == widget.order.lines.length) {
                              const activeColor = Color(0xFF0D6B55);
                              const borderColor = Color(0xFFE2EBE8);

                              Widget buildMethodChip(
                                  String method, String label, IconData icon) {
                                final active = paymentMethod == method;
                                return ChoiceChip(
                                  label: Text(label),
                                  selected: active,
                                  onSelected: (val) {
                                    if (val) {
                                      setSheetState(() {
                                        paymentMethod = method;
                                        if (method == 'DUE') {
                                          paidAmountController.text = '0';
                                          hasCustomPaidAmount = true;
                                        } else {
                                          paidAmountController.text =
                                              totalReceiveAmount.toString();
                                          hasCustomPaidAmount = false;
                                        }
                                      });
                                    }
                                  },
                                  selectedColor: activeColor,
                                  backgroundColor: const Color(0xFFF8FBFA),
                                  labelStyle: TextStyle(
                                    color: active
                                        ? Colors.white
                                        : const Color(0xFF71827F),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: active
                                          ? activeColor
                                          : const Color(0xFFE2EBE8),
                                    ),
                                  ),
                                  showCheckmark: false,
                                  avatar: Icon(
                                    icon,
                                    size: 16,
                                    color: active
                                        ? Colors.white
                                        : const Color(0xFF71827F),
                                  ),
                                );
                              }

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          activeColor.withValues(alpha: 0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.payment_rounded,
                                            color: activeColor),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'পেমেন্ট বিবরণ',
                                          style: TextStyle(
                                            color: Color(0xFF16302E),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'পেমেন্ট পদ্ধতি নির্বাচন করুন',
                                      style: TextStyle(
                                        color: Color(0xFF71827F),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        buildMethodChip(
                                            'CASH', 'নগদ', Icons.money_rounded),
                                        buildMethodChip('DUE', 'বাকি / বকেয়া',
                                            Icons.schedule_rounded),
                                        buildMethodChip('BKASH', 'বিকাশ',
                                            Icons.mobile_screen_share_rounded),
                                        buildMethodChip('NAGAD', 'নগদ (MFS)',
                                            Icons.mobile_screen_share_rounded),
                                        buildMethodChip('ROCKET', 'রকেট',
                                            Icons.mobile_screen_share_rounded),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (paymentMethod != 'DUE') ...[
                                      TextField(
                                        controller: paidAmountController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters:
                                            NumericInputFormatters.wholeNumber,
                                        cursorColor: activeColor,
                                        style: const TextStyle(
                                          color: Color(0xFF16302E),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'পরিশোধিত টাকা',
                                          hintText: '০',
                                          prefixText: '৳ ',
                                          prefixStyle: TextStyle(
                                            color: activeColor,
                                            fontWeight: FontWeight.w900,
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFFF8FBFA),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 14),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide:
                                                BorderSide(color: borderColor),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide:
                                                BorderSide(color: borderColor),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                                color: activeColor, width: 1.4),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          hasCustomPaidAmount = true;
                                          setSheetState(() {});
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FBFA),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'বাকি থাকবে (বকেয়া):',
                                            style: TextStyle(
                                              color: Color(0xFF71827F),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            '৳ ${_bn(dueAmountValue)}',
                                            style: TextStyle(
                                              color: dueAmountValue > 0
                                                  ? Colors.redAccent
                                                  : activeColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (['BKASH', 'NAGAD', 'ROCKET']
                                        .contains(paymentMethod)) ...[
                                      const SizedBox(height: 16),
                                      const Divider(color: Color(0xFFE2EBE8)),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'মোবাইল ব্যাংকিং বিবরণ',
                                        style: TextStyle(
                                          color: Color(0xFF16302E),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: senderNumberController,
                                        keyboardType: TextInputType.phone,
                                        cursorColor: activeColor,
                                        style: const TextStyle(
                                          color: Color(0xFF16302E),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'প্রেরকের মোবাইল নম্বর',
                                          hintText: '০১৭XXXXXXXX',
                                          filled: true,
                                          fillColor: const Color(0xFFF8FBFA),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 14),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide:
                                                BorderSide(color: borderColor),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide:
                                                BorderSide(color: borderColor),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                                color: activeColor, width: 1.4),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: transactionIdController,
                                        cursorColor: activeColor,
                                        style: const TextStyle(
                                          color: Color(0xFF16302E),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'ট্রানজেকশন আইডি (TxnID)',
                                          hintText: 'TrxID লিখুন',
                                          filled: true,
                                          fillColor: const Color(0xFFF8FBFA),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 14),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide:
                                                BorderSide(color: borderColor),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide:
                                                BorderSide(color: borderColor),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                                color: activeColor, width: 1.4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }
                            final line = widget.order.lines[index];
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FBFA),
                                borderRadius: BorderRadius.circular(18),
                                border:
                                    Border.all(color: const Color(0xFFE2EBE8)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    line.productName,
                                    style: const TextStyle(
                                      color: Color(0xFF16302E),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'অর্ডারকৃত: ${_bn(line.orderedQuantity)} | ক্রয় মূল্য: ৳ ${_bn(line.unitCost)}',
                                    style: const TextStyle(
                                      color: Color(0xFF71827F),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (_advancedInventoryMode) ...[
                                    const SizedBox(height: 10),
                                    Builder(
                                      builder: (context) {
                                        final zone =
                                            zoneById(selectedZoneIds[index]);
                                        final racks = zone?.racks ??
                                            const <_InventoryRackOption>[];
                                        final rack = rackById(
                                            zone, selectedRackIds[index]);
                                        final shelves = rack?.shelves ??
                                            const <_InventoryShelfOption>[];
                                        final shelf = shelfById(
                                            rack, selectedShelfIds[index]);
                                        final bins = shelf?.bins ??
                                            const <_InventoryBinOption>[];

                                        InputDecoration decoration(
                                            String label, String hintText) {
                                          return InputDecoration(
                                            labelText: label,
                                            hintText: hintText,
                                            filled: true,
                                            fillColor: Colors.white,
                                            labelStyle: const TextStyle(
                                              color: Color(0xFF6E807D),
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            floatingLabelStyle: const TextStyle(
                                              color: Color(0xFF0D6B55),
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            hintStyle: const TextStyle(
                                              color: Color(0xFF9AA9A6),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFFD9E6E2)),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFFD9E6E2)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFF0D6B55),
                                                  width: 1.3),
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFFD9E6E2)),
                                            ),
                                          );
                                        }

                                        String? resolveValue(
                                          String? value,
                                          List<DropdownMenuItem<String>> items,
                                        ) {
                                          if (value == null || value.isEmpty) {
                                            return null;
                                          }
                                          for (final item in items) {
                                            if (item.value == value) {
                                              return value;
                                            }
                                          }
                                          return null;
                                        }

                                        Widget selectorField({
                                          required String label,
                                          required String? value,
                                          required String hintText,
                                          required List<
                                                  DropdownMenuItem<String>>
                                              items,
                                          required ValueChanged<String?>?
                                              onChanged,
                                          IconData? icon,
                                        }) {
                                          final safeValue =
                                              resolveValue(value, items);
                                          return DropdownButtonFormField<
                                              String>(
                                            value: safeValue,
                                            isExpanded: true,
                                            style: const TextStyle(
                                              color: Color(0xFF16302E),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            dropdownColor: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            menuMaxHeight: 320,
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Color(0xFF0D6B55),
                                            ),
                                            hint: Text(
                                              hintText,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Color(0xFF9AA9A6),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            decoration:
                                                decoration(label, hintText)
                                                    .copyWith(
                                              prefixIcon: icon == null
                                                  ? null
                                                  : Icon(icon,
                                                      size: 18,
                                                      color: const Color(
                                                          0xFF0D6B55)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 12,
                                              ),
                                            ),
                                            items: items,
                                            onChanged: onChanged,
                                            selectedItemBuilder: (context) {
                                              return items
                                                  .map(
                                                    (item) => Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: DefaultTextStyle(
                                                        style: const TextStyle(
                                                          color:
                                                              Color(0xFF16302E),
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                        child: item.child,
                                                      ),
                                                    ),
                                                  )
                                                  .toList(growable: false);
                                            },
                                          );
                                        }

                                        _InventoryBinOption? selectedBinOption;
                                        for (final bin in bins) {
                                          if (bin.id == selectedBinIds[index]) {
                                            selectedBinOption = bin;
                                            break;
                                          }
                                        }

                                        final selectedPath = [
                                          zone?.name,
                                          rack?.name,
                                          shelf?.name,
                                          selectedBinOption?.code ??
                                              (selectedBinIds[index] != null
                                                  ? 'Bin'
                                                  : null),
                                        ]
                                            .whereType<String>()
                                            .where((value) =>
                                                value.trim().isNotEmpty)
                                            .join('  →  ');

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      12, 10, 12, 12),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1FBF6),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                    color: const Color(
                                                        0xFFCEEBDD)),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Row(
                                                    children: [
                                                      Icon(
                                                        Icons.route_rounded,
                                                        size: 16,
                                                        color:
                                                            Color(0xFF0D6B55),
                                                      ),
                                                      SizedBox(width: 6),
                                                      Text(
                                                        'স্টোরেজ পাথ',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFF0D6B55),
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    selectedPath.isEmpty
                                                        ? 'ধাপে ধাপে Zone, Rack, Shelf, Bin নির্বাচন করুন'
                                                        : selectedPath,
                                                    style: const TextStyle(
                                                      color: Color(0xFF16302E),
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      height: 1.35,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            const Text(
                                              'লোকেশন নির্বাচন',
                                              style: TextStyle(
                                                color: Color(0xFF16302E),
                                                fontWeight: FontWeight.w800,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: selectorField(
                                                    label: 'জোন',
                                                    value:
                                                        selectedZoneIds[index],
                                                    hintText: _inventoryLoading
                                                        ? 'লোড হচ্ছে...'
                                                        : 'জোন নির্বাচন করুন',
                                                    icon: Icons.map_outlined,
                                                    items: _inventoryZones
                                                        .map(
                                                          (zoneOption) =>
                                                              DropdownMenuItem<
                                                                  String>(
                                                            value:
                                                                zoneOption.id,
                                                            child: Text(
                                                                zoneOption
                                                                    .name),
                                                          ),
                                                        )
                                                        .toList(
                                                            growable: false),
                                                    onChanged: (value) {
                                                      final nextZone =
                                                          zoneById(value);
                                                      final nextRack = nextZone
                                                                  ?.racks
                                                                  .isNotEmpty ==
                                                              true
                                                          ? nextZone!
                                                              .racks.first
                                                          : null;
                                                      final nextShelf = nextRack
                                                                  ?.shelves
                                                                  .isNotEmpty ==
                                                              true
                                                          ? nextRack!
                                                              .shelves.first
                                                          : null;
                                                      final nextBin = nextShelf
                                                                  ?.bins
                                                                  .isNotEmpty ==
                                                              true
                                                          ? nextShelf!
                                                              .bins.first
                                                          : null;
                                                      setSheetState(() {
                                                        selectedZoneIds[index] =
                                                            value;
                                                        selectedRackIds[index] =
                                                            nextRack?.id;
                                                        selectedShelfIds[
                                                                index] =
                                                            nextShelf?.id;
                                                        selectedBinIds[index] =
                                                            nextBin?.id;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: selectorField(
                                                    label: 'র‍্যাক',
                                                    value:
                                                        selectedRackIds[index],
                                                    hintText: racks.isEmpty
                                                        ? 'র‍্যাক নেই'
                                                        : 'র‍্যাক নির্বাচন করুন',
                                                    icon: Icons
                                                        .view_module_rounded,
                                                    items: racks
                                                        .map(
                                                          (rackOption) =>
                                                              DropdownMenuItem<
                                                                  String>(
                                                            value:
                                                                rackOption.id,
                                                            child: Text(
                                                                rackOption
                                                                    .name),
                                                          ),
                                                        )
                                                        .toList(
                                                            growable: false),
                                                    onChanged: racks.isEmpty
                                                        ? null
                                                        : (value) {
                                                            final nextRack =
                                                                rackById(zone,
                                                                    value);
                                                            final nextShelf =
                                                                nextRack?.shelves
                                                                            .isNotEmpty ==
                                                                        true
                                                                    ? nextRack!
                                                                        .shelves
                                                                        .first
                                                                    : null;
                                                            final nextBin =
                                                                nextShelf?.bins
                                                                            .isNotEmpty ==
                                                                        true
                                                                    ? nextShelf!
                                                                        .bins
                                                                        .first
                                                                    : null;
                                                            setSheetState(() {
                                                              selectedRackIds[
                                                                      index] =
                                                                  value;
                                                              selectedShelfIds[
                                                                      index] =
                                                                  nextShelf?.id;
                                                              selectedBinIds[
                                                                      index] =
                                                                  nextBin?.id;
                                                            });
                                                          },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: selectorField(
                                                    label: 'শেলফ',
                                                    value:
                                                        selectedShelfIds[index],
                                                    hintText: shelves.isEmpty
                                                        ? 'শেলফ নেই'
                                                        : 'শেলফ নির্বাচন করুন',
                                                    icon: Icons.layers_outlined,
                                                    items: shelves
                                                        .map(
                                                          (shelfOption) =>
                                                              DropdownMenuItem<
                                                                  String>(
                                                            value:
                                                                shelfOption.id,
                                                            child: Text(
                                                                shelfOption
                                                                    .name),
                                                          ),
                                                        )
                                                        .toList(
                                                            growable: false),
                                                    onChanged: shelves.isEmpty
                                                        ? null
                                                        : (value) {
                                                            final nextShelf =
                                                                shelfById(rack,
                                                                    value);
                                                            final nextBin =
                                                                nextShelf?.bins
                                                                            .isNotEmpty ==
                                                                        true
                                                                    ? nextShelf!
                                                                        .bins
                                                                        .first
                                                                    : null;
                                                            setSheetState(() {
                                                              selectedShelfIds[
                                                                      index] =
                                                                  value;
                                                              selectedBinIds[
                                                                      index] =
                                                                  nextBin?.id;
                                                            });
                                                          },
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: selectorField(
                                                    label: 'বিন',
                                                    value:
                                                        selectedBinIds[index],
                                                    hintText: bins.isEmpty
                                                        ? 'বিন নেই'
                                                        : 'বিন নির্বাচন করুন',
                                                    icon: Icons
                                                        .inventory_2_outlined,
                                                    items: bins
                                                        .map(
                                                          (bin) =>
                                                              DropdownMenuItem<
                                                                  String>(
                                                            value: bin.id,
                                                            child: Text(
                                                              bin.code.isEmpty
                                                                  ? bin
                                                                      .locationLabel
                                                                  : bin.code,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        )
                                                        .toList(
                                                            growable: false),
                                                    onChanged: bins.isEmpty
                                                        ? null
                                                        : (value) {
                                                            setSheetState(() {
                                                              selectedBinIds[
                                                                      index] =
                                                                  value;
                                                            });
                                                          },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            if (selectedPath.isNotEmpty)
                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                      color: const Color(
                                                          0xFFDCE8E4)),
                                                ),
                                                child: Text(
                                                  'নির্বাচিত: $selectedPath',
                                                  style: const TextStyle(
                                                    color: Color(0xFF516462),
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.35,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller:
                                              physicalControllers[index],
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(
                                            color: Color(0xFF16302E),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          inputFormatters:
                                              NumericInputFormatters
                                                  .wholeNumber,
                                          decoration: InputDecoration(
                                            labelText: 'পদার্থিক সংখ্যা',
                                            hintText: '১',
                                            filled: true,
                                            fillColor: Colors.white,
                                            labelStyle: const TextStyle(
                                              color: Color(0xFF6E807D),
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            floatingLabelStyle: const TextStyle(
                                              color: Color(0xFF0D6B55),
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            hintStyle: const TextStyle(
                                              color: Color(0xFFB1BEBA),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFFD9E6E2)),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFFD9E6E2)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFF0D6B55),
                                                  width: 1.3),
                                            ),
                                          ),
                                          onChanged: (val) {
                                            if (!hasCustomPaidAmount) {
                                              paidAmountController.text =
                                                  calculateTotalReceiveAmount()
                                                      .toString();
                                            }
                                            setSheetState(() {});
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: buyingControllers[index],
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(
                                            color: Color(0xFF16302E),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          inputFormatters:
                                              NumericInputFormatters
                                                  .wholeNumber,
                                          decoration: InputDecoration(
                                            labelText: 'ক্রয় মূল্য',
                                            hintText: '০',
                                            filled: true,
                                            fillColor: Colors.white,
                                            labelStyle: const TextStyle(
                                              color: Color(0xFF6E807D),
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            floatingLabelStyle: const TextStyle(
                                              color: Color(0xFF0D6B55),
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            hintStyle: const TextStyle(
                                              color: Color(0xFFB1BEBA),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFFD9E6E2)),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFFD9E6E2)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFF0D6B55),
                                                  width: 1.3),
                                            ),
                                          ),
                                          onChanged: (val) {
                                            if (!hasCustomPaidAmount) {
                                              paidAmountController.text =
                                                  calculateTotalReceiveAmount()
                                                      .toString();
                                            }
                                            setSheetState(() {});
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: sellingControllers[index],
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(
                                            color: Color(0xFF16302E),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          inputFormatters:
                                              NumericInputFormatters
                                                  .wholeNumber,
                                          decoration: InputDecoration(
                                            labelText: 'বিক্রয় মূল্য',
                                            hintText: '০',
                                            filled: true,
                                            fillColor: Colors.white,
                                            labelStyle: const TextStyle(
                                              color: Color(0xFF6E807D),
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            floatingLabelStyle: const TextStyle(
                                              color: Color(0xFF0D6B55),
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            hintStyle: const TextStyle(
                                              color: Color(0xFFB1BEBA),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFFD9E6E2)),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFFD9E6E2)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFF0D6B55),
                                                  width: 1.3),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: batchControllers[index],
                                          style: const TextStyle(
                                            color: Color(0xFF16302E),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: 'ব্যাচ নম্বর',
                                            hintText: 'B001',
                                            filled: true,
                                            fillColor: Colors.white,
                                            labelStyle: const TextStyle(
                                              color: Color(0xFF6E807D),
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            floatingLabelStyle: const TextStyle(
                                              color: Color(0xFF0D6B55),
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            hintStyle: const TextStyle(
                                              color: Color(0xFFB1BEBA),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFFD9E6E2)),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFFD9E6E2)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFF0D6B55),
                                                  width: 1.3),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          16 + MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFE15241),
                                  side: const BorderSide(
                                      color: Color(0xFFF0C9C4)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text('বাতিল'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final lines = <PurchaseReceiveLineInput>[];
                                  final placements =
                                      <PurchaseInventoryPlacementInput>[];
                                  for (var i = 0;
                                      i < widget.order.lines.length;
                                      i++) {
                                    final physicalCount = int.tryParse(
                                            physicalControllers[i]
                                                .text
                                                .trim()) ??
                                        0;
                                    final buyingPrice = int.tryParse(
                                            buyingControllers[i].text.trim()) ??
                                        0;
                                    final sellingPrice = int.tryParse(
                                            sellingControllers[i]
                                                .text
                                                .trim()) ??
                                        0;
                                    final batchNo =
                                        batchControllers[i].text.trim();
                                    if (physicalCount <= 0 ||
                                        buyingPrice < 0 ||
                                        sellingPrice < 0 ||
                                        batchNo.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'প্রতিটি পণ্যের জন্য সঠিক স্টক, ক্রয় মূল্য, বিক্রয় মূল্য ও ব্যাচ নম্বর দিন।'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }
                                    final selectedZoneId =
                                        _advancedInventoryMode &&
                                                selectedZoneIds[i] != null &&
                                                selectedZoneIds[i]!
                                                    .trim()
                                                    .isNotEmpty
                                            ? selectedZoneIds[i]
                                            : null;
                                    final selectedRackId =
                                        _advancedInventoryMode &&
                                                selectedRackIds[i] != null &&
                                                selectedRackIds[i]!
                                                    .trim()
                                                    .isNotEmpty
                                            ? selectedRackIds[i]
                                            : null;
                                    final selectedShelfId =
                                        _advancedInventoryMode &&
                                                selectedShelfIds[i] != null &&
                                                selectedShelfIds[i]!
                                                    .trim()
                                                    .isNotEmpty
                                            ? selectedShelfIds[i]
                                            : null;
                                    final selectedBinId =
                                        _advancedInventoryMode &&
                                                selectedBinIds[i] != null &&
                                                selectedBinIds[i]!
                                                    .trim()
                                                    .isNotEmpty
                                            ? selectedBinIds[i]
                                            : null;
                                    lines.add(PurchaseReceiveLineInput(
                                      productId:
                                          widget.order.lines[i].productId,
                                      physicalCount: physicalCount,
                                      buyingPrice: buyingPrice,
                                      sellingPrice: sellingPrice,
                                      batchNo: batchNo,
                                    ));
                                    if (_advancedInventoryMode &&
                                        (selectedZoneId != null ||
                                            selectedRackId != null ||
                                            selectedShelfId != null ||
                                            selectedBinId != null)) {
                                      placements.add(
                                        PurchaseInventoryPlacementInput(
                                          productId:
                                              widget.order.lines[i].productId,
                                          physicalCount: physicalCount,
                                          sellingPrice: sellingPrice,
                                          zoneId: selectedZoneId,
                                          rackId: selectedRackId,
                                          shelfId: selectedShelfId,
                                          binId: selectedBinId,
                                          batchNo: batchNo,
                                          productName:
                                              widget.order.lines[i].productName,
                                        ),
                                      );
                                    }
                                  }

                                  final totalReceive =
                                      calculateTotalReceiveAmount();
                                  int paid = 0;
                                  if (paymentMethod != 'DUE') {
                                    paid = int.tryParse(
                                            paidAmountController.text.trim()) ??
                                        0;
                                    if (paid < 0) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'পরিশোধিত টাকা নেতিবাচক হতে পারবে না।'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }
                                    if (paid > totalReceive) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'পরিশোধিত টাকা সর্বমোট মূল্যের চেয়ে বেশি হতে পারবে না।'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }
                                  }

                                  Map<String, dynamic>? details;
                                  if (['BKASH', 'NAGAD', 'ROCKET']
                                      .contains(paymentMethod)) {
                                    final sender =
                                        senderNumberController.text.trim();
                                    final trxId =
                                        transactionIdController.text.trim();
                                    details = {
                                      'senderNumber': sender,
                                      'transactionId': trxId,
                                    };
                                  }

                                  Navigator.of(ctx).pop(
                                    _PurchaseReceiveDialogResult(
                                      lines: lines,
                                      placements: placements,
                                      paidAmount: paid,
                                      paymentMethod: paymentMethod,
                                      paymentDetails: details,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D6B55),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text('গ্রহণ করুন'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        for (final controller in physicalControllers) {
          try {
            controller.dispose();
          } catch (_) {}
        }
        for (final controller in buyingControllers) {
          try {
            controller.dispose();
          } catch (_) {}
        }
        for (final controller in sellingControllers) {
          try {
            controller.dispose();
          } catch (_) {}
        }
        for (final controller in batchControllers) {
          try {
            controller.dispose();
          } catch (_) {}
        }
        try {
          paidAmountController.dispose();
        } catch (_) {}
        try {
          senderNumberController.dispose();
        } catch (_) {}
        try {
          transactionIdController.dispose();
        } catch (_) {}
      });
    }
  }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ক্রয় অর্ডার প্রত্যাখ্যান করবেন?'),
        content: const Text(
            'আপনি কি নিশ্চিত যে এই ক্রয় অর্ডারটি প্রত্যাখ্যান করতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('না'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE15241)),
            child: const Text('হ্যাঁ, প্রত্যাখ্যান করুন'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _submitting = true);
    try {
      await ref.read(purchaseOrderProvider.notifier).cancelOrder(widget.order);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ক্রয় অর্ডার প্রত্যাখ্যান করা হয়েছে।'),
            backgroundColor: Color(0xFFE15241),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ত্রুটি: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3FAFB),
        elevation: 0,
        foregroundColor: const Color(0xFF16302E),
        title: const Text(
          'ক্রয়ের বিবরণ',
          style: TextStyle(
            color: Color(0xFF0D6B55),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _submitting
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0D6B55)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _detailHero(order),
                const SizedBox(height: 16),
                const Text(
                  'পণ্য তালিকা',
                  style: TextStyle(
                    color: Color(0xFF16302E),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                ...order.lines.map(_detailLineCard),
                const SizedBox(height: 16),
                _detailSummary(order),
                const SizedBox(height: 16),
                _detailPaymentInfo(order),
                const SizedBox(height: 20),
                // Actions (Only show if submitted/pending approval)
                if (order.status == PurchaseOrderStatus.submitted) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _cancelOrder,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE15241),
                            side: const BorderSide(color: Color(0xFFF0C9C4)),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('প্রত্যাখ্যান করুন',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _receiveOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D6B55),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('রিসিভ করুন',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ],
                if (order.status == PurchaseOrderStatus.received ||
                    order.status == PurchaseOrderStatus.partiallyReceived) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showReturnDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE15241),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('ক্রয় ফেরত (Return Items)',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _detailHero(PurchaseOrder order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D6B55), Color(0xFF124C41)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D6B55).withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child:
                    const Icon(Icons.receipt_long_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.reference.isNotEmpty ? order.reference : order.id,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.supplierName,
                      style: const TextStyle(
                        color: Color(0xFFD8EFE6),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _miniInfoTile(
                  title: 'তারিখ',
                  value:
                      '${_bn(order.createdAt.day)}/${_bn(order.createdAt.month)}/${_bn(order.createdAt.year)}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniInfoTile(
                  title: 'অবস্থা',
                  value: switch (order.status) {
                    PurchaseOrderStatus.received => 'রিসিভড',
                    PurchaseOrderStatus.partiallyReceived => 'আংশিক রিসিভড',
                    PurchaseOrderStatus.cancelled => 'প্রত্যাখ্যাত',
                    PurchaseOrderStatus.submitted => 'অপেক্ষমাণ',
                    PurchaseOrderStatus.draft => 'খসড়া',
                  },
                ),
              ),
            ],
          ),
          if (order.note.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Text(
                order.note,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniInfoTile({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFD8EFE6),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailLineCard(PurchaseOrderLine line) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EBE8)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5F1),
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                const Icon(Icons.inventory_2_rounded, color: Color(0xFF0D6B55)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.productName,
                  style: const TextStyle(
                    color: Color(0xFF16302E),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '৳ ${_bn(line.unitCost)} × ${_bn(line.orderedQuantity)} টি',
                  style: const TextStyle(
                    color: Color(0xFF71827F),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '৳ ${_bn(line.orderedAmount)}',
            style: const TextStyle(
              color: Color(0xFF0D6B55),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailSummary(PurchaseOrder order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBCDDCF)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'সর্বমোট মূল্য',
              style: TextStyle(
                color: Color(0xFF0D6B55),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '৳ ${_bn(order.totalAmount)}',
            style: const TextStyle(
              color: Color(0xFF0D6B55),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailPaymentInfo(PurchaseOrder order) {
    final methodLabel = switch (order.paymentMethod.toUpperCase()) {
      'CASH' => 'নগদ (Cash)',
      'DUE' => 'বকেয়া (Due)',
      'BKASH' => 'বিকাশ (bKash)',
      'NAGAD' => 'নগদ (Nagad)',
      'ROCKET' => 'রকেট (Rocket)',
      _ => order.paymentMethod,
    };

    final isMfs = ['BKASH', 'NAGAD', 'ROCKET']
        .contains(order.paymentMethod.toUpperCase());
    final senderNumber = order.paymentDetails?['senderNumber'] ??
        order.paymentDetails?['sender_number'] ??
        '';
    final transactionId = order.paymentDetails?['transactionId'] ??
        order.paymentDetails?['transaction_id'] ??
        '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3ECE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'পেমেন্ট বিবরণ',
            style: TextStyle(
              color: Color(0xFF16302E),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _paymentRow('পেমেন্ট মাধ্যম', methodLabel),
          const Divider(height: 20, color: Color(0xFFE6EFEF)),
          _paymentRow('পরিশোধিত পরিমাণ', '৳ ${_bn(order.paidAmount)}'),
          const Divider(height: 20, color: Color(0xFFE6EFEF)),
          _paymentRow(
            'বকেয়া পরিমাণ',
            '৳ ${_bn(order.totalAmount - order.paidAmount > 0 ? order.totalAmount - order.paidAmount : 0)}',
            valueColor: order.totalAmount - order.paidAmount > 0
                ? const Color(0xFFE15241)
                : const Color(0xFF0E8F5F),
          ),
          if (isMfs &&
              (senderNumber.isNotEmpty || transactionId.isNotEmpty)) ...[
            const Divider(height: 20, color: Color(0xFFE6EFEF)),
            if (senderNumber.isNotEmpty)
              _paymentRow('প্রেরকের নম্বর', senderNumber),
            if (transactionId.isNotEmpty) ...[
              const SizedBox(height: 8),
              _paymentRow('ট্রানজেকশন আইডি', transactionId),
            ],
          ],
        ],
      ),
    );
  }

  Widget _paymentRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF5A7572),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF16302E),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
