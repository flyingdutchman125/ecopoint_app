import 'package:flutter/material.dart';

class EcoTreeVectorWidget extends StatelessWidget {
  final int level;
  final double width;
  final double height;

  const EcoTreeVectorWidget({
    Key? key,
    required this.level,
    this.width = 200,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final clampedLevel = level.clamp(1, 9);

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _EcoTreeVectorPainter(level: clampedLevel),
      ),
    );
  }
}

class _EcoTreeVectorPainter extends CustomPainter {
  final int level;

  _EcoTreeVectorPainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final w = size.width;
    final h = size.height;

    // 1. Draw Background Soft Glow Circle
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE8F5E9),
          const Color(0xFFF3F4F6).withOpacity(0.1),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.48));
    canvas.drawCircle(center, w * 0.46, bgPaint);

    // 2. Draw Soil / Ground Base
    final soilY = h * 0.78;
    final soilPath = Path()
      ..moveTo(w * 0.15, soilY)
      ..quadraticBezierTo(w * 0.5, soilY - 14, w * 0.85, soilY)
      ..quadraticBezierTo(w * 0.5, soilY + 22, w * 0.15, soilY)
      ..close();

    final soilPaint = Paint()..color = const Color(0xFF8D6E63);
    canvas.drawPath(soilPath, soilPaint);

    final grassPaint = Paint()..color = const Color(0xFF66BB6A);
    final grassPath = Path()
      ..moveTo(w * 0.18, soilY)
      ..quadraticBezierTo(w * 0.5, soilY - 18, w * 0.82, soilY)
      ..quadraticBezierTo(w * 0.5, soilY - 4, w * 0.18, soilY)
      ..close();
    canvas.drawPath(grassPath, grassPaint);

    // 3. Level Specific Vector Tree Drawings (1 to 9)
    switch (level) {
      case 1:
        _drawLevel1Seed(canvas, w, h, soilY);
        break;
      case 2:
        _drawLevel2Sprout(canvas, w, h, soilY);
        break;
      case 3:
        _drawLevel3Seedling(canvas, w, h, soilY);
        break;
      case 4:
        _drawLevel4SmallPlant(canvas, w, h, soilY);
        break;
      case 5:
        _drawLevel5YoungTree(canvas, w, h, soilY);
        break;
      case 6:
        _drawLevel6MediumTree(canvas, w, h, soilY);
        break;
      case 7:
        _drawLevel7LushTree(canvas, w, h, soilY);
        break;
      case 8:
        _drawLevel8FloweringTree(canvas, w, h, soilY);
        break;
      case 9:
        _drawLevel9AncientGrandTree(canvas, w, h, soilY);
        break;
    }
  }

  // --- Level 1: Bibit Kecil ---
  void _drawLevel1Seed(Canvas canvas, double w, double h, double soilY) {
    // Seed
    final seedCenter = Offset(w * 0.5, soilY - 4);
    final seedPaint = Paint()..color = const Color(0xFF4E342E);
    canvas.drawOval(Rect.fromCenter(center: seedCenter, width: 18, height: 12), seedPaint);

    // Tiny Sprout Shoot
    final shootPath = Path()
      ..moveTo(w * 0.5, soilY - 8)
      ..quadraticBezierTo(w * 0.48, soilY - 22, w * 0.44, soilY - 28)
      ..quadraticBezierTo(w * 0.52, soilY - 20, w * 0.5, soilY - 8);
    final shootPaint = Paint()..color = const Color(0xFF81C784);
    canvas.drawPath(shootPath, shootPaint);

    // Mini leaf bud
    final budPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawCircle(Offset(w * 0.44, soilY - 28), 5, budPaint);
  }

  // --- Level 2: Kecambah ---
  void _drawLevel2Sprout(Canvas canvas, double w, double h, double soilY) {
    final stemPath = Path()
      ..moveTo(w * 0.5, soilY - 6)
      ..quadraticBezierTo(w * 0.49, soilY - 35, w * 0.5, soilY - 50);
    final stemPaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(stemPath, stemPaint);

    // 2 Leaves
    final leafPaint = Paint()..color = const Color(0xFF4CAF50);

    // Left Leaf
    final leftLeaf = Path()
      ..moveTo(w * 0.5, soilY - 50)
      ..quadraticBezierTo(w * 0.38, soilY - 62, w * 0.36, soilY - 52)
      ..quadraticBezierTo(w * 0.42, soilY - 44, w * 0.5, soilY - 50);
    canvas.drawPath(leftLeaf, leafPaint);

    // Right Leaf
    final rightLeaf = Path()
      ..moveTo(w * 0.5, soilY - 50)
      ..quadraticBezierTo(w * 0.62, soilY - 62, w * 0.64, soilY - 52)
      ..quadraticBezierTo(w * 0.58, soilY - 44, w * 0.5, soilY - 50);
    canvas.drawPath(rightLeaf, leafPaint);
  }

  // --- Level 3: Tunas Muda ---
  void _drawLevel3Seedling(Canvas canvas, double w, double h, double soilY) {
    // Stem
    final stemPath = Path()
      ..moveTo(w * 0.5, soilY - 6)
      ..quadraticBezierTo(w * 0.48, soilY - 40, w * 0.5, soilY - 75);
    final stemPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(stemPath, stemPaint);

    // 4 Leaves
    final leafPaint = Paint()..color = const Color(0xFF388E3C);
    final lightLeaf = Paint()..color = const Color(0xFF81C784);

    // Lower pair
    _drawLeaf(canvas, Offset(w * 0.5, soilY - 40), -0.6, 22, leafPaint);
    _drawLeaf(canvas, Offset(w * 0.5, soilY - 40), 0.6, 22, lightLeaf);

    // Upper pair
    _drawLeaf(canvas, Offset(w * 0.5, soilY - 75), -0.8, 25, leafPaint);
    _drawLeaf(canvas, Offset(w * 0.5, soilY - 75), 0.8, 25, lightLeaf);
  }

  // --- Level 4: Tanaman Kecil ---
  void _drawLevel4SmallPlant(Canvas canvas, double w, double h, double soilY) {
    // Mini Trunk
    final trunkPath = Path()
      ..moveTo(w * 0.47, soilY - 6)
      ..lineTo(w * 0.48, soilY - 95)
      ..lineTo(w * 0.52, soilY - 95)
      ..lineTo(w * 0.53, soilY - 6)
      ..close();
    canvas.drawPath(trunkPath, Paint()..color = const Color(0xFF6D4C41));

    final darkGreen = Paint()..color = const Color(0xFF2E7D32);
    final mainGreen = Paint()..color = const Color(0xFF4CAF50);

    // Multiple Branches & Leaf clusters
    _drawLeaf(canvas, Offset(w * 0.48, soilY - 45), -0.9, 28, darkGreen);
    _drawLeaf(canvas, Offset(w * 0.52, soilY - 45), 0.9, 28, mainGreen);

    _drawLeaf(canvas, Offset(w * 0.48, soilY - 70), -0.8, 30, darkGreen);
    _drawLeaf(canvas, Offset(w * 0.52, soilY - 70), 0.8, 30, mainGreen);

    _drawLeaf(canvas, Offset(w * 0.5, soilY - 95), -0.3, 32, darkGreen);
    _drawLeaf(canvas, Offset(w * 0.5, soilY - 95), 0.3, 32, mainGreen);
  }

  // --- Level 5: Pohon Muda ---
  void _drawLevel5YoungTree(Canvas canvas, double w, double h, double soilY) {
    // Wooden Trunk
    final trunkPath = Path()
      ..moveTo(w * 0.44, soilY - 6)
      ..quadraticBezierTo(w * 0.48, soilY - 60, w * 0.47, soilY - 115)
      ..lineTo(w * 0.53, soilY - 115)
      ..quadraticBezierTo(w * 0.52, soilY - 60, w * 0.56, soilY - 6)
      ..close();
    canvas.drawPath(trunkPath, Paint()..color = const Color(0xFF5D4037));

    // Canopy Circles
    final dark = Paint()..color = const Color(0xFF1B5E20);
    final mid = Paint()..color = const Color(0xFF2E7D32);
    final bright = Paint()..color = const Color(0xFF4CAF50);

    canvas.drawCircle(Offset(w * 0.38, soilY - 105), 28, dark);
    canvas.drawCircle(Offset(w * 0.62, soilY - 105), 28, dark);
    canvas.drawCircle(Offset(w * 0.5, soilY - 130), 34, mid);
    canvas.drawCircle(Offset(w * 0.44, soilY - 125), 24, bright);
  }

  // --- Level 6: Pohon Sedang ---
  void _drawLevel6MediumTree(Canvas canvas, double w, double h, double soilY) {
    // Stronger Trunk
    final trunkPath = Path()
      ..moveTo(w * 0.42, soilY - 6)
      ..quadraticBezierTo(w * 0.47, soilY - 70, w * 0.45, soilY - 125)
      ..lineTo(w * 0.55, soilY - 125)
      ..quadraticBezierTo(w * 0.53, soilY - 70, w * 0.58, soilY - 6)
      ..close();
    canvas.drawPath(trunkPath, Paint()..color = const Color(0xFF4E342E));

    final dark = Paint()..color = const Color(0xFF1B5E20);
    final mid = Paint()..color = const Color(0xFF2E7D32);
    final bright = Paint()..color = const Color(0xFF66BB6A);

    canvas.drawCircle(Offset(w * 0.34, soilY - 115), 35, dark);
    canvas.drawCircle(Offset(w * 0.66, soilY - 115), 35, dark);
    canvas.drawCircle(Offset(w * 0.5, soilY - 145), 45, mid);
    canvas.drawCircle(Offset(w * 0.4, soilY - 138), 30, bright);
    canvas.drawCircle(Offset(w * 0.6, soilY - 138), 28, bright);
  }

  // --- Level 7: Pohon Rimbun ---
  void _drawLevel7LushTree(Canvas canvas, double w, double h, double soilY) {
    // Broad Trunk with roots
    final trunkPath = Path()
      ..moveTo(w * 0.38, soilY - 6)
      ..quadraticBezierTo(w * 0.46, soilY - 80, w * 0.44, soilY - 135)
      ..lineTo(w * 0.56, soilY - 135)
      ..quadraticBezierTo(w * 0.54, soilY - 80, w * 0.62, soilY - 6)
      ..close();
    canvas.drawPath(trunkPath, Paint()..color = const Color(0xFF3E2723));

    final c1 = Paint()..color = const Color(0xFF1B5E20);
    final c2 = Paint()..color = const Color(0xFF2F7A2F);
    final c3 = Paint()..color = const Color(0xFF4CAF50);
    final c4 = Paint()..color = const Color(0xFF81C784);

    canvas.drawCircle(Offset(w * 0.3, soilY - 125), 42, c1);
    canvas.drawCircle(Offset(w * 0.7, soilY - 125), 42, c1);
    canvas.drawCircle(Offset(w * 0.5, soilY - 165), 52, c2);
    canvas.drawCircle(Offset(w * 0.38, soilY - 150), 38, c3);
    canvas.drawCircle(Offset(w * 0.62, soilY - 150), 38, c3);
    canvas.drawCircle(Offset(w * 0.48, soilY - 178), 28, c4);
  }

  // --- Level 8: Pohon Berbunga ---
  void _drawLevel8FloweringTree(Canvas canvas, double w, double h, double soilY) {
    _drawLevel7LushTree(canvas, w, h, soilY);

    // Flowers / Blossoms
    final flowerPaint = Paint()..color = const Color(0xFFFF80AB);
    final centerPaint = Paint()..color = const Color(0xFFFFEB3B);

    final flowerPositions = [
      Offset(w * 0.32, soilY - 140),
      Offset(w * 0.68, soilY - 140),
      Offset(w * 0.45, soilY - 170),
      Offset(w * 0.58, soilY - 175),
      Offset(w * 0.38, soilY - 110),
      Offset(w * 0.62, soilY - 115),
      Offset(w * 0.5, soilY - 135),
    ];

    for (final pos in flowerPositions) {
      canvas.drawCircle(pos, 7, flowerPaint);
      canvas.drawCircle(pos, 3, centerPaint);
    }
  }

  // --- Level 9: Pohon Abadi (Grand Ancient Eco Tree) ---
  void _drawLevel9AncientGrandTree(Canvas canvas, double w, double h, double soilY) {
    // Golden Halo / Eco Aura
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFD54F).withOpacity(0.4),
          const Color(0xFF4CAF50).withOpacity(0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.5, soilY - 150), radius: 95));
    canvas.drawCircle(Offset(w * 0.5, soilY - 150), 95, auraPaint);

    // Majestic Trunk
    final trunkPath = Path()
      ..moveTo(w * 0.34, soilY - 6)
      ..quadraticBezierTo(w * 0.45, soilY - 90, w * 0.42, soilY - 145)
      ..lineTo(w * 0.58, soilY - 145)
      ..quadraticBezierTo(w * 0.55, soilY - 90, w * 0.66, soilY - 6)
      ..close();
    canvas.drawPath(trunkPath, Paint()..color = const Color(0xFF271C19));

    // Giant Golden Canopy
    final c1 = Paint()..color = const Color(0xFF1B5E20);
    final c2 = Paint()..color = const Color(0xFF2E7D32);
    final c3 = Paint()..color = const Color(0xFF4CAF50);
    final cGold = Paint()..color = const Color(0xFFFFD54F);

    canvas.drawCircle(Offset(w * 0.25, soilY - 135), 48, c1);
    canvas.drawCircle(Offset(w * 0.75, soilY - 135), 48, c1);
    canvas.drawCircle(Offset(w * 0.5, soilY - 180), 58, c2);
    canvas.drawCircle(Offset(w * 0.35, soilY - 165), 45, c3);
    canvas.drawCircle(Offset(w * 0.65, soilY - 165), 45, c3);
    canvas.drawCircle(Offset(w * 0.5, soilY - 195), 32, cGold);

    // Hanging Golden Eco Fruits
    final fruitPositions = [
      Offset(w * 0.3, soilY - 110),
      Offset(w * 0.7, soilY - 110),
      Offset(w * 0.42, soilY - 145),
      Offset(w * 0.58, soilY - 145),
      Offset(w * 0.5, soilY - 120),
      Offset(w * 0.36, soilY - 170),
      Offset(w * 0.64, soilY - 170),
    ];

    final fruitPaint = Paint()..color = const Color(0xFFFFC107);
    final sheenPaint = Paint()..color = Colors.white;

    for (final pos in fruitPositions) {
      canvas.drawCircle(pos, 8, fruitPaint);
      canvas.drawCircle(pos + const Offset(-2, -2), 2.5, sheenPaint);
    }
  }

  void _drawLeaf(Canvas canvas, Offset origin, double angleRad, double length, Paint paint) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angleRad);

    final leafPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-length * 0.4, -length * 0.5, 0, -length)
      ..quadraticBezierTo(length * 0.4, -length * 0.5, 0, 0)
      ..close();
    canvas.drawPath(leafPath, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EcoTreeVectorPainter oldDelegate) {
    return oldDelegate.level != level;
  }
}
