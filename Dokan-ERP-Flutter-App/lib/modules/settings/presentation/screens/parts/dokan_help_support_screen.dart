part of '../settings_screens.dart';

class DokanHelpSupportScreen extends ConsumerStatefulWidget {
  const DokanHelpSupportScreen({super.key});

  @override
  ConsumerState<DokanHelpSupportScreen> createState() =>
      _DokanHelpSupportScreenState();
}

class _DokanHelpSupportScreenState
    extends ConsumerState<DokanHelpSupportScreen> {
  int? _expandedFaq;
  String _whatsapp = "8801700000000";
  String _email = "support@dokanerp.com";
  String _phone = "+8801700000000";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSupportContact();
    });
  }

  Future<void> _fetchSupportContact() async {
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get('/app/api/settings/support-contact');
      final data = response.data;
      setState(() {
        _whatsapp = data['whatsapp']?.toString() ?? _whatsapp;
        _email = data['email']?.toString() ?? _email;
        _phone = data['phone']?.toString() ?? _phone;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final faqs = [
      (
        'কিভাবে পণ্য যোগ করবো?',
        'পণ্য মেনুতে গিয়ে নতুন পণ্য যোগ করুন এবং তথ্য পূরণ করুন।'
      ),
      (
        'কিভাবে বিক্রয় করবো?',
        'বিক্রয় সেকশনে গিয়ে পণ্য নির্বাচন করে বিক্রয় সম্পন্ন করুন।'
      ),
      (
        'স্টক কম হলে কি হবে?',
        'কম স্টক লিমিট অনুযায়ী ড্যাশবোর্ডে সতর্কতা দেখাবে।'
      ),
      (
        'ট্যাক্স কিভাবে কাজ করে?',
        'ট্যাক্স সেটিংস অনুযায়ী স্বয়ংক্রিয়ভাবে বিক্রয়ে প্রয়োগ হবে।'
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'গাইড ও সাপোর্ট',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
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
              child: const Text(
                'অ্যাপ ব্যবহার নির্দেশিকা ও সহায়তা নিন',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            DokanFadeSlideIn(
              delay: const Duration(milliseconds: 60),
              duration: const Duration(milliseconds: 400),
              slideOffset: const Offset(0, 15),
              child: _guideCard(
                Icons.menu_book_outlined,
                'অ্যাপ ব্যবহার নির্দেশিকা',
                'How to use inventory system',
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DokanGuideDetailScreen(
                      title: 'অ্যাপ ব্যবহার নির্দেশিকা',
                      steps: [
                        'হোম স্ক্রিন বা সাইডবার থেকে আপনার কাঙ্ক্ষিত অপশন সিলেক্ট করুন।',
                        'ড্যাশবোর্ডের প্রধান ফিচারগুলো যেমন ক্যাশ বাক্স, ইনভেন্টরি, সেলস এবং কাস্টমার ডাটাবেস লক্ষ্য করুন।',
                        'কুইক অ্যাকশন মেনু বা নোটিফিকেশন বার ব্যবহার করে গুরুত্বপূর্ণ সংকেত বা নোটিফিকেশন চেক করুন।',
                      ],
                    ),
                  ),
                ),
              ),
            ),
            DokanFadeSlideIn(
              delay: const Duration(milliseconds: 90),
              duration: const Duration(milliseconds: 400),
              slideOffset: const Offset(0, 15),
              child: _guideCard(
                Icons.point_of_sale_outlined,
                'বিক্রয় শুরু করুন',
                'Sales flow guide',
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DokanGuideDetailScreen(
                      title: 'বিক্রয় শুরু করুন',
                      steps: [
                        'হোম স্ক্রিন থেকে বা সাইডবার মেনু থেকে "বিক্রয়" (POS) সেকশনে প্রবেশ করুন।',
                        'প্রোডাক্ট ক্যাটাগরি বা সার্চ বার ব্যবহার করে আপনার পণ্যগুলো নির্বাচন করে কার্টে যুক্ত করুন।',
                        'প্রয়োজন সাপেক্ষে কাস্টমার সিলেক্ট করুন বা ভ্যাট/ডিসকাউন্ট/চার্জ অ্যাপ্লাই করুন।',
                        'পেমেন্ট মেথড (যেমন: ক্যাশ, কার্ড, mobile ব্যাংকিং বা বাকি) সিলেক্ট করুন।',
                        '"বিক্রয় নিশ্চিত করুন" বাটনে ক্লিক করে ইনভয়েস সফলভাবে জেনারেট করুন।',
                      ],
                    ),
                  ),
                ),
              ),
            ),
            DokanFadeSlideIn(
              delay: const Duration(milliseconds: 120),
              duration: const Duration(milliseconds: 400),
              slideOffset: const Offset(0, 15),
              child: _guideCard(
                Icons.inventory_2_outlined,
                'পণ্য যোগ করুন',
                'Product management guide',
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DokanGuideDetailScreen(
                      title: 'পণ্য যোগ করুন',
                      steps: [
                        'অ্যাপের মূল নেভিগেশন বার থেকে "ইনভেন্টরি" বা "পণ্য" অপশনে ক্লিক করুন।',
                        '"নতুন পণ্য যোগ করুন" বাটনে ক্লিক করে পণ্য এন্ট্রি ফর্ম ওপেন করুন।',
                        'পণ্যের নাম, ছবি, ক্যাটাগরি, ইউনিট এবং বারকোড (যদি থাকে) ইনপুট দিন।',
                        'পণ্যের কেনা দাম (ক্রয় মূল্য) এবং বিক্রয় মূল্য নির্ধারণ করুন।',
                        'স্টক কাউন্ট এবং লো-স্টক নোটিফিকেশন পেতে কাঙ্ক্ষিত সতর্কতা সীমা দিয়ে পণ্যটি সেভ করুন।',
                      ],
                    ),
                  ),
                ),
              ),
            ),
            DokanFadeSlideIn(
              delay: const Duration(milliseconds: 150),
              duration: const Duration(milliseconds: 400),
              slideOffset: const Offset(0, 15),
              child: _guideCard(
                Icons.bar_chart_outlined,
                'রিপোর্ট দেখুন',
                'Reports explanation',
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DokanGuideDetailScreen(
                      title: 'রিপোর্ট দেখুন',
                      steps: [
                        'নেভিগেশন প্যানেল বা প্রোফাইল মেনু থেকে "রিপোর্ট ও অ্যানালিটিক্স" সেকশনে প্রবেশ করুন।',
                        'নির্দিষ্ট তারিখ বা সময়সীমা সিলেক্ট করে বিক্রয় ও লাভের ডাটা ফিল্টার করুন।',
                        'ব্যবসার মোট ক্রয়, বিক্রয়, লাভ এবং বকেয়া বাকির হিসাব সংক্ষেপে গ্রাফ বা চার্টের মাধ্যমে পর্যালোচনা করুন।',
                        'প্রয়োজনবোধে কাস্টমার ও সাপ্লায়ার লেজার রিপোর্ট আলাদাভাবে এক্সপোর্ট বা ভিউ করুন।',
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            DokanFadeSlideIn(
              delay: const Duration(milliseconds: 180),
              duration: const Duration(milliseconds: 400),
              slideOffset: const Offset(0, 15),
              child: const Text(
                'সাধারণ প্রশ্ন',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(faqs.length, (index) {
              final item = faqs[index];
              final expanded = _expandedFaq == index;

              return DokanFadeSlideIn(
                delay: Duration(milliseconds: 210 + index * 30),
                duration: const Duration(milliseconds: 400),
                slideOffset: const Offset(0, 12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _expandedFaq = expanded ? null : index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.$1,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            AnimatedRotation(
                              duration: const Duration(milliseconds: 250),
                              turns: expanded ? 0.5 : 0,
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 250),
                      crossFadeState: expanded
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                        child: Text(
                          item.$2,
                          style: const TextStyle(
                            color: Colors.black,
                            height: 1.5,
                          ),
                        ),
                      ),
                      secondChild: const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              );
            }),
            const SizedBox(height: 24),
            DokanFadeSlideIn(
              delay: const Duration(milliseconds: 330),
              duration: const Duration(milliseconds: 400),
              slideOffset: const Offset(0, 15),
              child: const Text(
                'সাপোর্টের সাথে যোগাযোগ করুন',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 12),
            DokanFadeSlideIn(
              delay: const Duration(milliseconds: 360),
              duration: const Duration(milliseconds: 400),
              slideOffset: const Offset(0, 15),
              child: _supportButton(
                'WhatsApp Support',
                Icons.chat_outlined,
                () => _launch('https://wa.me/$_whatsapp'),
              ),
            ),
            const SizedBox(height: 10),
            DokanFadeSlideIn(
              delay: const Duration(milliseconds: 390),
              duration: const Duration(milliseconds: 400),
              slideOffset: const Offset(0, 15),
              child: _supportButton(
                'Email Support',
                Icons.email_outlined,
                () => _launch('mailto:$_email?subject=Dokan%20ERP%20Support'),
              ),
            ),
            const SizedBox(height: 10),
            DokanFadeSlideIn(
              delay: const Duration(milliseconds: 420),
              duration: const Duration(milliseconds: 400),
              slideOffset: const Offset(0, 15),
              child: _supportButton(
                'Call Support',
                Icons.call_outlined,
                () => _launch('tel:$_phone'),
              ),
            ),
            const SizedBox(height: 24),
            DokanFadeSlideIn(
              delay: const Duration(milliseconds: 450),
              duration: const Duration(milliseconds: 400),
              slideOffset: const Offset(0, 15),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Info',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'App Version: 1.0.0',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Build Number: 100',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Last Update: June 2026',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('অ্যাকশনটি সম্পন্ন করা যায়নি: $urlString')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('অ্যাকশনটি সম্পন্ন করা যায়নি: $urlString')),
        );
      }
    }
  }

  Widget _guideCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _supportButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.black),
        label: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
          minimumSize: const Size.fromHeight(52),
        ),
      ),
    );
  }
}

