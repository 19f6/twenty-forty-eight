import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TileWidget extends StatelessWidget {
  const TileWidget({
    super.key,
    required this.value,
    required this.justMerged,
    required this.isNew,
  });

  final int value;
  final bool justMerged;
  final bool isNew;

  Color get _background => AppTheme.tileColor(value);

  double get _fontSize {
    if (value < 100) return 32;
    if (value < 1000) return 28;
    return 22;
  }

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: _background.withValues(alpha: 0.55),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: TextStyle(
          color: Colors.white,
          fontSize: _fontSize,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
          ],
        ),
      ),
    );

    if (isNew || justMerged) {
      return TweenAnimationBuilder<double>(
        key: ValueKey('$value-$isNew-$justMerged'),
        tween: Tween(begin: isNew ? 0.0 : 1.0, end: 1.0),
        duration: const Duration(milliseconds: 180),
        curve: isNew ? Curves.easeOut : Curves.elasticOut,
        builder: (context, scale, child) => Transform.scale(
          scale: justMerged ? 0.85 + 0.15 * scale : scale,
          child: child,
        ),
        child: tile,
      );
    }

    return tile;
  }
}
