import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'dart:math';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  final _random = Random();
  final _animations = <MovieTween>[];

  @override
  void initState() {
    super.initState();
    _generateAnimations();
  }

  void _generateAnimations() {
    for (int i = 0; i < 15; i++) {
      final duration = Duration(seconds: 10 + _random.nextInt(10));
      final tween = MovieTween()
        ..tween('x', Tween(begin: _random.nextDouble() * 400, end: _random.nextDouble() * 400), duration: duration)
        ..tween('y', Tween(begin: _random.nextDouble() * 800, end: _random.nextDouble() * 800), duration: duration)
        ..tween('opacity', Tween(begin: 0.2, end: 0.7), duration: duration);
      _animations.add(tween);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(_animations.length, (i) {
        final tween = _animations[i];
        return LoopAnimationBuilder<Movie>(
          tween: tween,
          duration: tween.duration,
          builder: (context, value, child) {
            return Positioned(
              top: value.get('y'),
              left: value.get('x'),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(value.get('opacity')),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