class DokanGuideDetailScreen extends StatelessWidget {
  const DokanGuideDetailScreen({
    super.key,
    required this.title,
    required this.steps,
  });

  final String title;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF4F7FB),
              foregroundColor: const Color(0xFF16302E),
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF16302E),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DokanFadeSlideIn(
              delay: const Duration(milliseconds: 30),
              duration: const Duration(milliseconds: 450),
              slideOffset: const Offset(0, 18),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE3EBE8)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C21413C),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          color: Color(0xFF0E8F5F), size: 24),
                      SizedBox(width: 10),
                      Text(
                        'সহজ নির্দেশনাবলী',
                        style: TextStyle(
                          color: Color(0xFF16302E),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFF0F4F3)),
                  const SizedBox(height: 8),
                  ...steps.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final text = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEAF5F1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$index',
                              style: const TextStyle(
                                color: Color(0xFF0E8F5F),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              text,
                              style: const TextStyle(
                                color: Color(0xFF16302E),
                                fontSize: 14.5,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}

class DokanNotificationSubscriptionSettingsScreen
    extends ConsumerStatefulWidget {
  const DokanNotificationSubscriptionSettingsScreen({
    super.key,
    this.lockedMode = false,
  });

  final bool lockedMode;

  @override
  ConsumerState<DokanNotificationSubscriptionSettingsScreen> createState() =>
      _DokanNotificationSubscriptionSettingsScreenState();
}

class _DokanNotificationSubscriptionSettingsScreenState
    extends ConsumerState<DokanNotificationSubscriptionSettingsScreen> {
  bool _isMonthly = false;

  static const Color _bg = Color(0xFFF4F7FB);
  static const Color _text = Color(0xFF16302E);
  static const Color _muted = Color(0xFF6F8280);
  static const Color _border = Color(0xFFE3EBE8);
  static const Color _accent = Color(0xFF0E8F5F);
  static const Color _accentDeep = Color(0xFF0A7A52);
  static const Color _warning = Color(0xFFD9822B);
  static const Color _danger = Color(0xFFE15241);

  @override
  Widget build(BuildContext context) {
    final subInfoAsync = ref.watch(subscriptionInfoProvider);

    return PopScope(
      canPop: !widget.lockedMode,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          surfaceTintColor: _bg,
          elevation: 0,
          centerTitle: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: IconButton(
              onPressed: widget.lockedMode
                  ? () => ref.read(dokanAppFlowProvider.notifier).logout()
                  : () => Navigator.of(context).maybePop(),
              icon: Icon(
                widget.lockedMode
                    ? Icons.logout_rounded
                    : Icons.arrow_back_rounded,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _text,
              ),
            ),
          ),
          leadingWidth: 72,
          title: Text(
            widget.lockedMode
                ? 'সাবস্ক্রিপশন পেমেন্ট প্রয়োজন'
                : 'প্ল্যান ও পেমেন্ট',
            style: const TextStyle(
              color: _text,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SafeArea(
          child: subInfoAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: _accent),
            ),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: _danger, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'সাবস্ক্রিপশন তথ্য লোড করা সম্ভব হয়নি।\n$err',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(subscriptionInfoProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('আবার চেষ্টা করুন'),
                    ),
                  ],
                ),
              ),
            ),
            data: (info) {
              final isTrial = info.tier == 'TRIAL';
              final plans = <_SubscriptionPlanData>[
                if (isTrial)
                  _SubscriptionPlanData(
                    name: 'ফ্রি ট্রায়াল',
                    price: '৳০',
                    priceSuffix: _isMonthly ? '/মাস' : '',
                    monthlyPrice: 0,
                    subtitle: 'নতুন দোকানের জন্য ফ্রি ট্রায়াল',
                    badge: isTrial ? 'বর্তমান প্ল্যান' : 'মেয়াদ শেষ',
                    badgeColor: isTrial
                        ? const Color(0xFFEAF5F1)
                        : const Color(0xFFFDECEC),
                    badgeTextColor: isTrial ? _accent : _danger,
                    icon: Icons.storefront_rounded,
                    iconBackground: const Color(0xFFEAF5F1),
                    iconColor: _accent,
                    current: isTrial,
                    popular: false,
                    upgradeLabel: 'চলমান',
                    features: const <String>[
                      '১টি দোকান',
                      '৫০টি পণ্য সীমা',
                      '১ জন সেলসম্যান ইউজার',
                      'বেসিক রিপোর্ট',
                    ],
                  ),
                _SubscriptionPlanData(
                  name: 'পে-অ্যাজ-ইউ-গো',
                  price: _isMonthly
                      ? '৳${trNum((info.ratePerAccount * 30).toInt())}'
                      : '৳${trNum(info.ratePerAccount.toInt())}',
                  priceSuffix: _isMonthly ? '/মাস' : '/দিন',
                  monthlyPrice: (info.ratePerAccount * 30).toInt(),
                  subtitle: _isMonthly
                      ? 'সক্রিয় সেলসম্যান অনুযায়ী মাসিক সার্ভিস ফি'
                      : 'সক্রিয় সেলসম্যান অনুযায়ী প্রতিদিনের সার্ভিস ফি',
                  badge: !isTrial ? 'বর্তমান প্ল্যান' : 'জনপ্রিয়',
                  badgeColor: const Color(0xFFFFF4E5),
                  badgeTextColor: _warning,
                  icon: Icons.workspace_premium_rounded,
                  iconBackground: const Color(0xFFFFF4E5),
                  iconColor: _warning,
                  current: !isTrial,
                  popular: isTrial,
                  upgradeLabel:
                      info.amountDue > 0 ? 'বকেয়া পরিশোধ' : 'আপগ্রেড করুন',
                  features: <String>[
                    _isMonthly
                        ? 'প্রতি সেলসম্যান প্রতি মাসে মাত্র ${trNum((info.ratePerAccount * 30).toInt())} টাকা'
                        : 'প্রতি সেলসম্যান প্রতিদিন মাত্র ${trNum(info.ratePerAccount.toInt())} টাকা',
                    'অসীম পণ্য সীমা',
                    'অসীম সেলসম্যান ইউজার',
                    'আয়-ব্যয়ের রিপোর্ট ও দ্রুত সাপোর্ট',
                  ],
                ),
              ];

              final paymentHistory = info.recentPayments.map((payment) {
                final isSuccess = payment.status == 'SUCCESS';
                final isPending = payment.status == 'PENDING';

                final dateStr = () {
                  try {
                    final dt = DateTime.parse(payment.paidAt);
                    return AppDateFormatter.dayMonthYear(dt);
                  } catch (_) {
                    return payment.paidAt;
                  }
                }();

                return _SubscriptionHistoryData(
                  planName: 'পে-অ্যাজ-ইউ-গো',
                  amount: '৳${payment.amount.toStringAsFixed(0)}',
                  date: dateStr,
                  status:
                      isSuccess ? 'সফল' : (isPending ? 'অপেক্ষমাণ' : 'ব্যর্থ'),
                  statusColor: isSuccess
                      ? const Color(0xFFEAF5F1)
                      : (isPending
                          ? const Color(0xFFFFF4E5)
                          : const Color(0xFFFDECEC)),
                  statusTextColor:
                      isSuccess ? _accent : (isPending ? _warning : _danger),
                  icon: isSuccess
                      ? Icons.verified_rounded
                      : (isPending
                          ? Icons.schedule_rounded
                          : Icons.error_rounded),
                );
              }).toList();

              return LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth =
                      constraints.maxWidth > 760 ? 760.0 : constraints.maxWidth;
                  final bottomPadding =
                      MediaQuery.viewInsetsOf(context).bottom + 24;
                  return RefreshIndicator(
                    color: _accent,
                    onRefresh: () async {
                      ref.invalidate(subscriptionInfoProvider);
                      await ref.read(subscriptionInfoProvider.future);
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        SliverPadding(
                          padding:
                              EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
                          sliver: SliverToBoxAdapter(
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: contentWidth),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (widget.lockedMode && !info.allowed) ...[
                                      DokanFadeSlideIn(
                                        delay: const Duration(milliseconds: 30),
                                        duration: const Duration(milliseconds: 500),
                                        slideOffset: const Offset(0, 10),
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 18),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFDECEC),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: const Color(0xFFF2C8C2),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'পেমেন্ট না করা পর্যন্ত অন্য কোনো পেজে যাওয়া যাবে না।',
                                                style: TextStyle(
                                                  color: _danger,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                info.message ??
                                                    'সাবস্ক্রিপশন চালু করতে নিচের বকেয়া পরিশোধ করুন।',
                                                style: const TextStyle(
                                                  color: _text,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                    DokanFadeSlideIn(
                                      delay: const Duration(milliseconds: 70),
                                      duration: const Duration(milliseconds: 500),
                                      slideOffset: const Offset(0, 15),
                                      child: _CurrentPlanSummaryCard(
                                        info: info,
                                        accent: _accent,
                                        accentDeep: _accentDeep,
                                        borderColor: _border,
                                        textColor: _text,
                                        mutedColor: _muted,
                                        onPrimaryAction: () => _openPlanDetails(
                                            context, plans.first),
                                        onUpgrade: () => _openCheckout(
                                            context, plans.last, ref),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    DokanFadeSlideIn(
                                      delay: const Duration(milliseconds: 110),
                                      duration: const Duration(milliseconds: 500),
                                      slideOffset: const Offset(0, 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const _SubscriptionSectionLabel(
                                              title: 'উপলব্ধ প্ল্যান'),
                                          Container(
                                            width: 170,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE3EBE8),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Stack(
                                              children: [
                                                AnimatedAlign(
                                                  duration: const Duration(milliseconds: 250),
                                                  curve: Curves.easeInOut,
                                                  alignment: _isMonthly
                                                      ? Alignment.centerRight
                                                      : Alignment.centerLeft,
                                                  child: FractionallySizedBox(
                                                    widthFactor: 0.5,
                                                    child: Container(
                                                      margin: const EdgeInsets.all(3),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(9),
                                                        boxShadow: const [
                                                          BoxShadow(
                                                            color: Color(0x12000000),
                                                            blurRadius: 4,
                                                            offset: Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: GestureDetector(
                                                        behavior: HitTestBehavior.opaque,
                                                        onTap: () => setState(() => _isMonthly = false),
                                                        child: Center(
                                                          child: AnimatedDefaultTextStyle(
                                                            duration: const Duration(milliseconds: 200),
                                                            style: TextStyle(
                                                              color: !_isMonthly
                                                                  ? _accent
                                                                  : const Color(0xFF6F8280),
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w800,
                                                            ),
                                                            child: const Text('প্রতিদিনের'),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: GestureDetector(
                                                        behavior: HitTestBehavior.opaque,
                                                        onTap: () => setState(() => _isMonthly = true),
                                                        child: Center(
                                                          child: AnimatedDefaultTextStyle(
                                                            duration: const Duration(milliseconds: 200),
                                                            style: TextStyle(
                                                              color: _isMonthly
                                                                  ? _accent
                                                                  : const Color(0xFF6F8280),
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w800,
                                                            ),
                                                            child: const Text('মাসিক'),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    DokanFadeSlideIn(
                                      delay: const Duration(milliseconds: 150),
                                      duration: const Duration(milliseconds: 500),
                                      slideOffset: const Offset(0, 15),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 300),
                                        transitionBuilder: (Widget child, Animation<double> animation) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(0.0, 0.05),
                                                end: Offset.zero,
                                              ).animate(animation),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: LayoutBuilder(
                                          key: ValueKey<bool>(_isMonthly),
                                          builder: (context, planConstraints) {
                                            final cardWidth =
                                                planConstraints.maxWidth > 620
                                                    ? (planConstraints.maxWidth -
                                                            12) /
                                                        2
                                                    : planConstraints.maxWidth;
                                            return Wrap(
                                              spacing: 12,
                                              runSpacing: 12,
                                              children: plans
                                                  .map(
                                                    (plan) => SizedBox(
                                                      width: cardWidth,
                                                      child: _SubscriptionPlanCard(
                                                        data: plan,
                                                        accent: _accent,
                                                        borderColor: _border,
                                                        textColor: _text,
                                                        mutedColor: _muted,
                                                        onViewPlan: () =>
                                                            _openPlanDetails(
                                                                context, plan),
                                                        onUpgrade: () =>
                                                            _openCheckout(
                                                                context, plan, ref),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(growable: false),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    if (paymentHistory.isNotEmpty) ...[
                                      const DokanFadeSlideIn(
                                        delay: Duration(milliseconds: 190),
                                        duration: Duration(milliseconds: 500),
                                        slideOffset: Offset(0, 10),
                                        child: _SubscriptionSectionLabel(
                                            title: 'পেমেন্ট ইতিহাস'),
                                      ),
                                      const SizedBox(height: 10),
                                      ...List.generate(paymentHistory.length, (index) {
                                        final item = paymentHistory[index];
                                        return DokanFadeSlideIn(
                                          delay: Duration(milliseconds: 190 + (index * 40)),
                                          duration: const Duration(milliseconds: 500),
                                          slideOffset: const Offset(0, 15),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(bottom: 12),
                                            child: _SubscriptionHistoryCard(
                                              data: item,
                                              textColor: _text,
                                              mutedColor: _muted,
                                              borderColor: _border,
                                            ),
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 6),
                                    ],
                                    DokanFadeSlideIn(
                                      delay: Duration(
                                          milliseconds: 190 +
                                              (paymentHistory.isNotEmpty
                                                  ? paymentHistory.length * 40 + 20
                                                  : 40)),
                                      duration: const Duration(milliseconds: 500),
                                      slideOffset: const Offset(0, 15),
                                      child: const Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          _SubscriptionSectionLabel(
                                              title: 'সাহায্য ও সাপোর্ট'),
                                          SizedBox(height: 10),
                                          _SubscriptionSupportCard(
                                            accent: _accent,
                                            accentDeep: _accentDeep,
                                            borderColor: _border,
                                            textColor: _text,
                                            mutedColor: _muted,
                                          ),
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
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _openPlanDetails(BuildContext context, _SubscriptionPlanData plan) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PlanDetailsSheet(plan: plan),
    );
  }

  void _openCheckout(
      BuildContext context, _SubscriptionPlanData plan, WidgetRef ref) {
    Navigator.of(context)
        .push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _SubscriptionCheckoutScreen(plan: plan),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    )
        .then((_) {
      ref.invalidate(subscriptionInfoProvider);
    });
  }
}


