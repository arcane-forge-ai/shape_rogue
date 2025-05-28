import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class TriangleComponent extends Component {
  final double size;
  final Paint paint;
  final Vector2 position;
  final Anchor anchor;
  
  TriangleComponent({
    required this.size,
    required this.paint,
    required this.position,
    this.anchor = Anchor.center,
  });
  
  @override
  void render(Canvas canvas) {
    final path = Path();
    final halfSize = size / 2;
    
    // Create equilateral triangle
    path.moveTo(0, -halfSize); // Top point
    path.lineTo(-halfSize * cos(pi / 6), halfSize / 2); // Bottom left
    path.lineTo(halfSize * cos(pi / 6), halfSize / 2); // Bottom right
    path.close();
    
    canvas.save();
    canvas.translate(position.x, position.y);
    canvas.drawPath(path, paint);
    canvas.restore();
  }
}

class PentagonComponent extends Component {
  final double size;
  final Paint paint;
  final Vector2 position;
  final Anchor anchor;
  
  PentagonComponent({
    required this.size,
    required this.paint,
    required this.position,
    this.anchor = Anchor.center,
  });
  
  @override
  void render(Canvas canvas) {
    final path = Path();
    final radius = size / 2;
    final angleStep = 2 * pi / 5;
    
    // Start from top point
    for (int i = 0; i < 5; i++) {
      final angle = -pi / 2 + i * angleStep; // Start from top
      final x = radius * cos(angle);
      final y = radius * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.save();
    canvas.translate(position.x, position.y);
    canvas.drawPath(path, paint);
    canvas.restore();
  }
}

class HexagonComponent extends Component {
  final double size;
  final Paint paint;
  final Vector2 position;
  final Anchor anchor;
  
  HexagonComponent({
    required this.size,
    required this.paint,
    required this.position,
    this.anchor = Anchor.center,
  });
  
  @override
  void render(Canvas canvas) {
    final path = Path();
    final radius = size / 2;
    final angleStep = 2 * pi / 6;
    
    // Start from top point
    for (int i = 0; i < 6; i++) {
      final angle = -pi / 2 + i * angleStep; // Start from top
      final x = radius * cos(angle);
      final y = radius * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.save();
    canvas.translate(position.x, position.y);
    canvas.drawPath(path, paint);
    canvas.restore();
  }
} 