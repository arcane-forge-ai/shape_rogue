import 'dart:math';
import 'package:flutter/material.dart';
import '../game/circle_rouge_game.dart';
import '../config/hero_config.dart';

class HeroSelectionOverlay extends StatelessWidget {
  final CircleRougeGame game;

  const HeroSelectionOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xEE000000), // Semi-transparent black
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'CHOOSE YOUR HERO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        children: HeroConfig.instance.heroes.map((hero) {
                          return _buildHeroCard(hero);
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(HeroData hero) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF424242),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hero shape representation
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: hero.color,
              shape: hero.shape == 'circle' ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: hero.shape != 'circle' ? BorderRadius.circular(8) : null,
            ),
            child: hero.shape != 'circle' && hero.shape != 'square'
                ? CustomPaint(
                    painter: _getShapePainter(hero.shape, hero.color),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            hero.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${hero.health} HP • ${hero.moveSpeed} Speed',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hero.ability.name,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            hero.ability.description,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                game.overlays.remove('HeroSelection');
                game.startGameWithHero(hero.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('SELECT', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  CustomPainter? _getShapePainter(String shape, Color color) {
    switch (shape) {
      case 'triangle':
        return _TrianglePainter(color);
      case 'pentagon':
        return _PentagonPainter(color);
      case 'hexagon':
        return _HexagonPainter(color);
      default:
        return null;
    }
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PentagonPainter extends CustomPainter {
  final Color color;
  _PentagonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    for (int i = 0; i < 5; i++) {
      final angle = -90 + (i * 72); // Pentagon angles
      final x = center.dx + radius * cos(angle * 3.14159 / 180);
      final y = center.dy + radius * sin(angle * 3.14159 / 180);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HexagonPainter extends CustomPainter {
  final Color color;
  _HexagonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    for (int i = 0; i < 6; i++) {
      final angle = -90 + (i * 60); // Hexagon angles
      final x = center.dx + radius * cos(angle * 3.14159 / 180);
      final y = center.dy + radius * sin(angle * 3.14159 / 180);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 