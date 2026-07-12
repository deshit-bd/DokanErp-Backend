part of '../settings_screens.dart';

class _DokanStoreBinListScreen extends ConsumerStatefulWidget {
  const _DokanStoreBinListScreen(
      {required this.zone, required this.rack, required this.shelf});
  final _StoreZoneData zone;
  final _StoreRackData rack;
  final _StoreShelfData shelf;

  @override
  ConsumerState<_DokanStoreBinListScreen> createState() =>
      _DokanStoreBinListScreenState();
}

class _DokanStoreBinListScreenState
    extends ConsumerState<_DokanStoreBinListScreen> {
  _StoreBinData? _selectedBin;
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final zone = widget.zone;
    final rack = widget.rack;
    final shelf = widget.shelf;
    final contentWidth = MediaQuery.of(context).size.width > 980
        ? 980.0
        : MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: DokanStoreLayoutManagementScreen._bg,
      appBar: AppBar(
        backgroundColor: DokanStoreLayoutManagementScreen._bg,
        surfaceTintColor: DokanStoreLayoutManagementScreen._bg,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: DokanStoreLayoutManagementScreen._text,
            ),
          ),
        ),
        leadingWidth: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              shelf.name,
              style: const TextStyle(
                color: DokanStoreLayoutManagementScreen._text,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'র‍্যাক: ${rack.name} · জোন: ${zone.name}',
              style: const TextStyle(
                color: DokanStoreLayoutManagementScreen._muted,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _StoreLayoutBreadcrumb(
                          steps: [
                            'হোম',
                            zone.name,
                            rack.name,
                            shelf.name,
                            'বিন'
                          ],
                        ),
                        const SizedBox(height: 14),
                        _StoreLayoutSectionCard(
                          title: 'বিন লিস্ট',
                          subtitle: '${shelf.bins.length}টি বিন নিবন্ধিত আছে',
                          accent: DokanStoreLayoutManagementScreen._accent,
                          child: Column(
                            children: [
                              if (shelf.bins.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Text(
                                      'কোনো বিন পাওয়া যায়নি। একটি নতুন বিন যোগ করুন।'),
                                )
                              else
                                for (final bin in shelf.bins) ...[
                                  _buildBinCard(context, bin),
                                  if (bin != shelf.bins.last)
                                    const SizedBox(height: 12),
                                ],
                            ],
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditBottomSheet(
          context,
          type: 'Bin',
          parent: shelf,
          onSaved: _refresh,
        ),
        backgroundColor: DokanStoreLayoutManagementScreen._accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('বিন যোগ করুন',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBinCard(BuildContext context, _StoreBinData bin) {
    Color badgeColor;
    String badgeText;

    if (bin.quantity == 0) {
      badgeColor = Colors.red;
      badgeText = 'স্টক আউট';
    } else if (bin.isLowStock) {
      badgeColor = Colors.orange;
      badgeText = 'লো স্টক';
    } else {
      badgeColor = Colors.green;
      badgeText = 'স্টক ওকে';
    }

    return _StoreLayoutItemCard(
      title: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            bin.code,
            style: const TextStyle(
              color: DokanStoreLayoutManagementScreen._text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        'স্টক: ${bin.quantity} পিস',
        style: const TextStyle(
          color: DokanStoreLayoutManagementScreen._muted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      icon: Icons.archive_rounded,
      iconColor: Colors.blue,
      iconBgColor: Colors.blue.withOpacity(0.12),
      isSelected: _selectedBin == bin,
      onTap: () async {
        setState(() {
          _selectedBin = bin;
        });
        await Future.delayed(const Duration(milliseconds: 250));
        if (!context.mounted) return;
        _showContextMenu(
          context,
          ref,
          type: 'Bin',
          item: bin,
          parent: widget.shelf,
          onChanged: _refresh,
        );
        setState(() {
          _selectedBin = null;
        });
      },
      onMorePressed: () => _showContextMenu(
        context,
        ref,
        type: 'Bin',
        item: bin,
        parent: widget.shelf,
        onChanged: _refresh,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: () {
                if (bin.quantity > 0) {
                  setState(() {
                    bin.quantity--;
                  });
                  _refresh();
                }
              },
              icon: const Icon(Icons.remove_circle_outline_rounded,
                  color: Colors.red, size: 18),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 28,
            child: Text(
              '${bin.quantity}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: DokanStoreLayoutManagementScreen._text,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: () {
                setState(() {
                  bin.quantity++;
                });
                _refresh();
              },
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: DokanStoreLayoutManagementScreen._accent, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddEditBottomSheetContent extends ConsumerStatefulWidget {
  const _AddEditBottomSheetContent({
    required this.type,
    this.item,
    this.parent,
    required this.onSaved,
  });

  final String type;
  final Object? item;
  final Object? parent;
  final VoidCallback onSaved;

  @override
  ConsumerState<_AddEditBottomSheetContent> createState() =>
      _AddEditBottomSheetContentState();
}

class _AddEditBottomSheetContentState
    extends ConsumerState<_AddEditBottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  _StoreZoneData? _selectedZone;
  _StoreRackData? _selectedRack;
  _StoreShelfData? _selectedShelf;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _quantityController = TextEditingController(text: '0');

    if (widget.item != null) {
      if (widget.item is _StoreZoneData) {
        _nameController.text = (widget.item as _StoreZoneData).name;
      } else if (widget.item is _StoreRackData) {
        _nameController.text = (widget.item as _StoreRackData).name;
        for (final z in _storeZones) {
          if (z.racks.contains(widget.item)) {
            _selectedZone = z;
            break;
          }
        }
      } else if (widget.item is _StoreShelfData) {
        final shelf = widget.item as _StoreShelfData;
        _nameController.text = shelf.name;
        for (final z in _storeZones) {
          for (final r in z.racks) {
            if (r.shelves.contains(shelf)) {
              _selectedRack = r;
              break;
            }
          }
        }
      } else if (widget.item is _StoreBinData) {
        final bin = widget.item as _StoreBinData;
        _nameController.text = bin.code;
        _quantityController.text = bin.quantity.toString();
        for (final z in _storeZones) {
          for (final r in z.racks) {
            for (final s in r.shelves) {
              if (s.bins.contains(bin)) {
                _selectedShelf = s;
                break;
              }
            }
          }
        }
      }
    } else {
      if (widget.parent != null) {
        if (widget.parent is _StoreZoneData) {
          _selectedZone = widget.parent as _StoreZoneData;
        } else if (widget.parent is _StoreRackData) {
          _selectedRack = widget.parent as _StoreRackData;
        } else if (widget.parent is _StoreShelfData) {
          _selectedShelf = widget.parent as _StoreShelfData;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  bool _isSaving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;

    setState(() {
      _isSaving = true;
    });

    try {
      final repo = ref.read(inventoryLayoutRepositoryProvider);

      if (widget.item != null) {
        // EDIT MODE
        if (widget.item is _StoreZoneData) {
          final zone = widget.item as _StoreZoneData;
          await repo.updateZone(zone.id ?? '', {
            'name': name,
          });
          zone.name = name;
        } else if (widget.item is _StoreRackData) {
          final rack = widget.item as _StoreRackData;
          await repo.updateRack(rack.id ?? '', {
            'name': name,
          });
          rack.name = name;
        } else if (widget.item is _StoreShelfData) {
          final shelf = widget.item as _StoreShelfData;
          await repo.updateShelf(shelf.id ?? '', {
            'name': name,
          });
          shelf.name = name;
        } else if (widget.item is _StoreBinData) {
          final bin = widget.item as _StoreBinData;
          await repo.updateBin(bin.id ?? '', {
            'code': name,
            'quantity': qty,
          });
          bin.code = name;
          bin.quantity = qty;
        }
      } else {
        // CREATE MODE
        if (widget.type == 'Zone') {
          final responseData = await repo.createZone({
            'name': name,
          });
          final zoneData = responseData['zone'];
          _storeZones.add(_StoreZoneData(
            id: zoneData['id'],
            name: zoneData['name'],
            racks: [],
          ));
        } else if (widget.type == 'Rack') {
          if (_selectedZone == null) return;
          final responseData = await repo.createRack({
            'zoneId': _selectedZone!.id,
            'name': name,
            'autoGenerate': false,
          });
          final rackData = responseData['rack'];
          _selectedZone!.racks.add(_StoreRackData(
            id: rackData['id'],
            name: rackData['name'],
            shelves: [],
          ));
        } else if (widget.type == 'Shelf') {
          if (_selectedRack == null) return;
          _StoreZoneData? zone;
          for (final z in _storeZones) {
            if (z.racks.contains(_selectedRack)) {
              zone = z;
              break;
            }
          }
          if (zone == null) return;
          final responseData = await repo.createShelf({
            'zoneId': zone.id,
            'rackId': _selectedRack!.id,
            'name': name,
          });
          final shelfData = responseData['shelf'];
          _selectedRack!.shelves.add(_StoreShelfData(
            id: shelfData['id'],
            name: shelfData['name'],
            direction: shelfData['direction'] ?? 'উপরের সারি',
            bins: [],
          ));
        } else if (widget.type == 'Bin') {
          if (_selectedShelf == null) return;
          _StoreZoneData? zone;
          _StoreRackData? rack;
          for (final z in _storeZones) {
            for (final r in z.racks) {
              if (r.shelves.contains(_selectedShelf)) {
                zone = z;
                rack = r;
                break;
              }
            }
          }
          if (zone == null || rack == null) return;
          final responseData = await repo.createBin({
            'zoneId': zone.id,
            'rackId': rack.id,
            'shelfId': _selectedShelf!.id,
            'code': name,
            'quantity': qty,
          });
          final binData = responseData['bin'];
          _selectedShelf!.bins.add(_StoreBinData(
            id: binData['id'],
            code: binData['code'],
            quantity: qty,
            rackName: rack.name,
            shelfName: _selectedShelf!.name,
          ));
        }
      }
      widget.onSaved();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_inventoryMutationErrorMessage(e))),
        );
      }
    } finally {
      if (context.mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.item != null
        ? '${widget.type} সম্পাদনা'
        : 'নতুন ${widget.type} যোগ করুন';
    final allRacks = _storeZones.expand((z) => z.racks).toList();
    final allShelves =
        _storeZones.expand((z) => z.racks.expand((r) => r.shelves)).toList();

    return SafeArea(
        child: Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 48,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.type == 'Rack' && widget.item == null) ...[
                DropdownButtonFormField<_StoreZoneData>(
                  value: _selectedZone,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  decoration: const InputDecoration(
                    labelText: 'জোন নির্বাচন করুন',
                    labelStyle: TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  items: _storeZones.map((z) {
                    return DropdownMenuItem(
                      value: z,
                      child: Text(z.name,
                          style: const TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: widget.parent != null
                      ? null
                      : (val) {
                          setState(() {
                            _selectedZone = val;
                          });
                        },
                  validator: (val) =>
                      val == null ? 'দয়া করে একটি জোন নির্বাচন করুন' : null,
                ),
                const SizedBox(height: 14),
              ],
              if (widget.type == 'Shelf' && widget.item == null) ...[
                DropdownButtonFormField<_StoreRackData>(
                  value: _selectedRack,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  decoration: const InputDecoration(
                    labelText: 'র‍্যাক নির্বাচন করুন',
                    labelStyle: TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  items: allRacks.map((r) {
                    return DropdownMenuItem(
                      value: r,
                      child: Text(r.name,
                          style: const TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: widget.parent != null
                      ? null
                      : (val) {
                          setState(() {
                            _selectedRack = val;
                          });
                        },
                  validator: (val) =>
                      val == null ? 'দয়া করে একটি র‍্যাক নির্বাচন করুন' : null,
                ),
                const SizedBox(height: 14),
              ],
              if (widget.type == 'Bin' && widget.item == null) ...[
                DropdownButtonFormField<_StoreShelfData>(
                  value: _selectedShelf,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  decoration: const InputDecoration(
                    labelText: 'শেলফ নির্বাচন করুন',
                    labelStyle: TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  items: allShelves.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s.name,
                          style: const TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: widget.parent != null
                      ? null
                      : (val) {
                          setState(() {
                            _selectedShelf = val;
                          });
                        },
                  validator: (val) =>
                      val == null ? 'দয়া করে একটি শেলফ নির্বাচন করুন' : null,
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.black, fontSize: 15),
                decoration: InputDecoration(
                  labelText: widget.type == 'Bin'
                      ? 'বিন কোড (যেমন: A-A-S1-B3)'
                      : '${widget.type} নাম',
                  labelStyle: const TextStyle(color: Colors.black54),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'দয়া করে সঠিক নাম লিখুন'
                    : null,
              ),
              const SizedBox(height: 14),
              if (widget.type == 'Bin') ...[
                TextFormField(
                  controller: _quantityController,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  keyboardType: TextInputType.number,
                  inputFormatters: NumericInputFormatters.wholeNumber,
                  decoration: const InputDecoration(
                    labelText: 'স্টক পরিমাণ (পিস)',
                    labelStyle: TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty)
                      return 'দয়া করে স্টক সংখ্যা লিখুন';
                    if (int.tryParse(val) == null)
                      return 'দয়া করে সঠিক সংখ্যা লিখুন';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
              ],
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: DokanStoreLayoutManagementScreen._accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('সংরক্ষণ করুন',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    ));
  }
}

void _showAddEditBottomSheet(
  BuildContext context, {
  required String type,
  Object? item,
  Object? parent,
  required VoidCallback onSaved,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return _AddEditBottomSheetContent(
        type: type,
        item: item,
        parent: parent,
        onSaved: onSaved,
      );
    },
  );
}

void _showContextMenu(
  BuildContext context,
  WidgetRef ref, {
  required String type,
  required Object item,
  Object? parent,
  required VoidCallback onChanged,
  bool readOnly = false,
}) {
  if (readOnly) {
    _showInventoryWriteUnavailableMessage(context);
    return;
  }
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            if (type != 'Bin')
              ListTile(
                leading: const Icon(Icons.add_circle_outline_rounded,
                    color: Color(0xFF0E8F5F)),
                title: Text(
                  type == 'Zone'
                      ? 'র‍্যাক যোগ করুন'
                      : (type == 'Rack' ? 'শেলফ যোগ করুন' : 'বিন যোগ করুন'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddEditBottomSheet(
                    context,
                    type: type == 'Zone'
                        ? 'Rack'
                        : (type == 'Rack' ? 'Shelf' : 'Bin'),
                    parent: item,
                    onSaved: onChanged,
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: Colors.blue),
              title: const Text('সম্পাদনা',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              onTap: () {
                Navigator.of(context).pop();
                _showAddEditBottomSheet(
                  context,
                  type: type,
                  item: item,
                  onSaved: onChanged,
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_forever_rounded, color: Colors.red),
              title: const Text('মুছে ফেলুন',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              onTap: () {
                Navigator.of(context).pop();
                _deleteItem(context, ref, item, onChanged);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

void _deleteItem(
    BuildContext context, WidgetRef ref, Object item, VoidCallback onDeleted) {
  String warningText = '';
  if (item is _StoreZoneData) {
    warningText =
        'এই জোনটি ডিলিট করলে এর অধীনে থাকা সব র‍্যাক, শেলফ এবং বিন ডিলিট হয়ে যাবে। আপনি কি নিশ্চিত?';
  } else if (item is _StoreRackData) {
    warningText =
        'এই র‍্যাকটি ডিলিট করলে এর অধীনে থাকা সব শেলফ এবং বিন ডিলিট হয়ে যাবে। আপনি কি নিশ্চিত?';
  } else if (item is _StoreShelfData) {
    warningText =
        'এই শেলফটি ডিলিট করলে এর অধীনে থাকা সব বিন ডিলিট হয়ে যাবে। আপনি কি নিশ্চিত?';
  } else if (item is _StoreBinData) {
    warningText = 'এই বিনটি ডিলিট করতে চান?';
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('সতর্কতা', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(warningText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                final repo = ref.read(inventoryLayoutRepositoryProvider);
                if (item is _StoreZoneData) {
                  await repo.deleteZone(item.id ?? '');
                  _storeZones.remove(item);
                } else if (item is _StoreRackData) {
                  await repo.deleteRack(item.id ?? '');
                  for (final z in _storeZones) {
                    if (z.racks.contains(item)) {
                      z.racks.remove(item);
                      break;
                    }
                  }
                } else if (item is _StoreShelfData) {
                  await repo.deleteShelf(item.id ?? '');
                  for (final z in _storeZones) {
                    for (final r in z.racks) {
                      if (r.shelves.contains(item)) {
                        r.shelves.remove(item);
                        break;
                      }
                    }
                  }
                } else if (item is _StoreBinData) {
                  await repo.deleteBin(item.id ?? '');
                  for (final z in _storeZones) {
                    for (final r in z.racks) {
                      for (final s in r.shelves) {
                        if (s.bins.contains(item)) {
                          s.bins.remove(item);
                          break;
                        }
                      }
                    }
                  }
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                onDeleted();
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_inventoryMutationErrorMessage(e))),
                  );
                }
              }
            },
            child:
                const Text('মুছে ফেলুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

void _showInventoryWriteUnavailableMessage(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'সার্ভারের সাথে লাইভ সংযোগ নেই। ক্যাশে থাকা ডাটা দেখানো হচ্ছে, তাই এখন নতুন তথ্য সংরক্ষণ করা যাবে না।',
      ),
    ),
  );
}

String _inventoryMutationErrorMessage(Object error) {
  if (error is NetworkException &&
      error.kind == NetworkExceptionKind.noConnection) {
    return 'সার্ভারের সাথে সংযোগ করা যাচ্ছে না। আপনার ইন্টারনেট বা API সার্ভার চালু আছে কি না দেখে আবার চেষ্টা করুন।';
  }
  return 'অনুরোধটি সম্পন্ন করা যায়নি: $error';
}
