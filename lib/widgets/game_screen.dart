import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game_board.dart';
import '../services/best_score_store.dart';
import '../theme/app_theme.dart';
import 'board_widget.dart';
import 'score_box.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final BestScoreStore _store = BestScoreStore();
  GameBoard? _board;
  int _lastSavedBest = 0;

  double _dragDx = 0;
  double _dragDy = 0;
  static const double _swipeThreshold = 24;

  @override
  void initState() {
    super.initState();
    _loadAndStart();
  }

  Future<void> _loadAndStart() async {
    final best = await _store.load();
    final board = GameBoard(best: best);
    board.addListener(_persistBestIfChanged);
    if (!mounted) return;
    setState(() {
      _board = board;
      _lastSavedBest = best;
    });
  }

  void _persistBestIfChanged() {
    final board = _board;
    if (board == null || board.best == _lastSavedBest) return;
    _lastSavedBest = board.best;
    _store.save(board.best);
  }

  @override
  void dispose() {
    _board?.removeListener(_persistBestIfChanged);
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _dragDx = 0;
    _dragDy = 0;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _dragDx += details.delta.dx;
    _dragDy += details.delta.dy;
  }

  void _onPanEnd(DragEndDetails details) {
    final board = _board;
    if (board == null) return;
    if (_dragDx.abs() < _swipeThreshold && _dragDy.abs() < _swipeThreshold) {
      return;
    }
    if (_dragDx.abs() > _dragDy.abs()) {
      board.move(_dragDx > 0 ? Direction.right : Direction.left);
    } else {
      board.move(_dragDy > 0 ? Direction.down : Direction.up);
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    final board = _board;
    if (board == null || event is! KeyDownEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        board.move(Direction.left);
      case LogicalKeyboardKey.arrowRight:
        board.move(Direction.right);
      case LogicalKeyboardKey.arrowUp:
        board.move(Direction.up);
      case LogicalKeyboardKey.arrowDown:
        board.move(Direction.down);
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final board = _board;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: board == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.accent),
                )
              : Focus(
                  autofocus: true,
                  onKeyEvent: _onKeyEvent,
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    behavior: HitTestBehavior.translucent,
                    child: ListenableBuilder(
                      listenable: board,
                      builder: (context, _) => _GameBody(board: board),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _GameBody extends StatelessWidget {
  const _GameBody({required this.board});

  final GameBoard board;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(board: board),
          const SizedBox(height: 8),
          const _Instructions(),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final boardSize =
                      constraints.maxWidth < constraints.maxHeight
                          ? constraints.maxWidth
                          : constraints.maxHeight;
                  return SizedBox(
                    width: boardSize,
                    height: boardSize,
                    child: Stack(
                      children: [
                        BoardWidget(board: board, boardSize: boardSize),
                        if (board.isGameOver)
                          _GameOverOverlay(
                            boardSize: boardSize,
                            onRestart: board.startNewGame,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.board});

  final GameBoard board;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.titleGradient.createShader(bounds),
            child: const Text(
              '2048',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScoreBox(label: 'SCORE', value: board.score),
                const SizedBox(width: 8),
                ScoreBox(label: 'BEST', value: board.best),
                const SizedBox(width: 8),
                _RestartButton(onPressed: board.startNewGame),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RestartButton extends StatelessWidget {
  const _RestartButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'New Game',
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: const Color(0xFF0F1020),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _Instructions extends StatelessWidget {
  const _Instructions();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Swipe (or use arrow keys) to move tiles. Combine matching tiles to reach 2048!',
        style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({required this.boardSize, required this.onRestart});

  final double boardSize;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: 1,
      child: Container(
        width: boardSize,
        height: boardSize,
        decoration: BoxDecoration(
          color: const Color(0xE614122B),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.titleGradient.createShader(bounds),
              child: const Text(
                'Game Over!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: const Color(0xFF0F1020),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
