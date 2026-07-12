part of '../settings_screens.dart';

class _TaxChargeSheet extends StatefulWidget {
  const _TaxChargeSheet({
    required this.existingNames,
    required this.isTax,
    this.oldItem,
  });

  final _TaxChargeItem? oldItem;
  final Set<String> existingNames;
  final bool isTax;

  @override
  State<_TaxChargeSheet> createState() => _TaxChargeSheetState();
}

class _TaxChargeSheetState extends State<_TaxChargeSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _value;
  late _TaxChargeValueType _type;

  @override
  void initState() {
    super.initState();
    final defaultName = widget.isTax ? 'ভ্যাট' : 'ডেলিভারি চার্জ';
    _name = TextEditingController(text: widget.oldItem?.name ?? defaultName);
    _value =
        TextEditingController(text: widget.oldItem?.value.toString() ?? '');
    _type = widget.oldItem?.type ??
        (widget.isTax
            ? _TaxChargeValueType.percent
            : _TaxChargeValueType.fixed);
  }

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final theme = ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(
        primary: Colors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        labelStyle: const TextStyle(color: Colors.black54),
        hintStyle: const TextStyle(color: Colors.black45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );

    return Theme(
      data: theme,
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _name,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: widget.isTax
                          ? 'করের নাম (যেমন: ভ্যাট / VAT)'
                          : 'চার্জের নাম (যেমন: ডেলিভারি চার্জ / Delivery)',
                      labelStyle: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600),
                      hintText: widget.isTax ? 'ভ্যাট / VAT' : 'ডেলিভারি চার্জ',
                      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      final name = v?.trim() ?? '';
                      if (name.isEmpty) return 'নাম লিখুন';
                      if (widget.existingNames.contains(name.toLowerCase()))
                        return 'এই নামটি আগে থেকেই আছে';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<_TaxChargeValueType>(
                    value: _type,
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'ধরন',
                      labelStyle: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _TaxChargeValueType.values
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.label,
                                  style: const TextStyle(color: Colors.black)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _type = v ?? _type),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _value,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: NumericInputFormatters.decimal,
                    decoration: InputDecoration(
                      labelText: 'মান',
                      labelStyle: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      final raw = v?.trim() ?? '';
                      final num = double.tryParse(raw);
                      if (raw.isEmpty) return 'মান লিখুন';
                      if (num == null) return 'সঠিক সংখ্যা লিখুন';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white),
                      child: const Text('সংরক্ষণ করুন'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('বাতিল',
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _TaxChargeItem(
        id: widget.oldItem?.id,
        name: _name.text.trim(),
        value: double.parse(_value.text.trim()),
        type: _type,
      ),
    );
  }
}
