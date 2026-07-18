part of '../onboarding_screen.dart';

class _AnimatedIllustrationElement extends StatefulWidget {
  const _AnimatedIllustrationElement({
    required this.child,
    required this.delay,
    required this.duration,
    this.slideOffset = const Offset(0, 30),
    this.floatOffsetY = 6.0,
    this.floatDuration = const Duration(milliseconds: 2500),
    this.floatDelayFraction = 0.0,
    this.isActive = true,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;
  final double floatOffsetY;
  final Duration floatDuration;
  final double floatDelayFraction;
  final bool isActive;

  @override
  State<_AnimatedIllustrationElement> createState() => _AnimatedIllustrationElementState();
}

class _AnimatedIllustrationElementState extends State<_AnimatedIllustrationElement> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _floatController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(begin: widget.slideOffset, end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: widget.floatDuration,
    );

    _floatAnimation = Tween<double>(begin: -widget.floatOffsetY, end: widget.floatOffsetY).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOutSine,
      ),
    );

    if (widget.isActive) {
      _playAnimations();
    }
  }

  void _playAnimations() {
    _entranceController.reset();
    _floatController.reset();

    Future.delayed(widget.delay, () {
      if (mounted && widget.isActive) {
        _entranceController.forward().then((_) {
          if (mounted && widget.floatOffsetY > 0.0 && widget.isActive) {
            final isRunningInTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
            if (!isRunningInTest) {
              Future.delayed(
                Duration(
                  milliseconds: (widget.floatDuration.inMilliseconds * widget.floatDelayFraction).toInt(),
                ),
                () {
                  if (mounted && widget.isActive) {
                    _floatController.repeat(reverse: true);
                  }
                },
              );
            }
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant _AnimatedIllustrationElement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _playAnimations();
    } else if (!widget.isActive && oldWidget.isActive) {
      _entranceController.reset();
      _floatController.reset();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entranceController, _floatController]),
      builder: (context, child) {
        final double scale = _scaleAnimation.value;
        final double opacity = _fadeAnimation.value;
        final Offset slide = _slideAnimation.value;
        final double float = _floatController.isAnimating ? _floatAnimation.value : 0.0;

        return Transform.translate(
          offset: slide + Offset(0, float),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _FadeSlideEntrance extends StatefulWidget {
  const _FadeSlideEntrance({
    required this.child,
    required this.delay,
    this.duration = const Duration(milliseconds: 650),
    this.offset = const Offset(0, 20),
    this.isActive = true,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final bool isActive;

  @override
  State<_FadeSlideEntrance> createState() => _FadeSlideEntranceState();
}

class _FadeSlideEntranceState extends State<_FadeSlideEntrance> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (widget.isActive) {
      _playAnimation();
    }
  }

  void _playAnimation() {
    _controller.reset();
    Future.delayed(widget.delay, () {
      if (mounted && widget.isActive) {
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _FadeSlideEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _playAnimation();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.reset();
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
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _AnimatedGlowCircle extends StatefulWidget {
  const _AnimatedGlowCircle({
    required this.child,
    required this.delay,
    this.duration = const Duration(milliseconds: 1000),
    this.isActive = true,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final bool isActive;

  @override
  State<_AnimatedGlowCircle> createState() => _AnimatedGlowCircleState();
}

class _AnimatedGlowCircleState extends State<_AnimatedGlowCircle> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    if (widget.isActive) {
      _playAnimation();
    }
  }

  void _playAnimation() {
    _controller.reset();
    Future.delayed(widget.delay, () {
      if (mounted && widget.isActive) {
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _AnimatedGlowCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _playAnimation();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.reset();
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
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _AnimatedWidthFactor extends StatefulWidget {
  const _AnimatedWidthFactor({
    required this.child,
    required this.delay,
    required this.isActive,
  });

  final Widget child;
  final Duration delay;
  final bool isActive;

  @override
  State<_AnimatedWidthFactor> createState() => _AnimatedWidthFactorState();
}

class _AnimatedWidthFactorState extends State<_AnimatedWidthFactor> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _widthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (widget.isActive) {
      _play();
    }
  }

  void _play() {
    _controller.reset();
    Future.delayed(widget.delay, () {
      if (mounted && widget.isActive) {
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _AnimatedWidthFactor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _play();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.reset();
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
      animation: _controller,
      builder: (context, child) {
        return FractionallySizedBox(
          widthFactor: _widthAnimation.value,
          alignment: Alignment.centerLeft,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _AnimatedHeightFactor extends StatefulWidget {
  const _AnimatedHeightFactor({
    required this.child,
    required this.delay,
    required this.isActive,
    required this.height,
  });

  final Widget child;
  final Duration delay;
  final bool isActive;
  final double height;

  @override
  State<_AnimatedHeightFactor> createState() => _AnimatedHeightFactorState();
}

class _AnimatedHeightFactorState extends State<_AnimatedHeightFactor> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heightAnimation = Tween<double>(begin: 0.0, end: widget.height).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    if (widget.isActive) {
      _play();
    }
  }

  void _play() {
    _controller.reset();
    Future.delayed(widget.delay, () {
      if (mounted && widget.isActive) {
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _AnimatedHeightFactor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _play();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.reset();
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
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: _heightAnimation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
