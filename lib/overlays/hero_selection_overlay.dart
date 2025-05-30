import 'dart:math';
import 'package:flutter/material.dart';
import '../game/circle_rouge_game.dart';
import '../config/hero_config.dart';

class HeroSelectionOverlay extends StatefulWidget {
  final CircleRougeGame game;

  const HeroSelectionOverlay({super.key, required this.game});

  @override
  State<HeroSelectionOverlay> createState() => _HeroSelectionOverlayState();
}

class _HeroSelectionOverlayState extends State<HeroSelectionOverlay>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  String? hoveredHeroId;
  Map<String, bool> flippedCards = {}; // Track which cards are flipped
  Map<String, AnimationController> flipControllers = {}; // Animation controllers for each card

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Initialize flip controllers for each hero
    for (final hero in HeroConfig.instance.heroes) {
      flippedCards[hero.id] = false;
      flipControllers[hero.id] = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    }

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    for (final controller in flipControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleCardFlip(String heroId) {
    setState(() {
      flippedCards[heroId] = !flippedCards[heroId]!;
      if (flippedCards[heroId]!) {
        flipControllers[heroId]!.forward();
      } else {
        flipControllers[heroId]!.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F0F1F),
            ],
          ),
        ),
        child: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: min(MediaQuery.of(context).size.width * 0.95, 700),
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  padding: const EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2D2D4A),
                        Color(0xFF1E1E3A),
                        Color(0xFF151528),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF4A9EFF).withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A9EFF).withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with enhanced styling
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4A9EFF).withOpacity(0.15),
                              const Color(0xFF9C27B0).withOpacity(0.15),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_pin,
                              color: const Color(0xFF4A9EFF),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [
                                    Color(0xFF4A9EFF),
                                    Color(0xFF9C27B0),
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  'CHOOSE YOUR HERO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // const SizedBox(height: 25),
                      
                      // Hero selection - horizontal scrolling
                      Container(
                        height: 300,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: HeroConfig.instance.heroes.map((hero) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: MouseRegion(
                                  onEnter: (_) => setState(() => hoveredHeroId = hero.id),
                                  onExit: (_) => setState(() => hoveredHeroId = null),
                                  child: GestureDetector(
                                    onTap: () => _toggleCardFlip(hero.id),
                                    child: _buildHeroCard(hero, hoveredHeroId == hero.id),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      
                      // const SizedBox(height: 20),
                      
                      // Back button
                      Container(
                        width: 160,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF424242),
                              Color(0xFF303030),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            widget.game.overlays.remove('HeroSelection');
                            widget.game.overlays.add('StartMenu');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white.withOpacity(0.8),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'BACK',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(HeroData hero, bool isHovered) {
    final flipAnimation = flipControllers[hero.id]!;
    final isFlipped = flippedCards[hero.id]!;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
      width: 180,
      height: 240,
      child: AnimatedBuilder(
        animation: flipAnimation,
        builder: (context, child) {
          final isShowingFront = flipAnimation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(flipAnimation.value * pi),
            child: isShowingFront 
                ? _buildCardFront(hero, isHovered)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildCardBack(hero, isHovered),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardFront(HeroData hero, bool isHovered) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isHovered
              ? [
                  hero.color.withOpacity(0.3),
                  hero.color.withOpacity(0.15),
                  const Color(0xFF2A2A2A),
                ]
              : [
                  const Color(0xFF3A3A3A),
                  const Color(0xFF2A2A2A),
                  const Color(0xFF1A1A1A),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHovered 
              ? hero.color.withOpacity(0.6) 
              : Colors.white.withOpacity(0.2),
          width: isHovered ? 2 : 1,
        ),
        boxShadow: [
          if (isHovered) ...[
            BoxShadow(
              color: hero.color.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hero shape
            Container(
              width: 60,
              height: 60,
              child: CustomPaint(
                painter: _getHeroShapePainter(hero.shape, hero.color, true),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    child: CustomPaint(
                      painter: _getHeroShapePainter(hero.shape, hero.color, false),
                    ),
                  ),
                ),
              ),
            ),
            
            // Hero name
            Text(
              hero.name.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: hero.color.withOpacity(0.5),
                    blurRadius: 5,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            
            // Stats (HP and Speed only)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.favorite, '${hero.health}', 'HP'),
                  Container(
                    width: 1,
                    height: 25,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  _buildStatItem(Icons.speed, '${hero.moveSpeed}', 'SPD'),
                ],
              ),
            ),
            
            // Tap to flip hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                'TAP FOR ABILITY',
                style: TextStyle(
                  color: hero.color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Select button
            Container(
              width: double.infinity,
              height: 35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    hero.color,
                    hero.color.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: hero.color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  widget.game.overlays.remove('HeroSelection');
                  widget.game.startGameWithHero(hero.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'SELECT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(HeroData hero, bool isHovered) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF9800).withOpacity(0.2),
            const Color(0xFFFF5722).withOpacity(0.2),
            const Color(0xFF2A2A2A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF9800).withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Ability icon and name
            Column(
              children: [
                Icon(
                  Icons.flash_on,
                  color: const Color(0xFFFF9800),
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  hero.ability.name.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFFF9800),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            
            // Ability description
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    hero.ability.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            
            // Back to front hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              // decoration: BoxDecoration(
              //   color: const Color(0xFFFF9800).withOpacity(0.2),
              //   borderRadius: BorderRadius.circular(12),
              //   border: Border.all(
              //     color: const Color(0xFFFF9800).withOpacity(0.3),
              //     width: 1,
              //   ),
              // ),
              child: const Text(
                'TAP TO FLIP BACK',
                style: TextStyle(
                  color: Color(0xFFFF9800),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Select button (same as front)
            Container(
              width: double.infinity,
              height: 35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    hero.color,
                    hero.color.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: hero.color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  widget.game.overlays.remove('HeroSelection');
                  widget.game.startGameWithHero(hero.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'SELECT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 16,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  CustomPainter? _getHeroShapePainter(String shape, Color color, bool withGlow) {
    switch (shape) {
      case 'circle':
        return _CirclePainter(color, withGlow);
      case 'triangle':
        return _TrianglePainter(color, withGlow);
      case 'square':
        return _SquarePainter(color, withGlow);
      case 'pentagon':
        return _PentagonPainter(color, withGlow);
      case 'hexagon':
        return _HexagonPainter(color, withGlow);
      default:
        return _CirclePainter(color, withGlow);
    }
  }
}

class _CirclePainter extends CustomPainter {
  final Color color;
  final bool withGlow;
  _CirclePainter(this.color, this.withGlow);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    if (withGlow) {
      // Draw glow effect
      final glowPaint = Paint()
        ..color = color.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(center, radius, glowPaint);
    } else {
      // Draw solid shape
      final paint = Paint()..color = color;
      canvas.drawCircle(center, radius * 0.8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SquarePainter extends CustomPainter {
  final Color color;
  final bool withGlow;
  _SquarePainter(this.color, this.withGlow);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final sideLength = size.width * (withGlow ? 1.0 : 0.8);
    
    if (withGlow) {
      // Draw glow effect
      final glowPaint = Paint()
        ..color = color.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawRect(
        Rect.fromCenter(center: center, width: sideLength, height: sideLength),
        glowPaint,
      );
    } else {
      // Draw solid shape
      final paint = Paint()..color = color;
      canvas.drawRect(
        Rect.fromCenter(center: center, width: sideLength, height: sideLength),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final bool withGlow;
  _TrianglePainter(this.color, this.withGlow);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * (withGlow ? 1.0 : 0.8);
    
    final paint = Paint();
    if (withGlow) {
      paint.color = color.withOpacity(0.6);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    } else {
      paint.color = color;
    }
    
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx - radius * cos(pi / 6), center.dy + radius / 2);
    path.lineTo(center.dx + radius * cos(pi / 6), center.dy + radius / 2);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PentagonPainter extends CustomPainter {
  final Color color;
  final bool withGlow;
  _PentagonPainter(this.color, this.withGlow);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * (withGlow ? 1.0 : 0.8);
    
    final paint = Paint();
    if (withGlow) {
      paint.color = color.withOpacity(0.6);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    } else {
      paint.color = color;
    }
    
    final path = Path();
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
  final bool withGlow;
  _HexagonPainter(this.color, this.withGlow);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * (withGlow ? 1.0 : 0.8);
    
    final paint = Paint();
    if (withGlow) {
      paint.color = color.withOpacity(0.6);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    } else {
      paint.color = color;
    }
    
    final path = Path();
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