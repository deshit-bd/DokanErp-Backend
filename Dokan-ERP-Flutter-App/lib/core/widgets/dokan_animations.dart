import 'package:flutter/material.dart';

/// Helper to find the nearest scrollable ancestor that is actually scrollable
/// (i.e. does not have NeverScrollableScrollPhysics).
ScrollableState? findActiveScrollable(BuildContext context) {
  ScrollableState? result;
  context.visitAncestorElements((element) {
    if (element is StatefulElement && element.widget is Scrollable) {
      final state = element.state;
      if (state is ScrollableState) {
        final physics = (element.widget as Scrollable).physics;
        if (physics is! NeverScrollableScrollPhysics) {
          result = state;
          return false; // Stop traversing
        }
      }
    }
    return true; // Continue traversing
  });
  return result ?? Scrollable.maybeOf(context);
}

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
    this.slideOffset,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// How far (px) the child slides up while fading in.
  final double offset;

  /// Direction and distance of slide.
  final Offset? slideOffset;

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
    final offsetToUse = widget.slideOffset ?? Offset(0, widget.offset);
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(
            (1 - _curve.value) * offsetToUse.dx,
            (1 - _curve.value) * offsetToUse.dy,
          ),
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
class AnimatedNumberString extends StatefulWidget {
  const AnimatedNumberString(
    this.text, {
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 1000),
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

  @override
  State<AnimatedNumberString> createState() => _AnimatedNumberStringState();
}

class _AnimatedNumberStringState extends State<AnimatedNumberString> {
  bool _isVisible = false;
  ScrollableState? _scrollable;

  static const _banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

  bool _wasCurrent = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final route = ModalRoute.of(context);
    if (route != null) {
      final isCurrent = route.isCurrent;
      if (isCurrent && !_wasCurrent) {
        // Reset visibility state when coming back to this screen
        _isVisible = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _checkVisibility();
        });
      }
      _wasCurrent = isCurrent;
    }

    _scrollable?.position.removeListener(_checkVisibility);
    _scrollable = findActiveScrollable(context);
    _scrollable?.position.addListener(_checkVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkVisibility();
    });
  }

  @override
  void dispose() {
    _scrollable?.position.removeListener(_checkVisibility);
    super.dispose();
  }

  void _checkVisibility() {
    if (!mounted || _isVisible) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final viewportHeight = MediaQuery.of(context).size.height;

    // Trigger animation Y when widget top is 95% down screen height
    if (position.dy < viewportHeight * 0.95 && position.dy > -renderBox.size.height) {
      setState(() {
        _isVisible = true;
      });
      _scrollable?.position.removeListener(_checkVisibility);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _checkVisibility();
      });
    }

    final firstDigitIndex = widget.text.indexOf(RegExp(r'[0-9০-৯]'));
    final lastDigitIndex = widget.text.lastIndexOf(RegExp(r'[0-9০-৯]'));

    if (firstDigitIndex == -1) {
      return Text(widget.text,
          style: widget.style,
          maxLines: widget.maxLines,
          softWrap: widget.softWrap,
          textAlign: widget.textAlign);
    }

    final prefix = widget.text.substring(0, firstDigitIndex);
    final suffix = widget.text.substring(lastDigitIndex + 1);

    final allDigits = widget.text
        .split('')
        .where((c) => RegExp(r'[0-9০-৯]').hasMatch(c))
        .join();

    final englishDigits = allDigits.split('').map((c) {
      final idx = _banglaDigits.indexOf(c);
      return idx >= 0 ? '$idx' : c;
    }).join();

    final target = int.tryParse(englishDigits) ?? 0;
    final isBangla = _banglaDigits.any(allDigits.contains);
    final hasCommas = widget.text.contains(',');

    if (target > 100000000) {
      return Text(widget.text,
          style: widget.style,
          maxLines: widget.maxLines,
          softWrap: widget.softWrap,
          textAlign: widget.textAlign);
    }

    final targetToUse = _isVisible ? target.toDouble() : 0.0;

    return TweenAnimationBuilder<double>(
      key: ValueKey(_isVisible),
      tween: Tween(begin: 0.0, end: targetToUse),
      duration: widget.duration,
      curve: widget.curve,
      builder: (context, animated, _) {
        final val = animated.round();
        var formatted = val.toString();
        if (hasCommas) {
          formatted = formatted.replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (match) => '${match[1]},',
          );
        }
        if (isBangla) {
          formatted = formatted.split('').map((c) {
            final d = int.tryParse(c);
            return d == null ? c : _banglaDigits[d];
          }).join();
        }
        return Text('$prefix$formatted$suffix',
            style: widget.style,
            maxLines: widget.maxLines,
            softWrap: widget.softWrap,
            textAlign: widget.textAlign,
            overflow: widget.maxLines != null ? TextOverflow.ellipsis : null);
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

/// A scroll reveal widget that listens to scroll view offset changes and
/// animates its child slowly when it enters the viewport.
class ScrollReveal extends StatefulWidget {
  const ScrollReveal({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 750),
    this.slideOffset = const Offset(0, 35),
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;
  final Offset slideOffset;
  final Duration delay;

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  bool _isVisible = false;
  ScrollableState? _scrollable;
  bool _wasCurrent = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final route = ModalRoute.of(context);
    if (route != null) {
      final isCurrent = route.isCurrent;
      if (isCurrent && !_wasCurrent) {
        // Reset visibility and reset animation when returning to this page
        setState(() {
          _isVisible = false;
        });
        _controller.reset();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _checkVisibility();
        });
      }
      _wasCurrent = isCurrent;
    }

    _scrollable?.position.removeListener(_checkVisibility);
    _scrollable = findActiveScrollable(context);
    _scrollable?.position.addListener(_checkVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkVisibility();
    });
  }

  @override
  void dispose() {
    _scrollable?.position.removeListener(_checkVisibility);
    _controller.dispose();
    super.dispose();
  }

  void _checkVisibility() {
    if (!mounted || _isVisible) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final viewportHeight = MediaQuery.of(context).size.height;

    // Trigger animation when Y Y-axis position is in view Y axis
    if (position.dy < viewportHeight * 0.92 && position.dy > -renderBox.size.height) {
      setState(() {
        _isVisible = true;
      });
      _scrollable?.position.removeListener(_checkVisibility);
      if (widget.delay == Duration.zero) {
        _controller.forward();
      } else {
        Future.delayed(widget.delay, () {
          if (mounted) _controller.forward();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _checkVisibility();
      });
    }
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        final double opacity = _isVisible ? _curve.value : 0.0;
        final double slideFactor = 1.0 - _curve.value;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(
              slideFactor * widget.slideOffset.dx,
              slideFactor * widget.slideOffset.dy,
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
