part of '../settings_screens.dart';

class _UCHeaderCard extends StatelessWidget {
  const _UCHeaderCard({
    required this.count,
    required this.countSuffix,
    required this.icon,
    required this.onAdd,
  });

  final int count;
  final String countSuffix;
  final IconData icon;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E8F5F), Color(0xFF0A6F4A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x220B5B40), blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '$count$countSuffix',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800),
            ),
          ),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 17),
            label: const Text('নতুন যোগ করুন',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0E8F5F),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _UCList<T> extends StatelessWidget {
  const _UCList({
    required this.items,
    required this.iconColor,
    required this.icon,
    required this.onEdit,
    required this.onDelete,
  });

  final List<T> items;
  final Color iconColor;
  final IconData icon;
  final void Function(T) onEdit;
  final void Function(T) onDelete;

  String _getBangla(T item) {
    if (item is DokanCategory) return item.name;
    if (item is DokanUnit) return item.name;
    if (item is _CategoryData) return item.bangla;
    return (item as _UnitData).bangla;
  }

  String _getEnglish(T item) {
    if (item is DokanCategory) return item.description ?? '';
    if (item is DokanUnit) return item.shortName;
    if (item is _CategoryData) return item.english;
    return (item as _UnitData).english;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3EBE8)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0C21413C), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            DokanFadeSlideIn(
              delay: Duration(milliseconds: i * 30),
              duration: const Duration(milliseconds: 450),
              slideOffset: const Offset(0, 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(icon, color: iconColor, size: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_getBangla(items[i]),
                              style: const TextStyle(
                                  color: Color(0xFF16302E),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          if (_getEnglish(items[i]).isNotEmpty)
                            Text(_getEnglish(items[i]),
                                style: const TextStyle(
                                    color: Color(0xFF6F8280),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => onEdit(items[i]),
                      icon: const Icon(Icons.edit_rounded, size: 17),
                      style: IconButton.styleFrom(
                        foregroundColor: const Color(0xFF0E8F5F),
                        backgroundColor: const Color(0xFFEAF5F1),
                        padding: const EdgeInsets.all(7),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: () => onDelete(items[i]),
                      icon: const Icon(Icons.delete_outline_rounded, size: 17),
                      style: IconButton.styleFrom(
                        foregroundColor: const Color(0xFFE15241),
                        backgroundColor: const Color(0xFFFEF0EF),
                        padding: const EdgeInsets.all(7),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i < items.length - 1)
              const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Color(0xFFF0F4F3)),
          ],
        ],
      ),
    );
  }
}

class _UCEmptyState extends StatelessWidget {
  const _UCEmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 44),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3EBE8)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: const Color(0xFFB0C4BE)),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(
                  color: Color(0xFF8A9896),
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Add / Edit Sheets ────────────────────────────────────────────────────────

class _AddEditCategorySheet extends ConsumerStatefulWidget {
  const _AddEditCategorySheet({this.existing, required this.onSaved});
  final DokanCategory? existing;
  final VoidCallback onSaved;

  @override
  ConsumerState<_AddEditCategorySheet> createState() =>
      _AddEditCategorySheetState();
}

class _AddEditCategorySheetState extends ConsumerState<_AddEditCategorySheet> {
  static const Color _text = Color(0xFF16302E);
  static const Color _muted = Color(0xFF6F8280);

  late final TextEditingController _banglaCtrl;
  late final TextEditingController _englishCtrl;
  String? _banglaError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _banglaCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _englishCtrl =
        TextEditingController(text: widget.existing?.description ?? '');
  }

  @override
  void dispose() {
    _banglaCtrl.dispose();
    _englishCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bangla = _banglaCtrl.text.trim();
    if (bangla.isEmpty) {
      setState(() => _banglaError = 'নাম আবশ্যক');
      return;
    }
    final english = _englishCtrl.text.trim();
    setState(() {
      _isSaving = true;
      _banglaError = null;
    });

    try {
      if (widget.existing != null) {
        await ref.read(dokanCategoryListProvider.notifier).updateCategory(
              widget.existing!.id,
              bangla,
              english.isEmpty ? null : english,
            );
      } else {
        await ref.read(dokanCategoryListProvider.notifier).addCategory(
              bangla,
              english.isEmpty ? null : english,
            );
      }
      widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _banglaError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 24,
                  offset: Offset(0, -4)),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'ক্যাটেগরি সম্পাদনা' : 'নতুন ক্যাটেগরি যোগ করুন',
                      style: const TextStyle(
                          color: _text,
                          fontSize: 17,
                          fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(foregroundColor: _muted),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _StoreTextField(
                  label: 'নাম *',
                  controller: _banglaCtrl,
                  onChanged: (_) => setState(() => _banglaError = null),
                  errorText: _banglaError,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 14),
                  child: Text('যেমন: মুদি',
                      style: const TextStyle(color: _muted, fontSize: 11.5)),
                ),
                _StoreTextField(
                  label: 'বিবরণ (Description)',
                  controller: _englishCtrl,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.only(left: 2, bottom: 20),
                  child: Text('যেমন: মুদি পণ্যসমূহ',
                      style: TextStyle(color: _muted, fontSize: 11.5)),
                ),
                _isSaving
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _StoreActionButton(
                        label: isEdit
                            ? 'পরিবর্তন সংরক্ষণ করুন'
                            : 'ক্যাটেগরি যোগ করুন',
                        icon: isEdit ? Icons.save_rounded : Icons.add_rounded,
                        onPressed: _save,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
