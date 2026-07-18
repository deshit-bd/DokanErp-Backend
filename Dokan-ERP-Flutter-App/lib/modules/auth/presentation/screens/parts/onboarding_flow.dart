part of '../onboarding_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _page = 0;

  static const List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: 'আপনার দোকান এখন আপনার হাতে',
      subtitle:
          'মুদি দোকানের বিক্রয়, স্টক ও হিসাব এখন একটি প্রফেশনাল অ্যাপে সামলান।',
      actionLabel: 'পরবর্তী',
      illustration: _OnboardingIllustration.kindOne,
      accent: Color(0xFF00694C),
      tint: Color(0xFFEAF5FA),
    ),
    _OnboardingPageData(
      title: 'বিক্রি করুন মাত্র কয়েক সেকেন্ডে',
      subtitle:
          'পণ্য খুঁজুন, কার্টে যোগ করুন এবং নগদ, bKash বা বাকি দিয়ে দ্রুত বিক্রি সম্পন্ন করুন।',
      actionLabel: 'পরবর্তী',
      illustration: _OnboardingIllustration.kindTwo,
      accent: Color(0xFF0E8B69),
      tint: Color(0xFFF1FBFF),
    ),
    _OnboardingPageData(
      title: 'বাকি, লাভ-ক্ষতি সব নজরে রাখুন',
      subtitle:
          'বাকি খাতা, দৈনিক রিপোর্ট ও আয়-ব্যয়ের হিসাব এক জায়গা থেকে দেখুন।',
      actionLabel: 'শুরু করুন',
      illustration: _OnboardingIllustration.kindThree,
      accent: Color(0xFF0A6A4F),
      tint: Color(0xFFE8F5E9),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToPage(int index) async {
    if (index < 0 || index >= _pages.length) {
      return;
    }
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _handlePrimaryAction() async {
    if (_page < _pages.length - 1) {
      await _goToPage(_page + 1);
    } else {
      widget.onFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_page];

    return Container(
      color: const Color(0xFFF7FBFA),
      child: SafeArea(
        bottom: true,
        child: Column(
          children: [
            _OnboardingTopBar(
              onBack: _page == 0 ? null : () => _goToPage(_page - 1),
              onSkip: widget.onFinished,
              tint: page.tint,
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _page = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return _OnboardingPage(
                    key: ValueKey(index),
                    pageIndex: index,
                    data: data,
                    isActive: index == _page,
                    onPrimaryAction: _handlePrimaryAction,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar({
    required this.onBack,
    required this.onSkip,
    required this.tint,
  });

  final VoidCallback? onBack;
  final VoidCallback onSkip;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 64,
            height: 24,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                color: const Color(0xFF3D4943),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints.tightFor(width: 24, height: 24),
              ),
            ),
          ),
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF3D4943),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              visualDensity: VisualDensity.compact,
            ),
            child: const Text(
              'এড়িয়ে যান',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _OnboardingIllustration { kindOne, kindTwo, kindThree }

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.illustration,
    required this.accent,
    required this.tint,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final _OnboardingIllustration illustration;
  final Color accent;
  final Color tint;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    super.key,
    required this.pageIndex,
    required this.data,
    required this.isActive,
    required this.onPrimaryAction,
  });

  final int pageIndex;
  final _OnboardingPageData data;
  final bool isActive;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final illustrationHeight =
            math.min(355.0, constraints.maxHeight * 0.56);
        final titleGap = constraints.maxHeight < 500 ? 14.0 : 22.0;
        final subtitleGap = constraints.maxHeight < 500 ? 8.0 : 10.0;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      _IllustrationCard(
                        data: data,
                        height: illustrationHeight,
                        isActive: isActive,
                      ),
                      SizedBox(height: titleGap),
                      _FadeSlideEntrance(
                        delay: const Duration(milliseconds: 250),
                        isActive: isActive,
                        child: Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: Color(0xFF131D21),
                          ),
                        ),
                      ),
                      SizedBox(height: subtitleGap),
                      _FadeSlideEntrance(
                        delay: const Duration(milliseconds: 400),
                        isActive: isActive,
                        child: Text(
                          data.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.55,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF3D4943),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _FadeSlideEntrance(
                    delay: const Duration(milliseconds: 550),
                    offset: const Offset(0, 15),
                    isActive: isActive,
                    child: _PageFooter(
                      pageCount: 3,
                      activeIndex: pageIndex,
                      actionLabel: data.actionLabel,
                      accent: data.accent,
                      onAction: onPrimaryAction,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IllustrationCard extends StatelessWidget {
  const _IllustrationCard({
    required this.data,
    required this.height,
    required this.isActive,
  });

  final _OnboardingPageData data;
  final double height;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: data.tint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: _IllustrationBackground(illustration: data.illustration),
          ),
          Center(
            child: _IllustrationScene(
              illustration: data.illustration,
              accent: data.accent,
              isActive: isActive,
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationBackground extends StatelessWidget {
  const _IllustrationBackground({required this.illustration});

  final _OnboardingIllustration illustration;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.2, -0.2),
          radius: 1.2,
          colors: switch (illustration) {
            _OnboardingIllustration.kindOne => [
                const Color(0xFFEDF7FA),
                const Color(0xFFEAF5FA),
              ],
            _OnboardingIllustration.kindTwo => [
                const Color(0xFFF6FBFF),
                const Color(0xFFEAF4FA),
              ],
            _OnboardingIllustration.kindThree => [
                const Color(0xFFF0FBF2),
                const Color(0xFFE6F5E8),
              ],
          },
        ),
      ),
    );
  }
}

class _IllustrationScene extends StatelessWidget {
  const _IllustrationScene({
    required this.illustration,
    required this.accent,
    required this.isActive,
  });

  final _OnboardingIllustration illustration;
  final Color accent;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return switch (illustration) {
      _OnboardingIllustration.kindOne => _sceneOne(accent, isActive),
      _OnboardingIllustration.kindTwo => _sceneTwo(accent, isActive),
      _OnboardingIllustration.kindThree => _sceneThree(accent, isActive),
    };
  }

  Widget _sceneOne(Color accent, bool isActive) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          right: 34,
          top: 48,
          child: _AnimatedGlowCircle(
            delay: const Duration(milliseconds: 50),
            isActive: isActive,
            child: _GlowCircle(color: accent.withOpacity(0.09), size: 118),
          ),
        ),
        Positioned(
          left: 28,
          bottom: 40,
          child: _AnimatedGlowCircle(
            delay: const Duration(milliseconds: 150),
            isActive: isActive,
            child: _GlowCircle(color: accent.withOpacity(0.14), size: 154),
          ),
        ),
        Positioned(
          bottom: 22,
          child: _AnimatedIllustrationElement(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 600),
            slideOffset: const Offset(0, 50),
            floatOffsetY: 4.0,
            floatDuration: const Duration(milliseconds: 3000),
            floatDelayFraction: 0.0,
            isActive: isActive,
            child: _StoreCard(
              accent: accent,
              title: 'Store',
              subtitle: 'Dokan',
              icon: Icons.storefront_rounded,
            ),
          ),
        ),
        Positioned(
          left: 32,
          top: 72,
          child: _AnimatedIllustrationElement(
            delay: const Duration(milliseconds: 350),
            duration: const Duration(milliseconds: 550),
            slideOffset: const Offset(-25, -25),
            floatOffsetY: 6.0,
            floatDuration: const Duration(milliseconds: 2400),
            floatDelayFraction: 0.2,
            isActive: isActive,
            child: _FeatureTile(
              label: 'বিক্রি',
              icon: Icons.point_of_sale_rounded,
              color: accent,
            ),
          ),
        ),
        Positioned(
          right: 18,
          top: 104,
          child: _AnimatedIllustrationElement(
            delay: const Duration(milliseconds: 450),
            duration: const Duration(milliseconds: 550),
            slideOffset: const Offset(25, -25),
            floatOffsetY: 6.0,
            floatDuration: const Duration(milliseconds: 2600),
            floatDelayFraction: 0.5,
            isActive: isActive,
            child: const _FeatureTile(
              label: 'স্টক',
              icon: Icons.inventory_2_rounded,
              color: Color(0xFF0A8B68),
            ),
          ),
        ),
        Positioned(
          right: 42,
          bottom: 52,
          child: _AnimatedIllustrationElement(
            delay: const Duration(milliseconds: 550),
            duration: const Duration(milliseconds: 500),
            slideOffset: const Offset(25, 25),
            floatOffsetY: 5.0,
            floatDuration: const Duration(milliseconds: 2800),
            floatDelayFraction: 0.75,
            isActive: isActive,
            child: _MiniChart(accent: accent, isActive: isActive),
          ),
        ),
      ],
    );
  }

  Widget _sceneTwo(Color accent, bool isActive) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 32,
          top: 44,
          child: _AnimatedGlowCircle(
            delay: const Duration(milliseconds: 50),
            isActive: isActive,
            child: _GlowCircle(color: accent.withOpacity(0.1), size: 136),
          ),
        ),
        Positioned(
          right: 36,
          bottom: 34,
          child: _AnimatedGlowCircle(
            delay: const Duration(milliseconds: 150),
            isActive: isActive,
            child: _GlowCircle(color: accent.withOpacity(0.12), size: 156),
          ),
        ),
        Positioned(
          left: 32,
          bottom: 40,
          child: _AnimatedIllustrationElement(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 600),
            slideOffset: const Offset(0, 50),
            floatOffsetY: 4.0,
            floatDuration: const Duration(milliseconds: 2900),
            floatDelayFraction: 0.0,
            isActive: isActive,
            child: _StackedCard(
              accent: accent,
              title: 'POS',
              subtitle: 'Fast checkout',
              icon: Icons.shopping_cart_checkout_rounded,
            ),
          ),
        ),
        Positioned(
          right: 22,
          top: 56,
          child: _AnimatedIllustrationElement(
            delay: const Duration(milliseconds: 450),
            duration: const Duration(milliseconds: 550),
            slideOffset: const Offset(25, -25),
            floatOffsetY: 6.0,
            floatDuration: const Duration(milliseconds: 2500),
            floatDelayFraction: 0.6,
            isActive: isActive,
            child: _FeatureTile(
              label: 'Cash',
              icon: Icons.payments_rounded,
              color: accent,
            ),
          ),
        ),
        Positioned(
          right: 42,
          bottom: 74,
          child: _AnimatedIllustrationElement(
            delay: const Duration(milliseconds: 550),
            duration: const Duration(milliseconds: 550),
            slideOffset: const Offset(35, 0),
            floatOffsetY: 6.0,
            floatDuration: const Duration(milliseconds: 2700),
            floatDelayFraction: 0.8,
            isActive: isActive,
            child: const _FeatureTile(
              label: 'bKash',
              icon: Icons.account_balance_wallet_rounded,
              color: Color(0xFF0A8B68),
            ),
          ),
        ),
        Positioned(
          top: 126,
          child: _AnimatedIllustrationElement(
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 600),
            slideOffset: const Offset(25, 25),
            floatOffsetY: 5.0,
            floatDuration: const Duration(milliseconds: 3200),
            floatDelayFraction: 0.3,
            isActive: isActive,
            child: _ReceiptCard(accent: accent, isActive: isActive),
          ),
        ),
      ],
    );
  }

  Widget _sceneThree(Color accent, bool isActive) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          right: 36,
          top: 58,
          child: _AnimatedGlowCircle(
            delay: const Duration(milliseconds: 50),
            isActive: isActive,
            child: _GlowCircle(color: accent.withOpacity(0.1), size: 130),
          ),
        ),
        Positioned(
          left: 28,
          bottom: 34,
          child: _AnimatedGlowCircle(
            delay: const Duration(milliseconds: 150),
            isActive: isActive,
            child: _GlowCircle(color: accent.withOpacity(0.12), size: 162),
          ),
        ),
        Positioned(
          left: 34,
          top: 58,
          child: _AnimatedIllustrationElement(
            delay: const Duration(milliseconds: 350),
            duration: const Duration(milliseconds: 550),
            slideOffset: const Offset(-25, -25),
            floatOffsetY: 5.0,
            floatDuration: const Duration(milliseconds: 2600),
            floatDelayFraction: 0.4,
            isActive: isActive,
            child: _MetricCard(
              title: 'Due',
              value: '৳12,480',
              color: accent,
              isActive: isActive,
            ),
          ),
        ),
        Positioned(
          right: 28,
          bottom: 46,
          child: _AnimatedIllustrationElement(
            delay: const Duration(milliseconds: 450),
            duration: const Duration(milliseconds: 550),
            slideOffset: const Offset(25, 25),
            floatOffsetY: 5.0,
            floatDuration: const Duration(milliseconds: 2800),
            floatDelayFraction: 0.8,
            isActive: isActive,
            child: _MetricCard(
              title: 'Profit',
              value: '৳3,240',
              color: const Color(0xFF0A8B68),
              isActive: isActive,
            ),
          ),
        ),
        Positioned(
          bottom: 26,
          child: _AnimatedIllustrationElement(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 600),
            slideOffset: const Offset(0, 50),
            floatOffsetY: 4.0,
            floatDuration: const Duration(milliseconds: 3100),
            floatDelayFraction: 0.0,
            isActive: isActive,
            child: _LedgerBoard(accent: accent, isActive: isActive),
          ),
        ),
      ],
    );
  }
}
