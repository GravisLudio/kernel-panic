import 'piece.dart';
import 'position.dart';

class Board {
  final Map<Position, Piece> pieces;

  const Board({required this.pieces});

  // El Root Zone (Núcleo Central) en un tablero 8x8 clásico está en d4, d5, e4, e5.
  // Es decir, posiciones X: [3, 4], Y: [3, 4]
  bool isRootZone(Position pos) {
    return (pos.x == 3 || pos.x == 4) && (pos.y == 3 || pos.y == 4);
  }

  Piece? getPieceAt(Position pos) {
    return pieces[pos];
  }

  bool isInsideBoard(Position pos) {
    return pos.x >= 0 && pos.x < 8 && pos.y >= 0 && pos.y < 8;
  }

  Board copyWith({Map<Position, Piece>? pieces}) {
    return Board(pieces: pieces ?? this.pieces);
  }

  factory Board.initial() {
    final p = <Position, Piece>{};

    void addRow(int y, PieceColor color, int scriptDir) {
      // Fila principal
      p[Position(0, y)] = Piece(id: '${color.name}_firewall_1', type: PieceType.firewall, color: color);
      p[Position(1, y)] = Piece(id: '${color.name}_daemon_1', type: PieceType.daemon, color: color, hasGhost: true);
      p[Position(2, y)] = Piece(id: '${color.name}_worm_1', type: PieceType.worm, color: color);
      p[Position(3, y)] = Piece(id: '${color.name}_matrix_1', type: PieceType.matrix, color: color);
      p[Position(4, y)] = Piece(id: '${color.name}_kernel_1', type: PieceType.kernel, color: color);
      p[Position(5, y)] = Piece(id: '${color.name}_worm_2', type: PieceType.worm, color: color);
      p[Position(6, y)] = Piece(id: '${color.name}_daemon_2', type: PieceType.daemon, color: color, hasGhost: true);
      p[Position(7, y)] = Piece(id: '${color.name}_firewall_2', type: PieceType.firewall, color: color);

      // Fila de Scripts
      final scriptY = color == PieceColor.black ? y + 1 : y - 1;
      for (int i = 0; i < 8; i++) {
        p[Position(i, scriptY)] = Piece(id: '${color.name}_script_$i', type: PieceType.script, color: color, scriptDir: scriptDir);
      }
    }

    addRow(0, PieceColor.black, 1);
    addRow(7, PieceColor.white, -1);

    return Board(pieces: p);
  }

  List<Map<String, dynamic>> toJson() {
    return pieces.entries.map((entry) {
      return {
        'x': entry.key.x,
        'y': entry.key.y,
        'piece': entry.value.toJson(),
      };
    }).toList();
  }

  factory Board.fromJson(List<dynamic> jsonList) {
    final Map<Position, Piece> pieces = {};
    for (var item in jsonList) {
      final map = item as Map<dynamic, dynamic>;
      final x = map['x'] as int;
      final y = map['y'] as int;
      final piece = Piece.fromJson(map['piece'] as Map<dynamic, dynamic>);
      pieces[Position(x, y)] = piece;
    }
    return Board(pieces: pieces);
  }
}
