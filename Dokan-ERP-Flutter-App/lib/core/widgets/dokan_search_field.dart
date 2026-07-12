import 'package:flutter/material.dart';

class DokanSearchField extends StatelessWidget {
  const DokanSearchField({
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
    this.showClear = false,
    this.autofocus = false,
    this.height = 54,
    this.borderRadius = 16,
    this.fillColor = const Color(0xFFF8FBFA),
    this.borderColor = const Color(0xFFD7E5E0),
    this.focusedBorderColor = const Color(0xFF00694C),
    this.iconColor = const Color(0xFF00694C),
    this.textInputAction = TextInputAction.search,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool showClear;
  final bool autofocus;
  final double height;
  final double borderRadius;
  final Color fillColor;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color iconColor;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        cursorColor: focusedBorderColor,
        textInputAction: textInputAction,
        style: const TextStyle(
          color: Color(0xFF10201C),
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF72807C),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: iconColor, size: 22),
          suffixIcon: showClear
              ? IconButton(
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF72807C),
                    size: 20,
                  ),
                  tooltip: 'Clear search',
                )
              : null,
          filled: true,
          fillColor: fillColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}
