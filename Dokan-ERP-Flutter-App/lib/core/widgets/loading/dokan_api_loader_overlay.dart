import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DokanApiLoaderOverlay extends StatefulWidget {
  const DokanApiLoaderOverlay({
    super.key,
    required this.loading,
    required this.child,
  });

  final bool loading;
  final Widget child;

  @override
  State<DokanApiLoaderOverlay> createState() => _DokanApiLoaderOverlayState();
}

class _DokanApiLoaderOverlayState extends State<DokanApiLoaderOverlay>
    with SingleTickerProviderStateMixin {
  static const _showDelay = Duration(milliseconds: 140);
  static const _minimumVisibleTime = Duration(milliseconds: 420);

  late final AnimationController _controller;
  Timer? _transitionTimer;
  DateTime? _visibleSince;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );
    _updateVisibility();
  }

  @override
  void didUpdateWidget(covariant DokanApiLoaderOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loading != widget.loading) {
      _updateVisibility();
    }
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _updateVisibility() {
    _transitionTimer?.cancel();
    if (widget.loading) {
      if (_visible) return;
      _transitionTimer = Timer(_showDelay, () {
        if (!mounted || !widget.loading) return;
        setState(() {
          _visible = true;
          _visibleSince = DateTime.now();
          _controller.repeat();
        });
      });
      return;
    }

    if (!_visible) return;
    final elapsed = DateTime.now().difference(_visibleSince ?? DateTime.now());
    final remaining = _minimumVisibleTime - elapsed;
    _transitionTimer = Timer(
      remaining.isNegative ? Duration.zero : remaining,
      () {
        if (!mounted || widget.loading) return;
        setState(() {
          _visible = false;
          _visibleSince = null;
          _controller.stop();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          ignoring: !_visible,
          child: AbsorbPointer(
            absorbing: _visible,
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: ColoredBox(
                color: const Color(0x99041915),
                child: Center(
                  child: AnimatedScale(
                    scale: _visible ? 1 : 0.92,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 188),
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FFFC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFD5EEE5)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3D001B13),
                            blurRadius: 30,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) => CustomPaint(
                              size: const Size.square(64),
                              painter: _DokanLoaderPainter(_controller.value),
                              child: const SizedBox.square(
                                dimension: 64,
                                child: Center(
                                  child: Icon(
                                    Icons.storefront_rounded,
                                    size: 26,
                                    color: Color(0xFF08785B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            tr('একটু অপেক্ষা করুন', 'Please wait'),
                            style: const TextStyle(
                              color: Color(0xFF12372D),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          _LoadingText(animation: _controller),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingText extends StatelessWidget {
  const _LoadingText({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final dotCount = ((animation.value * 4).floor() % 4);
        return Text(
          '${tr('তথ্য লোড হচ্ছে', 'Loading data')}${'.' * dotCount}',
          style: const TextStyle(
            color: Color(0xFF5A736C),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}

class _DokanLoaderPainter extends CustomPainter {
  const _DokanLoaderPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 4;
    final track = Paint()
      ..color = const Color(0xFFDDF3EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    final primary = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF08A77A),
          Color(0xFF58D7B3),
          Color(0xFF08A77A),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;
    final pulse = Paint()
      ..color = const Color(0xFF0C8C67).withOpacity(
        0.08 + math.sin(progress * math.pi * 2).abs() * 0.08,
      );

    canvas.drawCircle(center, radius - 7, pulse);
    canvas.drawCircle(center, radius, track);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * math.pi * 2);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 1.25,
      false,
      primary,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DokanLoaderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
