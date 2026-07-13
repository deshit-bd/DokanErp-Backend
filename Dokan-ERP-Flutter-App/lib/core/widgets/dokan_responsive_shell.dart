import 'package:flutter/material.dart';

/// Makes the whole app responsive with a single wrapper.
///
/// On phones the content fills the screen as before. On wider screens
/// (tablet, desktop, wide web) the app is centred in a comfortable column and
/// MediaQuery is overridden to that width, so every screen and component lays
/// itself out for the column instead of stretching edge-to-edge.
class DokanResponsiveShell extends StatelessWidget {
  const DokanResponsiveShell({super.key, required this.child});

  final Widget child;

  /// Comfortable maximum content width for a mobile-first UI.
  static const double maxContentWidth = 1200;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;

    // Phones / narrow windows: use the full width unchanged.
    if (width <= maxContentWidth + 32) {
      return child;
    }

    // Wide screens: centre the app in a column and tell every screen the
    // usable width is [maxContentWidth] so layouts stay mobile-proportioned.
    return ColoredBox(
      color: const Color(0xFFE9EEF3),
      child: Center(
        child: SizedBox(
          width: maxContentWidth,
          height: media.size.height,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 24,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipRect(
              child: MediaQuery(
                data: media.copyWith(
                  size: Size(maxContentWidth, media.size.height),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
