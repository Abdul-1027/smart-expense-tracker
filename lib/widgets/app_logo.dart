// widgets/app_logo.dart

import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showTagline;
  final Color? backgroundColor;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showText = false,
    this.showTagline = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon mark
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? const Color(0xFF1D9E75),
            borderRadius: BorderRadius.circular(size * 0.22),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Upward arrow (above wallet)
              Positioned(
                top: size * 0.10,
                child: Column(
                  children: [
                    Icon(Icons.arrow_upward_rounded,
                        color: Colors.white, size: size * 0.22),
                  ],
                ),
              ),
              // Wallet body
              Positioned(
                bottom: size * 0.18,
                child: CustomPaint(
                  size: Size(size * 0.60, size * 0.38),
                  painter: _WalletPainter(),
                ),
              ),
            ],
          ),
        ),

        if (showText) ...[
          const SizedBox(height: 16),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Spend',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D9E75),
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'Smart',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF444441),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],

        if (showTagline) ...[
          const SizedBox(height: 6),
          const Text(
            'Your personal finance manager',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF888780),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ],
    );
  }
}

class _WalletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = Colors.white.withAlpha(60)
      ..style = PaintingStyle.fill;

    // Wallet body
    final walletRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.2, size.width, size.height * 0.8),
      Radius.circular(size.height * 0.15),
    );
    canvas.drawRRect(walletRect, fillPaint);
    canvas.drawRRect(walletRect, paint);

    // Wallet top flap
    final flapRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.2, size.width, size.height * 0.28),
      Radius.circular(size.height * 0.15),
    );
    canvas.drawRRect(flapRect,
        Paint()..color = Colors.white.withAlpha(80)..style = PaintingStyle.fill);

    // Coin dot
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.65),
      size.height * 0.12,
      Paint()..color = Colors.white..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}