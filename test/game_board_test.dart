import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_forty_eight/models/game_board.dart';

void main() {
  group('startNewGame', () {
    test('spawns 3 or 4 tiles with value 2 or 4, score starts at 0', () {
      final board = GameBoard();
      expect(board.tiles.length, anyOf(3, 4));
      expect(board.score, 0);
      expect(board.isGameOver, isFalse);
      for (final tile in board.tiles) {
        expect(tile.value, anyOf(2, 4));
      }
    });
  });

  group('move', () {
    test('slides tiles left and merges equal pairs once', () {
      final board = GameBoard.withTiles([
        [2, 2, null, null],
        [null, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
      ]);

      final moved = board.move(Direction.left);

      expect(moved, isTrue);
      expect(board.score, 4);
      final row0 = board.tiles.where((t) => t.row == 0).toList();
      final merged = row0.firstWhere((t) => !t.isNew);
      expect(merged.col, 0);
      expect(merged.value, 4);
      expect(merged.justMerged, isTrue);
    });

    test('does not double-merge a chain of four equal tiles', () {
      final board = GameBoard.withTiles([
        [2, 2, 2, 2],
        [null, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
      ]);

      board.move(Direction.left);

      final oldRow0 = board.tiles.where((t) => t.row == 0 && !t.isNew).toList()
        ..sort((a, b) => a.col.compareTo(b.col));
      expect(oldRow0.map((t) => t.value).toList(), [4, 4]);
      expect(board.score, 8);
    });

    test('slides tiles right toward the far edge', () {
      final board = GameBoard.withTiles([
        [2, 2, null, null],
        [null, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
      ]);

      board.move(Direction.right);

      final merged =
          board.tiles.where((t) => t.row == 0 && !t.isNew).single;
      expect(merged.col, 3);
      expect(merged.value, 4);
    });

    test('slides tiles up and down along a column', () {
      final board = GameBoard.withTiles([
        [null, 2, null, null],
        [null, null, null, null],
        [null, 2, null, null],
        [null, null, null, null],
      ]);

      board.move(Direction.up);

      final merged =
          board.tiles.where((t) => t.col == 1 && !t.isNew).single;
      expect(merged.row, 0);
      expect(merged.value, 4);
    });

    test('a move that changes nothing returns false and does not spawn', () {
      final board = GameBoard.withTiles([
        [2, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
      ]);

      final moved = board.move(Direction.left);

      expect(moved, isFalse);
      expect(board.tiles.length, 1);
      expect(board.score, 0);
    });

    test('updates best score and never lowers it', () {
      final board = GameBoard.withTiles(
        [
          [2, 2, null, null],
          [null, null, null, null],
          [null, null, null, null],
          [null, null, null, null],
        ],
        score: 0,
      );

      board.move(Direction.left);
      expect(board.best, board.score);
      final bestAfterFirstMove = board.best;

      board.move(Direction.left);
      expect(board.best, bestAfterFirstMove);
    });
  });

  group('game over detection', () {
    test('a full board with an available merge is not game over', () {
      final board = GameBoard.withTiles([
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 4],
      ]);

      expect(board.isGameOver, isFalse);
    });

    test('a full board with no adjacent equal values is game over', () {
      final board = GameBoard.withTiles([
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ]);

      expect(board.isGameOver, isTrue);
    });

    test('a board with an empty cell is never game over', () {
      final board = GameBoard.withTiles([
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, null],
      ]);

      expect(board.isGameOver, isFalse);
    });

    test('move() is a no-op once the game is over', () {
      final board = GameBoard.withTiles([
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ]);

      expect(board.move(Direction.left), isFalse);
    });
  });
}
