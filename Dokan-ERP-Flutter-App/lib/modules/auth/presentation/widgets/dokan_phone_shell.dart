import 'dart:math' as math;

import 'package:flutter/material.dart';

class DokanPhoneShell extends StatelessWidget {
  const DokanPhoneShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;
          final frameWidth = math.min(390.0, constraints.maxWidth);
          final frameHeight = isWide
              ? math.min(844.0, constraints.maxHeight)
              : constraints.maxHeight;

          final frame = SizedBox(
            width: frameWidth,
            height: frameHeight,
            child: child,
          );

          if (!isWide) {
            return frame;
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.2, -0.35),
                radius: 1.2,
                colors: [
                  Color(0xFF183730),
                  Color(0xFF071712),
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: frameWidth,
                height: frameHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B221C),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 40,
                      offset: Offset(0, 20),
                    ),
                  ],
                ),
                child: frame,
              ),
            ),
          );
        },
      ),
    );
  }
}
