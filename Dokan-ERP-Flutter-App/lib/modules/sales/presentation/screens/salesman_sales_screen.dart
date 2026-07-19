import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/modules/auth/auth.dart';
import 'package:dokan_erp/modules/notifications/notifications.dart';
import 'package:dokan_erp/modules/products/products.dart';
import 'package:dokan_erp/modules/products/products.dart';
import 'package:dokan_erp/modules/products/products.dart';
import 'package:dokan_erp/modules/sales/presentation/providers/cart_provider.dart';

class SalesmanSalesScreen extends ConsumerStatefulWidget {
  const SalesmanSalesScreen({super.key});

  @override
  ConsumerState<SalesmanSalesScreen> createState() =>
      _SalesmanSalesScreenState();
}

class _SalesmanSalesScreenState extends ConsumerState<SalesmanSalesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerNumberController =
      TextEditingController();
  final TextEditingController _transactionIdController =
      TextEditingController();
  final TextEditingController _cashReceivedController = TextEditingController();
  final TextEditingController _creditDueAmountController =
      TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _cardLast4Controller = TextEditingController();
  final TextEditingController _cardApprovalController = TextEditingController();
  final TextEditingController _bankSenderController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _bankReferenceController =
      TextEditingController();

  late final FocusNode _cashReceivedFocusNode;
  late final FocusNode _creditDueAmountFocusNode;

  String _query = '';
  String _selectedCategory = 'সব';
  Map<String, String> _fieldErrors = <String, String>{};
  static const List<String> _categories = <String>[
    'সব',
    'চাল-ডাল',
    'তেল-মসলা',
    'প্যাকেট আইটেম',
    'দৈনন্দিন',
  ];

  @override
  void initState() {
    super.initState();
    _cashReceivedFocusNode = FocusNode();
    _creditDueAmountFocusNode = FocusNode();
    _discountController.text = '';
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dokanAppFlowProvider.notifier).refreshPermissions();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dokanInventoryCatalogProvider.notifier).refreshFromRepository();
    });
  }

  @override
  void dispose() {
    _cashReceivedFocusNode.dispose();
    _creditDueAmountFocusNode.dispose();
    _searchController.dispose();
    _discountController.dispose();
    _customerNameController.dispose();
    _customerNumberController.dispose();
    _transactionIdController.dispose();
    _cashReceivedController.dispose();
    _creditDueAmountController.dispose();
    _cardHolderController.dispose();
    _cardLast4Controller.dispose();
    _cardApprovalController.dispose();
    _bankSenderController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _bankReferenceController.dispose();
    super.dispose();
  }

  List<String> get _dynamicCategories {
    final catalog = ref.watch(dokanInventoryCatalogProvider);
    final list = <String>['সব'];
    for (final p in catalog) {
      final cat = p.category.trim();
      if (cat.isNotEmpty && !list.contains(cat)) {
        list.add(cat);
      }
    }
    return list;
  }

  List<_SalesmanPosItem> get _visibleItems {
    final catalog = ref.watch(dokanInventoryCatalogProvider);
    final query = _query.trim().toLowerCase();
    return catalog.map(_salesItemFromProduct).where((item) {
      final categoryMatch =
          _selectedCategory == 'সব' ||
          item.category.trim() == _selectedCategory.trim();
      final searchMatch = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query) ||
          item.id.toLowerCase().contains(query);
      return categoryMatch && searchMatch;
    }).toList(growable: false);
  }

  _SalesmanPosItem _salesItemFromProduct(DokanCatalogProduct product) {
    final img = product.imageLabel.trim();
    return _SalesmanPosItem(
      id: product.barcode,
      name: product.name,
      sku: product.barcode,
      price: product.salePrice,
      stock: product.stock,
      category: product.category,
      icon: _iconForCategory(product.category),
      imageUrl: img.isNotEmpty ? img : '',
      emoji: product.emoji,
    );
  }

  Widget _buildItemThumbnail(_SalesmanPosItem item) {
    final url = item.imageUrl.trim();
    final isNetworkUrl = url.startsWith('http://') || url.startsWith('https://');
    final isAssetUrl = url.startsWith('assets/');
    final isFileUrl = url.startsWith('/Users/') || url.startsWith('file://') || url.startsWith('/data/');

    if (url.isNotEmpty && url != 'ছবি যোগ করা হয়নি') {
      Widget? imageWidget;
      if (isNetworkUrl) {
        imageWidget = Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildItemFallbackIcon(item),
        );
      } else if (isAssetUrl) {
        imageWidget = Image.asset(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildItemFallbackIcon(item),
        );
      } else if (isFileUrl) {
        final filePath = url.replaceFirst('file://', '');
        imageWidget = Image.file(
          File(filePath),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildItemFallbackIcon(item),
        );
      } else if (url.length > 200 || url.startsWith('data:image')) {
        try {
          final cleanBase64 = url.contains(',') ? url.split(',').last : url;
          final bytes = base64Decode(cleanBase64);
          imageWidget = Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildItemFallbackIcon(item),
          );
        } catch (_) {
          imageWidget = null;
        }
      }

      if (imageWidget != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 44,
            height: 44,
            color: const Color(0xFFEFF4FF),
            child: imageWidget,
          ),
        );
      }
    }

    return _buildItemFallbackIcon(item);
  }

  Widget _buildItemFallbackIcon(_SalesmanPosItem item) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: item.emoji.trim().isNotEmpty
          ? Text(item.emoji, style: const TextStyle(fontSize: 22))
          : Icon(item.icon, color: const Color(0xFF1D4ED8), size: 22),
    );
  }

  DokanCatalogProduct? _findProductById(String id) {
    final catalog = ref.read(dokanInventoryCatalogProvider);
    for (final product in catalog) {
      if (product.barcode == id) {
        return product;
      }
    }
    return null;
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'চাল-ডাল':
        return Icons.rice_bowl_outlined;
      case 'তেল-মসলা':
        return Icons.water_drop_outlined;
      case 'প্যাকেট আইটেম':
        return Icons.local_drink_outlined;
      case 'দৈনন্দিন':
        return Icons.local_laundry_service_outlined;
      case 'বিস্কুট':
        return Icons.cookie_outlined;
      case 'সাবান':
        return Icons.spa_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  void _syncControllersFromState(DokanPosState state) {
    _discountController.text = state.discount == 0 ? '' : state.discount.toString();
    _customerNameController.text = state.customerName;
    _customerNumberController.text = state.customerNumber;
    _transactionIdController.text = state.transactionId;
    _cashReceivedController.text =
        state.cashReceived == 0 ? '' : state.cashReceived.toString();
    _creditDueAmountController.text =
        state.creditDueAmount == 0 ? '' : state.creditDueAmount.toString();
    _cardHolderController.text = state.cardHolderName;
    _cardLast4Controller.text = state.cardLast4;
    _cardApprovalController.text = state.cardApprovalCode;
    _bankSenderController.text = state.bankSenderName;
    _bankNameController.text = state.bankName;
    _bankAccountController.text = state.bankAccountNumber;
    _bankReferenceController.text = state.bankReferenceNumber;
  }

  Future<void> _openItemDetails(_SalesmanPosItem item) async {
    final currentQty = ref.read(dokanPosProvider).cartQuantities[item.id] ?? 0;
    var qty = currentQty <= 0 ? 1 : currentQty;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final selected = qty > 0;
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 52,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3DCE0),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF7F0),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child:
                              Icon(item.icon, color: const Color(0xFF0F766E)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'আইডি ${item.sku}  |  ${item.category}',
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.w700,
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
                          child: _DetailTile(
                            title: 'স্টক',
                            value: (item.stock - qty).toString(),
                            accent: (item.stock - qty) <= 5
                                ? const Color(0xFFB45309)
                                : const Color(0xFF0F766E),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DetailTile(
                            title: 'দাম',
                            value: '৳${item.price}',
                            accent: const Color(0xFF1D4ED8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'পরিমাণ',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: qty <= 0
                                ? null
                                : () => setSheetState(() => qty -= 1),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            '$qty',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          IconButton(
                            onPressed: qty >= item.stock
                                ? null
                                : () => setSheetState(() => qty += 1),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final notifier = ref.read(dokanPosProvider.notifier);
                          notifier.setItemQuantity(
                            item.id,
                            qty,
                            stockLimit: item.stock,
                          );
                          Navigator.of(sheetContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                selected
                                    ? '${item.name} কার্টে আপডেট হয়েছে'
                                    : '${item.name} কার্টে যোগ হয়েছে',
                              ),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0F766E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                            qty == 0 ? 'কার্ট থেকে সরান' : 'কার্টে যোগ করুন'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openCheckoutSheet() async {
    final current = ref.read(dokanPosProvider);
    if (current.cartCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কার্ট খালি আছে')),
      );
      return;
    }

    // Set default cashReceived or creditDueAmount when opening checkout to current total
    if (current.paymentMethod == DokanPosPaymentMethod.cash) {
      ref.read(dokanPosProvider.notifier).setCashReceived(current.total.toString());
    } else if (current.paymentMethod == DokanPosPaymentMethod.due) {
      ref.read(dokanPosProvider.notifier).setCreditDueAmount(current.total.toString());
    }

    _fieldErrors = <String, String>{};
    _syncControllersFromState(ref.read(dokanPosProvider));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(dokanPosProvider);

                final stateCashStr = state.cashReceived == 0 ? '' : state.cashReceived.toString();
                if (_cashReceivedController.text != stateCashStr) {
                  _cashReceivedController.text = stateCashStr;
                }

                final stateDueStr = state.creditDueAmount == 0 ? '' : state.creditDueAmount.toString();
                if (_creditDueAmountController.text != stateDueStr) {
                  _creditDueAmountController.text = stateDueStr;
                }

                final method = state.paymentMethod;
                final isCash = method == DokanPosPaymentMethod.cash;
                final isDue = method == DokanPosPaymentMethod.due;
                final dueAmount = state.dueAmount;
                final status = isCash
                    ? (state.cashReceived >= state.total
                        ? DokanPosOrderStatus.paid
                        : state.cashReceived > 0
                            ? DokanPosOrderStatus.partiallyPaid
                            : DokanPosOrderStatus.due)
                    : isDue
                        ? (dueAmount >= state.total
                            ? DokanPosOrderStatus.due
                            : dueAmount > 0
                                ? DokanPosOrderStatus.partiallyPaid
                                : DokanPosOrderStatus.due)
                        : DokanPosOrderStatus.paid;

                return SafeArea(
                  top: false,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F8F7),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 14,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Container(
                              width: 54,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.shopping_cart_outlined,
                                  color: Color(0xFF006B53)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'কার্ট (${state.cartCount} পণ্য)',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'বন্ধ',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: status == DokanPosOrderStatus.paid
                                  ? const Color(0xFFEFFAF5)
                                  : const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: status == DokanPosOrderStatus.paid
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFFF59E0B),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  status == DokanPosOrderStatus.paid
                                      ? Icons.check_circle_outline
                                      : status ==
                                              DokanPosOrderStatus.partiallyPaid
                                          ? Icons.info_outline
                                          : Icons.error_outline,
                                  color: status == DokanPosOrderStatus.paid
                                      ? const Color(0xFF0F766E)
                                      : const Color(0xFFB45309),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    status == DokanPosOrderStatus.paid
                                        ? 'পেমেন্ট প্রস্তুত'
                                        : status ==
                                                DokanPosOrderStatus
                                                    .partiallyPaid
                                            ? 'আংশিক পরিশোধ'
                                            : 'বাকি / দেরি',
                                    style: TextStyle(
                                      color: status == DokanPosOrderStatus.paid
                                          ? const Color(0xFF0F766E)
                                          : const Color(0xFFB45309),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (dueAmount > 0)
                                  Text(
                                    '৳$dueAmount',
                                    style: TextStyle(
                                      color: status == DokanPosOrderStatus.paid
                                          ? const Color(0xFF0F766E)
                                          : const Color(0xFFB45309),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...state.cartQuantities.entries.map((entry) {
                            final catalogProduct = _findProductById(entry.key);
                            if (catalogProduct == null) {
                              return const SizedBox.shrink();
                            }
                            final product =
                                _salesItemFromProduct(catalogProduct);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFFD6E4E0)),
                                ),
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0F5F4),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        product.icon,
                                        color: const Color(0xFF006B53),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '৳${product.price}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _StepperButton(
                                      icon: Icons.remove,
                                      onTap: () => ref
                                          .read(dokanPosProvider.notifier)
                                          .removeItem(product.id),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${entry.value}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _StepperButton(
                                      icon: Icons.add,
                                      onTap: () => ref
                                          .read(dokanPosProvider.notifier)
                                          .addItem(product.id,
                                              stockLimit: product.stock),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          _DarkTextField(
                            controller: _discountController,
                            hint: 'ছাড়ের পরিমাণ',
                            readOnly: !ref.watch(dokanAppFlowProvider).can(DokanPermission.settingsManage),
                            onChanged: (value) => ref
                                .read(dokanPosProvider.notifier)
                                .setDiscount(value),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: dokanPosCheckoutPaymentMethods
                                .where((m) =>
                                    m != DokanPosPaymentMethod.due ||
                                    ref.watch(dokanAppFlowProvider).can(DokanPermission.salesManage))
                                .map((m) {
                              final selected = state.paymentMethod == m;
                              return _PaymentChip(
                                label: dokanPosCheckoutPaymentMethodLabel(m),
                                selected: selected,
                                onTap: () {
                                  ref
                                      .read(dokanPosProvider.notifier)
                                      .setPaymentMethod(m);
                                  _syncControllersFromState(ref.read(dokanPosProvider));
                                  setSheetState(() {
                                    _fieldErrors = <String, String>{};
                                  });
                                },
                              );
                            }).toList(growable: false),
                          ),
                          if (isDue) ...[
                            const SizedBox(height: 12),
                            _DarkTextField(
                              controller: _customerNameController,
                              hint: 'গ্রাহকের নাম',
                              errorText: _fieldErrors['customerName'],
                              onChanged: (value) => ref
                                  .read(dokanPosProvider.notifier)
                                  .setCustomerName(value),
                            ),
                            const SizedBox(height: 10),
                            _DarkTextField(
                              controller: _customerNumberController,
                              hint: 'গ্রাহকের নম্বর',
                              keyboardType: TextInputType.phone,
                              errorText: _fieldErrors['customerNumber'],
                              onChanged: (value) => ref
                                  .read(dokanPosProvider.notifier)
                                  .setCustomerNumber(value),
                            ),
                            const SizedBox(height: 10),
                          ],
                          if (isDue)
                            _DarkTextField(
                              controller: _creditDueAmountController,
                              focusNode: _creditDueAmountFocusNode,
                              hint: 'বাকির পরিমাণ',
                              keyboardType: TextInputType.number,
                              inputFormatters:
                                  NumericInputFormatters.wholeNumber,
                              errorText: _fieldErrors['creditDueAmount'],
                              readOnly: true,
                              onChanged: (value) => ref
                                  .read(dokanPosProvider.notifier)
                                  .setCreditDueAmount(value),
                            ),
                          if (isCash) ...[
                            const SizedBox(height: 10),
                            _DarkTextField(
                              controller: _cashReceivedController,
                              focusNode: _cashReceivedFocusNode,
                              hint: 'প্রাপ্ত নগদ',
                              keyboardType: TextInputType.number,
                              inputFormatters:
                                  NumericInputFormatters.wholeNumber,
                              errorText: _fieldErrors['cashReceived'],
                              readOnly: true,
                              onChanged: (value) => ref
                                  .read(dokanPosProvider.notifier)
                                  .setCashReceived(value),
                            ),
                          ],
                          if (!isCash &&
                              !isDue &&
                              method != DokanPosPaymentMethod.card &&
                              method != DokanPosPaymentMethod.bank) ...[
                            const SizedBox(height: 10),
                            _DarkTextField(
                              controller: _transactionIdController,
                              hint: 'Transaction ID',
                              errorText: _fieldErrors['transactionId'],
                              onChanged: (value) => ref
                                  .read(dokanPosProvider.notifier)
                                  .setTransactionId(value),
                            ),
                          ],
                          if (method == DokanPosPaymentMethod.card) ...[
                            const SizedBox(height: 10),
                            _DarkTextField(
                              controller: _cardHolderController,
                              hint: 'কার্ডধারীর নাম',
                              errorText: _fieldErrors['cardHolder'],
                              onChanged: (value) => ref
                                  .read(dokanPosProvider.notifier)
                                  .setCardHolderName(value),
                            ),
                            const SizedBox(height: 10),
                            _DarkTextField(
                              controller: _cardLast4Controller,
                              hint: 'কার্ডের শেষ ৪ সংখ্যা',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              errorText: _fieldErrors['cardLast4'],
                              onChanged: (value) => ref
                                  .read(dokanPosProvider.notifier)
                                  .setCardLast4(value),
                            ),
                            const SizedBox(height: 10),
                            _DarkTextField(
                              controller: _cardApprovalController,
                              hint: 'অনুমোদন কোড',
                              errorText: _fieldErrors['cardApproval'],
                              onChanged: (value) => ref
                                  .read(dokanPosProvider.notifier)
                                  .setCardApprovalCode(value),
                            ),
                          ],
                          if (method == DokanPosPaymentMethod.bank) ...[
                            const SizedBox(height: 10),
                            _DarkTextField(
                              controller: _bankSenderController,
                              hint: 'প্রেরকের নাম',
                              errorText: _fieldErrors['bankSender'],
                              onChanged: (value) => ref
                                  .read(dokanPosProvider.notifier)
                                  .setBankSenderName(value),
                            ),
                            const SizedBox(height: 10),
                            _DarkTextField(
                              controller: _bankNameController,
                              hint: 'ব্যাংকের নাম',
                              errorText: _fieldErrors['bankName'],
                              onChanged: (value) => ref
                                  .read(dokanPosProvider.notifier)
                                  .setBankName(value),
                            ),
                            const SizedBox(height: 10),
                            _DarkTextField(
                              controller: _bankAccountController,
                              hint: 'অ্যাকাউন্ট নম্বর',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              errorText: _fieldErrors['bankAccount'],
                              onChanged: (value) => ref
                                  .read(dokanPosProvider.notifier)
                                  .setBankAccountNumber(value),
                            ),
                            const SizedBox(height: 10),
                            _DarkTextField(
                              controller: _bankReferenceController,
                              hint: 'রেফারেন্স নম্বর',
                              errorText: _fieldErrors['bankReference'],
                              onChanged: (value) => ref
                                  .read(dokanPosProvider.notifier)
                                  .setBankReferenceNumber(value),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: dueAmount > 0
                                  ? const Color(0xFFFFF7ED)
                                  : const Color(0xFFEFFAF5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: dueAmount > 0
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF86EFAC),
                              ),
                            ),
                            child: Text(
                              dueAmount > 0
                                  ? 'বাকি: ৳$dueAmount'
                                  : 'পেমেন্ট প্রস্তুত',
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () async {
                                final notifier =
                                    ref.read(dokanPosProvider.notifier);
                                final validation =
                                    notifier.validateCheckoutResult();
                                if (validation.hasBlockingErrors) {
                                  setSheetState(() {
                                    _fieldErrors = validation.fieldErrors;
                                  });
                                  return;
                                }

                                final currentState = ref.read(dokanPosProvider);
                                final total = currentState.total;
                                final due = currentState.dueAmount;
                                final paidAmount = total - due;
                                final itemsSummary = currentState
                                    .cartQuantities.entries
                                    .map((entry) {
                                  final catalogProduct =
                                      _findProductById(entry.key);
                                  if (catalogProduct == null) {
                                    return 'Unknown x${entry.value}';
                                  }
                                  return '${catalogProduct.name} x${entry.value}';
                                }).join(', ');

                                final message =
                                    await notifier.confirmCheckout();
                                if (!mounted) return;
                                if (message ==
                                    'remaining_due_confirmation_required') {
                                  showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) {
                                      return AlertDialog(
                                        title: const Text('বাকি রাখতে চান?'),
                                        content: Text(
                                          'অবশিষ্ট ${validation.dueAmount} টাকা বাকি হিসেবে রাখতে চান?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(dialogContext)
                                                    .pop(false),
                                            child: const Text('না'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.of(dialogContext)
                                                    .pop(true),
                                            child: const Text('হ্যাঁ'),
                                          ),
                                        ],
                                      );
                                    },
                                  ).then((confirmed) async {
                                    if (confirmed == true) {
                                      final successMessage =
                                          await notifier.confirmCheckout(
                                        allowDueConfirmation: true,
                                      );
                                      if (!mounted || !sheetContext.mounted) {
                                        return;
                                      }
                                      if (successMessage != null) {
                                        notifier.resetAfterCheckout();
                                        Navigator.of(sheetContext).pop();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(successMessage),
                                          ),
                                        );
                                      }
                                    }
                                   });
                                  return;
                                }
                                 notifier.resetAfterCheckout();
                                 Navigator.of(sheetContext).pop();
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(
                                     content: Text(message ?? 'পেমেন্ট সম্পন্ন'),
                                   ),
                                 );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('লেনদেন সম্পন্ন'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  int _calculateTotalCustomerDue(DokanPosState state, List<DokanPosOrderRecord> orders) {
    final grouped = <String, List<DokanPosOrderRecord>>{};
    for (final order in orders) {
      final phone = order.customerNumber.trim();
      String key;
      if (phone.isNotEmpty) {
        key = phone;
      } else {
        final nameLower = order.customerName.trim().toLowerCase();
        if (nameLower == 'guest customer' ||
            nameLower == 'হাঁটা বিক্রয়' ||
            nameLower == 'অতিথি গ্রাহক' ||
            nameLower.isEmpty) {
          key = 'guest_customer_unified_key';
        } else {
          key = nameLower;
        }
      }
      if (state.hiddenCustomerKeys.contains(key)) {
        continue;
      }
      grouped.putIfAbsent(key, () => <DokanPosOrderRecord>[]).add(order);
    }

    final profilesByKey = <String, DokanCustomerProfileRecord>{
      for (final profile in state.customerProfiles) profile.key: profile,
    };

    final allKeys = <String>{...grouped.keys, ...profilesByKey.keys}
        .where((key) => !state.hiddenCustomerKeys.contains(key))
        .toList(growable: false);

    int total = 0;
    for (final key in allKeys) {
      final profile = profilesByKey[key];
      final purchaseOrders = grouped[key] ?? const <DokanPosOrderRecord>[];
      final openingDue = profile?.openingDue ?? 0;
      final localOrderDue = purchaseOrders.fold<int>(0, (sum, order) => sum + order.dueAmount);
      final hasProfileFinance = profile != null &&
          (profile.totalSales > 0 ||
              profile.totalPaid > 0 ||
              profile.currentDue > 0 ||
              profile.openingDue > 0);
      final totalDue = hasProfileFinance ? profile.currentDue : (localOrderDue + openingDue);
      total += totalDue;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dokanPosProvider);
    final salesmanName =
        ref.watch(dokanAppFlowProvider).currentSalesmanName ?? 'সেলসম্যান';
    final products = _visibleItems;
    final cartCount = state.cartCount;

    final salesHistoryOrders =
        ref.watch(salesHistoryOrdersProvider).valueOrNull ??
            const <DokanPosOrderRecord>[];
    final mergedOrders = mergeSalesHistoryOrders(
      localOrders: state.orders,
      remoteOrders: salesHistoryOrders,
    );
    final totalCustomerDue = _calculateTotalCustomerDue(state, mergedOrders);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(dokanInventoryCatalogProvider.notifier)
                .refreshFromRepository();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFD8E2F2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF7F0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.badge_outlined,
                              color: Color(0xFF0F766E)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'বিক্রয় করুন',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                salesmanName,
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: const Color(0xFFEFFAF5),
                          borderRadius: BorderRadius.circular(999),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () async {
                              final status = await ref
                                  .read(dokanScannerPermissionServiceProvider)
                                  .ensureCameraPermission();
                              if (!context.mounted) return;
                              if (!status.isGranted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'ক্যামেরা অনুমতি না পেলে স্ক্যান হবে না',
                                    ),
                                    backgroundColor: Color(0xFFB3261E),
                                  ),
                                );
                                return;
                              }
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const DokanBarcodeScannerScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  border:
                                      Border.all(color: const Color(0xFFB9F6CA)),
                                ),
                                child: const Icon(
                                  Icons.qr_code_scanner_rounded,
                                  size: 22,
                                  color: Color(0xFF0F766E),
                                ),
                              ),
                            ),
                          ),
                        ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: DokanSearchField(
                    controller: _searchController,
                    hintText: 'পণ্য, আইডি বা কোড খুঁজুন...',
                    borderRadius: 20,
                    onChanged: (value) => setState(() => _query = value),
                    showClear: _query.isNotEmpty,
                    onClear: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _dynamicCategories.map((label) {
                        final selected = _selectedCategory == label;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = label),
                            selectedColor: const Color(0xFFDCE8FF),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: selected
                                  ? const Color(0xFF1D4ED8)
                                  : const Color(0xFF334155),
                              fontWeight: FontWeight.w800,
                            ),
                            side: const BorderSide(color: Color(0xFFD8E2F2)),
                          ),
                        );
                      }).toList(growable: false),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      _metricCard('কার্ট', '$cartCount', const Color(0xFF0F766E)),
                      const SizedBox(width: 10),
                      _metricCard(
                        'বাকি',
                        '৳$totalCustomerDue',
                        const Color(0xFFB45309),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: const SizedBox(height: 16),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: products.isEmpty
                    ? SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.only(top: 20, bottom: 40),
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFD8E2F2)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.inventory_2_outlined,
                                  color: Color(0xFF0F766E), size: 52),
                              const SizedBox(height: 12),
                              const Text(
                                'কোনো পণ্য পাওয়া যায়নি',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'ফিল্টার বা সার্চ পরিষ্কার করে পুনরায় চেষ্টা করুন',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _query = '';
                                    _searchController.clear();
                                    _selectedCategory = 'সব';
                                  });
                                  ref
                                      .read(dokanInventoryCatalogProvider.notifier)
                                      .refreshFromRepository();
                                },
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('পণ্য রিফ্রেশ করুন'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F766E),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = products[index];
                      final qty = state.cartQuantities[item.id] ?? 0;
                      final selected = state.isSelected(item.id);
                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _openItemDetails(item),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF0F766E)
                                  : const Color(0xFFD8E2F2),
                              width: selected ? 1.8 : 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildItemThumbnail(item),
                                  if (selected)
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: () {
                                          ref
                                              .read(dokanPosProvider.notifier)
                                              .setItemQuantity(item.id, 0);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  '${item.name} কার্ট থেকে সরানো হয়েছে'),
                                              duration:
                                                  const Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEE2E2),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            border: Border.all(
                                              color: const Color(0xFFEF4444),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  'নির্বাচিত x$qty',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Color(0xFFB91C1C),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 3),
                                              const Icon(
                                                Icons.cancel,
                                                size: 13,
                                                color: Color(0xFFEF4444),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item.name,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 15,
                                  height: 1.2,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '৳${item.price}',
                                    style: const TextStyle(
                                      color: Color(0xFF0F766E),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? const Color(0xFFEFFAF5)
                                          : item.stock <= 5
                                              ? const Color(0xFFFFF7ED)
                                              : const Color(0xFFEFFAF5),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      selected
                                          ? 'কার্টে'
                                          : item.stock <= 5
                                              ? 'কম স্টক'
                                              : 'স্টক OK',
                                      style: TextStyle(
                                        color: selected
                                            ? const Color(0xFF0F766E)
                                            : item.stock <= 5
                                                ? const Color(0xFFB45309)
                                                : const Color(0xFF047857),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: products.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: _BottomBarButton(
                  label: 'কার্ট দেখুন',
                  icon: Icons.shopping_bag_outlined,
                  onTap: _openCheckoutSheet,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD8E2F2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesmanPosItem {
  const _SalesmanPosItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    required this.category,
    required this.icon,
    this.imageUrl = '',
    this.emoji = '',
  });

  final String id;
  final String name;
  final String sku;
  final int price;
  final int stock;
  final String category;
  final IconData icon;
  final String imageUrl;
  final String emoji;
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD6E4E0)),
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE1F0EC) : const Color(0xFFF4F7F6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF006B53) : const Color(0xFFD6E4E0),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    required this.controller,
    required this.hint,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.errorText,
    this.onChanged,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String hint;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      style: const TextStyle(color: Colors.black),
      cursorColor: const Color(0xFF006B53),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF374151)),
        errorText: errorText,
        filled: true,
        fillColor: const Color(0xFFF5F8F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD6E4E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD6E4E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF006B53)),
        ),
      ),
    );
  }
}

class _BottomBarButton extends StatelessWidget {
  const _BottomBarButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.title,
    required this.value,
    required this.accent,
  });

  final String title;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
