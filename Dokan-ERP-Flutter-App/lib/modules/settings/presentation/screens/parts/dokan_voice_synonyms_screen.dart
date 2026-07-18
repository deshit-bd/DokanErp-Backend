part of '../settings_screens.dart';

class DokanVoiceSynonymsScreen extends ConsumerStatefulWidget {
  const DokanVoiceSynonymsScreen({super.key});

  @override
  ConsumerState<DokanVoiceSynonymsScreen> createState() =>
      _DokanVoiceSynonymsScreenState();
}

class _DokanVoiceSynonymsScreenState
    extends ConsumerState<DokanVoiceSynonymsScreen> {
  final TextEditingController _englishController = TextEditingController();
  final TextEditingController _banglaController = TextEditingController();

  @override
  void dispose() {
    _englishController.dispose();
    _banglaController.dispose();
    super.dispose();
  }

  void _showAddDialog(DokanScanService scanService) {
    _englishController.clear();
    _banglaController.clear();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            tr('নতুন প্রতিশব্দ যোগ করুন', 'Add New Synonym'),
            style: const TextStyle(
              color: Color(0xFF16302E),
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _englishController,
                style: const TextStyle(color: Color(0xFF16302E), fontSize: 15, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: tr('ইংরেজি শব্দ (যেমন: sugar)', 'English Word (e.g. sugar)'),
                  labelStyle: const TextStyle(color: Color(0xFF6F8280), fontSize: 13.5),
                  floatingLabelStyle: const TextStyle(color: Color(0xFF0E8F5F)),
                  filled: true,
                  fillColor: const Color(0xFFF6F8FB),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFC0D3CF), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF0E8F5F), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _banglaController,
                style: const TextStyle(color: Color(0xFF16302E), fontSize: 15, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: tr('বাংলা প্রতিশব্দ (যেমন: চিনি)', 'Bangla Synonym (e.g. চিনি)'),
                  labelStyle: const TextStyle(color: Color(0xFF6F8280), fontSize: 13.5),
                  floatingLabelStyle: const TextStyle(color: Color(0xFF0E8F5F)),
                  filled: true,
                  fillColor: const Color(0xFFF6F8FB),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFC0D3CF), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF0E8F5F), width: 2),
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6F8280),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: Text(tr('বাতিল', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                final eng = _englishController.text.trim();
                final bng = _banglaController.text.trim();
                if (eng.isNotEmpty && bng.isNotEmpty) {
                  scanService.registerSynonym(eng, bng);
                  setState(() {});
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(tr('প্রতিশব্দ সফলভাবে যোগ হয়েছে!', 'Synonym added successfully!')),
                      backgroundColor: const Color(0xFF0E8F5F),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E8F5F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: Text(tr('যোগ করুন', 'Add')),
            ),
          ],
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanService = ref.watch(dokanScanServiceProvider);
    final custom = scanService.customSynonyms;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          tr('ভয়েস প্রতিশব্দ (Synonyms)', 'Voice Synonyms'),
          style: const TextStyle(
            color: Color(0xFF16302E),
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF16302E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DokanFadeSlideIn(
              delay: const Duration(milliseconds: 30),
              duration: const Duration(milliseconds: 400),
              slideOffset: const Offset(0, 15),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2EBE8)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF0E8F5F), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tr(
                          'অ্যাপে কোনো ইংরেজি পণ্যের নাম ভয়েসে বাংলা উচ্চারণে মেলাতে এখানে প্রতিশব্দ যোগ করুন। (যেমন: english = pepsi, bangla = পেপসি)',
                          'Add translation synonyms here so that spoken Bangla words map correctly to English products. (e.g. english = pepsi, bangla = পেপসি)',
                        ),
                        style: const TextStyle(
                          color: Color(0xFF71827F),
                          fontSize: 13,
                          height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
            const SizedBox(height: 20),
            DokanFadeSlideIn(
              delay: const Duration(milliseconds: 70),
              duration: const Duration(milliseconds: 400),
              slideOffset: const Offset(0, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('কাস্টম প্রতিশব্দ তালিকা', 'Custom Synonyms'),
                    style: const TextStyle(
                      color: Color(0xFF16302E),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showAddDialog(scanService),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0E8F5F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(tr('যোগ করুন', 'Add')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (custom.isEmpty)
              DokanFadeSlideIn(
                delay: const Duration(milliseconds: 110),
                duration: const Duration(milliseconds: 400),
                slideOffset: const Offset(0, 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  child: Text(
                    tr('কোনো কাস্টম প্রতিশব্দ যোগ করা হয়নি।', 'No custom synonyms added yet.'),
                    style: const TextStyle(color: Color(0xFF71827F), fontSize: 14),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: custom.length,
                itemBuilder: (context, index) {
                  final key = custom.keys.elementAt(index);
                  final values = custom[key] ?? [];
                  return DokanFadeSlideIn(
                    delay: Duration(milliseconds: 110 + index * 30),
                    duration: const Duration(milliseconds: 450),
                    slideOffset: const Offset(0, 10),
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2EBE8)),
                      ),
                      child: ListTile(
                        title: Text(
                          key.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF16302E),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: Text(
                          values.join(', '),
                          style: const TextStyle(color: Color(0xFF71827F)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final val in values)
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                onPressed: () {
                                  scanService.removeSynonym(key, val);
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(tr('প্রতিশব্দ মুছে ফেলা হয়েছে', 'Synonym removed')),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
            DokanFadeSlideIn(
              delay: const Duration(milliseconds: 150),
              duration: const Duration(milliseconds: 400),
              slideOffset: const Offset(0, 15),
              child: Text(
                tr('ডিফল্ট সিস্টেম প্রতিশব্দ (পঠনযোগ্য)', 'Default System Synonyms (Read-only)'),
                style: const TextStyle(
                  color: Color(0xFF16302E),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: scanService.defaultSynonyms.length,
              itemBuilder: (context, index) {
                final key = scanService.defaultSynonyms.keys.elementAt(index);
                final values = scanService.defaultSynonyms[key] ?? [];
                return DokanFadeSlideIn(
                  delay: Duration(milliseconds: 190 + index * 30),
                  duration: const Duration(milliseconds: 450),
                  slideOffset: const Offset(0, 10),
                  child: Card(
                    color: const Color(0xFFF1F5F3),
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFE2EBE8)),
                    ),
                    child: ListTile(
                      title: Text(
                        key.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF71827F),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        values.join(', '),
                        style: const TextStyle(color: Color(0xFF71827F)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
