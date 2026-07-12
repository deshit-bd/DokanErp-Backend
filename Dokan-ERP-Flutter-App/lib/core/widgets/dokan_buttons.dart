import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DokanButton extends StatelessWidget {
  const DokanButton({
    required this.onPressed,
    this.text,
    this.child,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.width,
    this.height = 54.0,
    this.isLoading = false,
    super.key,
  }) : assert(text != null || child != null,
            'Either text or child must be provided');

  final VoidCallback? onPressed;
  final String? text;
  final Widget? child;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double height;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBgColor = backgroundColor ?? AppColors.primary;
    final effectiveFgColor = foregroundColor ?? Colors.white;
    final effectiveRadius = borderRadius ?? 18.0;

    final Widget buttonChild;
    if (isLoading) {
      buttonChild = SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(effectiveFgColor),
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          child ??
              Text(
                text!,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
        ],
      );
    } else {
      buttonChild = child ??
          Text(
            text!,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          );
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: effectiveBgColor,
      foregroundColor: effectiveFgColor,
      disabledBackgroundColor: effectiveBgColor.withOpacity(0.5),
      disabledForegroundColor: effectiveFgColor.withOpacity(0.6),
      elevation: 0,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(effectiveRadius),
      ),
    );

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: buttonChild,
      ),
    );
  }
}

class DokanTextButton extends StatelessWidget {
  const DokanTextButton({
    required this.onPressed,
    this.text,
    this.child,
    this.foregroundColor,
    this.fontSize,
    this.fontWeight = FontWeight.w700,
    this.padding,
    this.isLoading = false,
    super.key,
  }) : assert(text != null || child != null,
            'Either text or child must be provided');

  final VoidCallback? onPressed;
  final String? text;
  final Widget? child;
  final Color? foregroundColor;
  final double? fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveFgColor = foregroundColor ?? AppColors.primary;

    final Widget buttonChild;
    if (isLoading) {
      buttonChild = SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(effectiveFgColor),
        ),
      );
    } else {
      buttonChild = child ??
          Text(
            text!,
            style: TextStyle(
              fontSize: fontSize ?? 14,
              fontWeight: fontWeight,
              color: effectiveFgColor,
            ),
          );
    }

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: effectiveFgColor,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: buttonChild,
    );
  }
}

class DokanIconButton extends StatelessWidget {
  const DokanIconButton({
    required this.icon,
    required this.onPressed,
    this.iconSize = 24.0,
    this.color,
    this.backgroundColor,
    this.borderRadius,
    this.padding = const EdgeInsets.all(8),
    this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double iconSize;
  final Color? color;
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry padding;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textPrimary;
    final effectiveRadius = borderRadius ?? 12.0;

    Widget button = Icon(
      icon,
      size: iconSize,
      color: effectiveColor,
    );

    if (backgroundColor != null) {
      button = Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(effectiveRadius),
        ),
        child: button,
      );
    }

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(effectiveRadius),
      child:
          tooltip != null ? Tooltip(message: tooltip!, child: button) : button,
    );
  }
}
