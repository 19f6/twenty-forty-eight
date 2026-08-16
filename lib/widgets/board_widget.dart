import 'package:flutter/material.dart';

import '../models/game_board.dart';
import '../models/tile.dart';
import '../theme/app_theme.dart';
import 'tile_widget.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key, required this.board, required this.boardSize});

  final GameBoard board;

  final double boardSize;

  static const double _gap = 10;
  static const Color _backgroundColor = AppTheme.surface;
  static const Color _cellColor = AppTheme.emptyCell;

  double get _cellSize =>
      (boardSize - _gap * (board.size + 1)) / board.size;

  Offset _cellOffset(int row, int col) {
    final cell = _cellSize;
    return Offset(
      _gap + col * (cell + _gap),
      _gap + row * (cell + _gap),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cell = _cellSize;
    return Container(
      width: boardSize,
      height: boardSize,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 24, spreadRadius: 2),
        ],
      ),
      child: Stack(
        children: [
          for (var r = 0; r < board.size; r++)
            for (var c = 0; c < board.size; c++)
              Positioned(
                left: _cellOffset(r, c).dx,
                top: _cellOffset(r, c).dy,
                width: cell,
                height: cell,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _cellColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
          for (final Tile tile in board.tiles)
            AnimatedPositioned(
              key: ValueKey(tile.id),
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeInOut,
              left: _cellOffset(tile.row, tile.col).dx,
              top: _cellOffset(tile.row, tile.col).dy,
              width: cell,
              height: cell,
              child: TileWidget(
                value: tile.value,
                justMerged: tile.justMerged,
                isNew: tile.isNew,
              ),
            ),
        ],
      ),
    );
  }
}
