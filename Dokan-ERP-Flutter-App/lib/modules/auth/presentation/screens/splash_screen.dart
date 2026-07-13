import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DokanSplashScreen extends StatelessWidget {
  const DokanSplashScreen({required this.progress});

  final int progress;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0, 100);
    final percent = (clamped / 100).clamp(0.0, 1.0);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF12362F),
            Color(0xFF081712),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            const Positioned.fill(child: _Atmosphere()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: const _BrandCluster(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ProgressOverlay(
                progress: clamped,
                percent: percent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressOverlay extends StatelessWidget {
  const _ProgressOverlay({
    required this.progress,
    required this.percent,
  });

  final int progress;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 5,
              color: Colors.white.withOpacity(0.18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: percent,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00FFB9),
                          Color(0xFF00694C),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tr('সিস্টেম চালু হচ্ছে', 'SYSTEM INITIALIZING'),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '$progress%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Atmosphere extends StatelessWidget {
  const _Atmosphere();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.15, -0.2),
          radius: 1.0,
          colors: [
            Color(0x1AFFFFFF),
            Color(0x00000000),
          ],
        ),
      ),
    );
  }
}

class _BrandCluster extends StatelessWidget {
  const _BrandCluster();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/dokan_logo.png',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          tr('আপনার দোকানের সহকারী', 'Your Store Assistant'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
