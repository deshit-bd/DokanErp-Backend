import 'package:flutter/material.dart';

/// A subtle, professional entrance animation: fade + slide-up.
///
/// Wrap any widget (card, section, list item) with it. Use [delay] to stagger
/// a group of items so they cascade in.
class DokanFadeSlideIn extends StatefulWidget {
  const DokanFadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 420),
    this.offset = 18,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// How far (px) the child slides up while fading in.
  final double offset;

  @override
  State<DokanFadeSlideIn> createState() => _DokanFadeSlideInState();
}

class _DokanFadeSlideInState extends State<DokanFadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _curve.value) * widget.offset),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Drop-in count-up for an already-formatted string such as "৳ ৩২২" or "১২ টি".
///
/// It finds the numeric run (English or Bangla digits), animates it up from
/// zero, and keeps the surrounding prefix/suffix (currency, unit) intact — so
/// it can replace a plain `Text(value)` without touching the caller.
class AnimatedNumberString extends StatelessWidget {
  const AnimatedNumberString(
    this.text, {
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 850),
    this.curve = Curves.easeOutCubic,
    this.maxLines,
    this.softWrap,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final int? maxLines;
  final bool? softWrap;
  final TextAlign? textAlign;

  static const _banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

  String _toBangla(int value) => value
      .toString()
      .split('')
      .map((c) {
        final d = int.tryParse(c);
        return d == null ? c : _banglaDigits[d];
      })
      .join();

  @override
  Widget build(BuildContext context) {
    final match = RegExp(r'[0-9০-৯]+').firstMatch(text);
    if (match == null) {
      return Text(text,
          style: style,
          maxLines: maxLines,
          softWrap: softWrap,
          textAlign: textAlign);
    }
    final numStr = match.group(0)!;
    final english = numStr.split('').map((c) {
      final i = _banglaDigits.indexOf(c);
      return i >= 0 ? '$i' : c;
    }).join();
    final target = int.tryParse(english) ?? 0;
    final isBangla = _banglaDigits.any(numStr.contains);
    final prefix = text.substring(0, match.start);
    final suffix = text.substring(match.end);

    // Skip the animation for very large values (looks janky) and just show it.
    if (target > 100000000) {
      return Text(text,
          style: style,
          maxLines: maxLines,
          softWrap: softWrap,
          textAlign: textAlign);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, animated, _) {
        final shown =
            isBangla ? _toBangla(animated.round()) : animated.round().toString();
        return Text('$prefix$shown$suffix',
            style: style,
            maxLines: maxLines,
            softWrap: softWrap,
            textAlign: textAlign,
            overflow: maxLines != null ? TextOverflow.ellipsis : null);
      },
    );
  }
}

/// Counts a number up from zero to [value] on first build (and re-animates when
/// [value] changes). [formatter] turns the live number into the display string,
/// so callers can localise (e.g. Bangla digits, currency).
class AnimatedCountText extends StatelessWidget {
  const AnimatedCountText({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
    this.maxLines,
    this.softWrap,
  });

  final num value;
  final String Function(num) formatter;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final int? maxLines;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, animated, _) => Text(
        formatter(animated),
        style: style,
        maxLines: maxLines,
        softWrap: softWrap,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      ),
    );
  }
}
