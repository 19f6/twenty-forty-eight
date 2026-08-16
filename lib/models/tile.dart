class Tile {
  static int _nextId = 0;

  final int id;
  int value;
  int row;
  int col;

  bool justMerged;
  bool isNew;

  Tile({
    required this.value,
    required this.row,
    required this.col,
    this.justMerged = false,
    this.isNew = false,
  }) : id = _nextId++;
}
