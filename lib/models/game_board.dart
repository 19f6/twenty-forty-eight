import 'dart:math';

import 'package:flutter/foundation.dart';

import 'tile.dart';

enum Direction { up, down, left, right }

class GameBoard extends ChangeNotifier {
  GameBoard({this.size = 4, int best = 0, Random? random})
      : _best = best,
        _random = random ?? Random() {
    startNewGame();
  }

  @visibleForTesting
  factory GameBoard.withTiles(List<List<int?>> grid, {int score = 0}) {
    final board = GameBoard(size: grid.length, random: Random(0));
    board._tiles.clear();
    board._score = score;
    for (var r = 0; r < grid.length; r++) {
      for (var c = 0; c < grid[r].length; c++) {
        final value = grid[r][c];
        if (value != null) {
          board._tiles.add(Tile(value: value, row: r, col: c));
        }
      }
    }
    board._isGameOver = !board._hasAnyLegalMove();
    return board;
  }

  final int size;
  final Random _random;

  final List<Tile> _tiles = [];
  List<Tile> get tiles => List.unmodifiable(_tiles);

  int _score = 0;
  int get score => _score;

  int _best = 0;
  int get best => _best;

  bool _isGameOver = false;
  bool get isGameOver => _isGameOver;

  Tile? _tileAt(int row, int col) {
    for (final t in _tiles) {
      if (t.row == row && t.col == col) return t;
    }
    return null;
  }

  void startNewGame() {
    _tiles.clear();
    _score = 0;
    _isGameOver = false;
    final startingTiles = 3 + _random.nextInt(2);
    for (var i = 0; i < startingTiles; i++) {
      _spawnRandomTile();
    }
    notifyListeners();
  }

  bool move(Direction direction) {
    if (_isGameOver) return false;

    for (final tile in _tiles) {
      tile.justMerged = false;
      tile.isNew = false;
    }

    var moved = false;
    for (final line in _linesFor(direction)) {
      moved = _collapseLine(line) || moved;
    }

    if (moved) {
      _spawnRandomTile();
      _best = max(_best, _score);
      _isGameOver = !_hasAnyLegalMove();
      notifyListeners();
    }
    return moved;
  }

  List<List<Point<int>>> _linesFor(Direction direction) {
    final lines = <List<Point<int>>>[];
    switch (direction) {
      case Direction.left:
        for (var r = 0; r < size; r++) {
          lines.add([for (var c = 0; c < size; c++) Point(r, c)]);
        }
      case Direction.right:
        for (var r = 0; r < size; r++) {
          lines.add([for (var c = size - 1; c >= 0; c--) Point(r, c)]);
        }
      case Direction.up:
        for (var c = 0; c < size; c++) {
          lines.add([for (var r = 0; r < size; r++) Point(r, c)]);
        }
      case Direction.down:
        for (var c = 0; c < size; c++) {
          lines.add([for (var r = size - 1; r >= 0; r--) Point(r, c)]);
        }
    }
    return lines;
  }

  bool _collapseLine(List<Point<int>> coords) {
    final lineTiles = [
      for (final p in coords)
        if (_tileAt(p.x, p.y) != null) _tileAt(p.x, p.y)!,
    ];
    if (lineTiles.isEmpty) return false;

    final result = <Tile>[];
    var changed = false;
    var i = 0;
    while (i < lineTiles.length) {
      final current = lineTiles[i];
      final next = i + 1 < lineTiles.length ? lineTiles[i + 1] : null;
      if (next != null && next.value == current.value) {
        current.value *= 2;
        current.justMerged = true;
        _score += current.value;
        _tiles.remove(next);
        result.add(current);
        i += 2;
        changed = true;
      } else {
        result.add(current);
        i += 1;
      }
    }

    for (var idx = 0; idx < result.length; idx++) {
      final target = coords[idx];
      final tile = result[idx];
      if (tile.row != target.x || tile.col != target.y) {
        changed = true;
      }
      tile.row = target.x;
      tile.col = target.y;
    }

    return changed;
  }

  void _spawnRandomTile() {
    final empty = <Point<int>>[
      for (var r = 0; r < size; r++)
        for (var c = 0; c < size; c++)
          if (_tileAt(r, c) == null) Point(r, c),
    ];
    if (empty.isEmpty) return;
    final spot = empty[_random.nextInt(empty.length)];
    final value = _random.nextDouble() < 0.9 ? 2 : 4;
    _tiles.add(Tile(value: value, row: spot.x, col: spot.y, isNew: true));
  }

  bool _hasAnyLegalMove() {
    if (_tiles.length < size * size) return true;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final value = _tileAt(r, c)!.value;
        final right = c + 1 < size ? _tileAt(r, c + 1) : null;
        final down = r + 1 < size ? _tileAt(r + 1, c) : null;
        if (right != null && right.value == value) return true;
        if (down != null && down.value == value) return true;
      }
    }
    return false;
  }
}
