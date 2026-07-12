part of '../product_screens.dart';

class DokanCategorySettingsScreen extends ConsumerStatefulWidget {
  const DokanCategorySettingsScreen({super.key});

  @override
  ConsumerState<DokanCategorySettingsScreen> createState() =>
      _DokanCategorySettingsScreenState();
}

class _DokanCategorySettingsScreenState
    extends ConsumerState<DokanCategorySettingsScreen> {
  final TextEditingController _addController = TextEditingController();
  final TextEditingController _editController = TextEditingController();
  String? _newCategoryError;
  String? _editError;
  String? _editingCategory;
  String? _deletePendingCategory;

  @override
  void dispose() {
    _addController.dispose();
    _editController.dispose();
    super.dispose();
  }

  List<String> _managedCategories(List<String> categories) {
    return categories
        .where((category) => category != DokanCategoryNotifier.uncategorized)
        .toList(growable: false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFD43B3B) : const Color(0xFF0C8C67),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _validateCategoryName(String value, {String? currentName}) {
    final name = value.trim();
    if (name.isEmpty) {
      return 'ক্যাটাগরির নাম দিন';
    }
    if (name.length < 2) {
      return 'কমপক্ষে ২ অক্ষর দিন';
    }
    final categories = ref.read(categoryProvider);
    final duplicate = categories.any((existing) {
      final same = existing.trim().toLowerCase() == name.toLowerCase();
      if (!same) return false;
      if (currentName == null) return true;
      return existing.trim().toLowerCase() != currentName.trim().toLowerCase();
    });
    if (duplicate) {
      return 'এই ক্যাটাগরি আগে থেকেই আছে';
    }
    return null;
  }

  void _saveNewCategory() {
    final value = _addController.text.trim();
    final error = _validateCategoryName(value);
    if (error != null) {
      setState(() => _newCategoryError = error);
      return;
    }
    ref.read(categoryProvider.notifier).addCategory(value);
    setState(() {
      _newCategoryError = null;
      _addController.clear();
    });
    _showSnackBar('ক্যাটাগরি সফলভাবে যোগ করা হয়েছে');
  }

  void _startEdit(String category) {
    if (category == DokanCategoryNotifier.uncategorized) {
      _showSnackBar('এই ক্যাটাগরি পরিবর্তন করা যাবে না', isError: true);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _editingCategory = category;
      _deletePendingCategory = null;
      _editError = null;
      _editController.text = category;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingCategory = null;
      _editError = null;
      _editController.clear();
    });
  }

  void _saveEditCategory(String oldCategory) {
    final value = _editController.text.trim();
    final error = _validateCategoryName(value, currentName: oldCategory);
    if (error != null) {
      setState(() => _editError = error);
      return;
    }
    ref.read(categoryProvider.notifier).updateCategory(oldCategory, value);
    ref
        .read(dokanInventoryCatalogProvider.notifier)
        .reassignCategory(oldCategory, value);
    setState(() {
      _editingCategory = null;
      _editError = null;
      _editController.clear();
    });
    _showSnackBar('ক্যাটাগরি সফলভাবে হালনাগাদ হয়েছে');
  }

  void _startDelete(String category) {
    if (category == DokanCategoryNotifier.uncategorized) {
      _showSnackBar('এই ক্যাটাগরি মুছা যাবে না', isError: true);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _deletePendingCategory = category;
      _editingCategory = null;
      _editError = null;
    });
  }

  void _cancelDelete() {
    setState(() => _deletePendingCategory = null);
  }

  void _confirmDeleteCategory(String category) {
    ref.read(categoryProvider.notifier).deleteCategory(category);
    ref.read(dokanInventoryCatalogProvider.notifier).reassignCategory(
          category,
          DokanCategoryNotifier.uncategorized,
        );
    setState(() {
      _deletePendingCategory = null;
      if (_editingCategory == category) {
        _editingCategory = null;
        _editController.clear();
      }
    });
    _showSnackBar('ক্যাটাগরি সফলভাবে মুছে ফেলা হয়েছে');
  }

  Widget _buildCategoryTile(String category) {
    final isEditing = _editingCategory == category;
    final isDeletePending = _deletePendingCategory == category;
    final isProtected = category == DokanCategoryNotifier.uncategorized;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9E6E2)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7F0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.category_rounded,
                      color: Color(0xFF00694C), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isProtected
                            ? 'সিস্টেম ক্যাটাগরি'
                            : 'পণ্য ও ফিল্টারে ব্যবহৃত হয়',
                        style: const TextStyle(
                          color: Color(0xFF5F6A66),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: isProtected ? null : () => _startEdit(category),
                  icon:
                      const Icon(Icons.edit_outlined, color: Color(0xFF00694C)),
                ),
                IconButton(
                  onPressed: isProtected ? null : () => _startDelete(category),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFD43B3B)),
                ),
              ],
            ),
          ),
          if (isEditing)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _editController,
                    autofocus: true,
                    style: const TextStyle(
                        color: Color(0xFF111111), fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: 'নতুন নাম লিখুন',
                      hintStyle: const TextStyle(color: Color(0xFF9BA5A1)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD9E6E2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: Color(0xFF00694C), width: 1.5),
                      ),
                    ),
                    onChanged: (_) {
                      if (_editError != null) {
                        setState(() => _editError = null);
                      }
                    },
                    onSubmitted: (_) => _saveEditCategory(category),
                  ),
                  if (_editError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _editError!,
                      style: const TextStyle(
                          color: Color(0xFFD43B3B),
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: _cancelEdit,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3D4943),
                          side: const BorderSide(color: Color(0xFFD9E6E2)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('বাতিল',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _saveEditCategory(category),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0C8C67),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('হালনাগাদ করুন',
                              style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (isDeletePending)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3C2C2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'এই ক্যাটাগরি মুছবেন?',
                      style: TextStyle(
                          color: Color(0xFFD43B3B),
                          fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"$category" মুছে দিলে এর পণ্যগুলো "অজানা" ক্যাটাগরিতে চলে যাবে।',
                      style: const TextStyle(
                          color: Color(0xFF3D4943),
                          fontWeight: FontWeight.w600,
                          height: 1.35),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _cancelDelete,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF3D4943),
                              side: const BorderSide(color: Color(0xFFD9E6E2)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('না',
                                style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _confirmDeleteCategory(category),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD43B3B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('হ্যাঁ, মুছুন',
                                style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _managedCategories(ref.watch(categoryProvider));
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3FAFB),
        elevation: 0,
        foregroundColor: const Color(0xFF111111),
        title: const Text(
          'ক্যাটাগরি সেটিংস',
          style: TextStyle(
            color: Color(0xFF00694C),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          _InventoryPageCard(
            title: 'নতুন ক্যাটাগরি যোগ করুন',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _addController,
                  style: const TextStyle(
                      color: Color(0xFF111111), fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: 'যেমন: চাল-ডাল',
                    hintStyle: const TextStyle(color: Color(0xFF9BA5A1)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFD9E6E2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFF00694C), width: 1.5),
                    ),
                  ),
                  onChanged: (_) {
                    if (_newCategoryError != null) {
                      setState(() => _newCategoryError = null);
                    }
                  },
                  onSubmitted: (_) => _saveNewCategory(),
                ),
                if (_newCategoryError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _newCategoryError!,
                    style: const TextStyle(
                        color: Color(0xFFD43B3B), fontWeight: FontWeight.w800),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveNewCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C8C67),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'ক্যাটাগরি যোগ করুন',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _InventoryPageCard(
            title: 'বর্তমান ক্যাটাগরি',
            child: categories.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'এখনও কোনো ক্যাটাগরি নেই',
                      style: TextStyle(
                          color: Color(0xFF3D4943),
                          fontWeight: FontWeight.w700),
                    ),
                  )
                : Column(
                    children: categories.map(_buildCategoryTile).toList(),
                  ),
          ),
          const SizedBox(height: 14),
          _InventoryPageCard(
            title: 'ক্যাটাগরি নীতি',
            child: const Text(
              'নতুন ক্যাটাগরি যোগ, সম্পাদনা বা মুছলে পণ্য তালিকা, ফিল্টার, স্টক পেজ এবং সতর্কতা পেজে তা সাথে সাথে update হবে।',
              style: TextStyle(
                  color: Color(0xFF3D4943),
                  fontWeight: FontWeight.w600,
                  height: 1.45),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ProductBottomNav(
        selectedIndex: 2,
        onHomeTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokanHomeDashboardScreen()),
        ),
        onSalesTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokanPosSalesHistoryScreen()),
        ),
        onProductsTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokanProductListScreen()),
        ),
        onReportsTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokanReportsHomeScreen()),
        ),
        onMoreTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokanAroOptionScreen()),
        ),
      ),
    );
  }
}
