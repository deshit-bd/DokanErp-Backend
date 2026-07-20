import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Engagement / habit card for the home dashboard.
///
/// Combines several behavioural-design levers into one card so a shopkeeper
/// has a reason to open the app every day:
///   • Streak (🔥 consecutive active days)  -> consistency / loss aversion
///   • Daily sales target + progress bar    -> goal-gradient
///   • Target-hit celebration               -> instant reward (peak-end)
///   • Growth insight vs yesterday          -> reciprocity / positive framing
class DokanHabitCard extends StatefulWidget {
  const DokanHabitCard({
    super.key,
    required this.todaySales,
    required this.todayProfit,
    this.growthPercent = 0,
  });

  final int todaySales;
  final int todayProfit;
  final int growthPercent;

  @override
  State<DokanHabitCard> createState() => _DokanHabitCardState();
}

class _DokanHabitCardState extends State<DokanHabitCard> {
  static const _streakKey = 'engagement_streak';
  static const _bestStreakKey = 'engagement_best_streak';
  static const _lastOpenKey = 'engagement_last_open';
  static const _targetKey = 'engagement_daily_target';

  int _streak = 0;
  int _bestStreak = 0;
  int _target = 5000;
  bool _loaded = false;
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    _loadAndRecord();
    _scheduleMidnightUpdate();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  void _scheduleMidnightUpdate() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final difference = tomorrow.difference(now);
    
    // Add 1 second delay to ensure we are actually past midnight
    _midnightTimer = Timer(difference + const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {});
        _scheduleMidnightUpdate();
      }
    });
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> _loadAndRecord() async {
    final prefs = await SharedPreferences.getInstance();
    var streak = prefs.getInt(_streakKey) ?? 0;
    var best = prefs.getInt(_bestStreakKey) ?? 0;
    final target = prefs.getInt(_targetKey) ?? 5000;
    final lastOpen = prefs.getString(_lastOpenKey);

    final today = _dateKey(DateTime.now());
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));

    if (lastOpen != today) {
      streak = (lastOpen == yesterday) ? streak + 1 : 1;
      if (streak > best) best = streak;
      await prefs.setInt(_streakKey, streak);
      await prefs.setInt(_bestStreakKey, best);
      await prefs.setString(_lastOpenKey, today);
    }

    if (!mounted) return;
    setState(() {
      _streak = streak;
      _bestStreak = best;
      _target = target;
      _loaded = true;
    });
  }

  Future<void> _editTarget() async {
    final controller = TextEditingController(text: _target.toString());
    final value = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('আজকের বিক্রির টার্গেট'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: '৳ ',
            hintText: 'যেমন: 5000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('বাতিল'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(int.tryParse(controller.text.trim())),
            child: const Text('সেট করুন'),
          ),
        ],
      ),
    );
    if (value == null || value <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_targetKey, value);
    if (mounted) setState(() => _target = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox(height: 8);

    final progress =
        _target <= 0 ? 0.0 : (widget.todaySales / _target).clamp(0.0, 1.0);
    final hitTarget = widget.todaySales >= _target && _target > 0;

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C8C67), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C8C67).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's date with calendar icon
          Row(
            children: [
              _buildDynamicCalendarIcon(DateTime.now()),
              const SizedBox(width: 12),
              Text(
                _formatBengaliDate(DateTime.now()),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Target progress
          Row(
            children: [
              Text(
                hitTarget
                    ? '🎉 আজকের টার্গেট পূরণ হয়েছে!'
                    : 'আজকের টার্গেট: ৳$_target',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _editTarget,
                child: const Icon(Icons.edit, color: Colors.white70, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation(
                hitTarget ? const Color(0xFFFFE08A) : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '৳${widget.todaySales} / ৳$_target (${(progress * 100).round()}%)',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9), fontSize: 11),
          ),
          // Growth insight (peak-end / positive framing)
          if (widget.growthPercent != 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.growthPercent > 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: Colors.white,
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.growthPercent > 0
                        ? 'গতকালের চেয়ে ${widget.growthPercent}% বেশি বিক্রি 🚀'
                        : 'আজ একটু কম কাল আরও ভালো হবে 💪',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _toBengaliDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengali = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    var output = input;
    for (var i = 0; i < english.length; i++) {
      output = output.replaceAll(english[i], bengali[i]);
    }
    return output;
  }

  Widget _buildDynamicCalendarIcon(DateTime date) {
    final dayStr = _toBengaliDigits(date.day.toString());

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Calendar top header (red)
          Container(
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFFD32F2F),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ),
          // Day number inside calendar
          Expanded(
            child: Center(
              child: Text(
                dayStr,
                style: const TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBengaliDate(DateTime date) {
    const months = [
      'জানুয়ারি',
      'ফেব্রুয়ারি',
      'মার্চ',
      'এপ্রিল',
      'মে',
      'জুন',
      'জুলাই',
      'আগস্ট',
      'সেপ্টেম্বর',
      'অক্টোবর',
      'নভেম্বর',
      'ডিসেম্বর'
    ];
    
    final dayShort = switch (date.weekday) {
      DateTime.sunday => 'রবি',
      DateTime.monday => 'সোম',
      DateTime.tuesday => 'মঙ্গল',
      DateTime.wednesday => 'বুধ',
      DateTime.thursday => 'বৃহস্পতি',
      DateTime.friday => 'শুক্র',
      DateTime.saturday => 'শনি',
      _ => '',
    };

    final day = _toBengaliDigits(date.day.toString());
    final monthName = months[date.month - 1];
    final year = _toBengaliDigits(date.year.toString());

    return '$dayShort, $day $monthName $year';
  }
}
