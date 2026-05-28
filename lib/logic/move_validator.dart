import '../models/board.dart';
import '../models/position.dart';
import '../models/piece.dart';

class MoveValidator {
  final Board board;

  MoveValidator(this.board);

  List<Position> getValidMoves(Position start) {
    final piece = board.getPieceAt(start);
    if (piece == null) return [];

    List<Position> moves = [];

    switch (piece.type) {
      case PieceType.kernel:
        moves = _getKernelMoves(start, piece);
        break;
      case PieceType.matrix:
        moves = _getMatrixMoves(start, piece);
        break;
      case PieceType.daemon:
        moves = _getDaemonMoves(start, piece);
        break;
      case PieceType.script:
        moves = _getScriptMoves(start, piece);
        break;
      case PieceType.firewall:
        moves = _getFirewallMoves(start, piece);
        break;
      case PieceType.worm:
        moves = _getWormMoves(start, piece);
        break;
    }

    // Filtrar movimientos fuera del tablero o a casillas con piezas del mismo color
    return moves.where((pos) {
      if (!board.isInsideBoard(pos)) return false;
      final targetPiece = board.getPieceAt(pos);
      if (targetPiece != null && targetPiece.color == piece.color) return false;
      return true;
    }).toList();
  }

  List<Position> _getKernelMoves(Position pos, Piece piece) {
    // 1 casilla todas las direcciones + 2 casillas ortogonal
    List<Position> moves = [];
    final dirs = [
      [-1, -1], [0, -1], [1, -1],
      [-1, 0],           [1, 0],
      [-1, 1],  [0, 1],  [1, 1],
    ];
    for (var d in dirs) {
      moves.add(Position(pos.x + d[0], pos.y + d[1]));
    }
    // Saltos ortogonales de 2
    final jumpDirs = [
      [0, -2], [0, 2], [-2, 0], [2, 0]
    ];
    for (var d in jumpDirs) {
      moves.add(Position(pos.x + d[0], pos.y + d[1]));
    }
    return moves;
  }

  List<Position> _getMatrixMoves(Position pos, Piece piece) {
    return _getSlidingMoves(pos, [
      [-1, -1], [0, -1], [1, -1],
      [-1, 0],           [1, 0],
      [-1, 1],  [0, 1],  [1, 1],
    ]);
  }

  List<Position> _getFirewallMoves(Position pos, Piece piece) {
    return _getSlidingMoves(pos, [
      [0, -1], [-1, 0], [1, 0], [0, 1],
    ]);
  }

  List<Position> _getSlidingMoves(Position pos, List<List<int>> directions) {
    List<Position> moves = [];
    for (var d in directions) {
      int cx = pos.x + d[0];
      int cy = pos.y + d[1];
      while (board.isInsideBoard(Position(cx, cy))) {
        final p = Position(cx, cy);
        moves.add(p);
        if (board.getPieceAt(p) != null) break; // Bloqueado después de esta casilla
        cx += d[0];
        cy += d[1];
      }
    }
    return moves;
  }

  List<Position> _getDaemonMoves(Position pos, Piece piece) {
    List<Position> moves = [];
    final jumps = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1]
    ];
    for (var j in jumps) {
      moves.add(Position(pos.x + j[0], pos.y + j[1]));
    }
    return moves;
  }

  List<Position> _getWormMoves(Position pos, Piece piece) {
    List<Position> moves = [];
    final diagonals = [
      [-1, -1], [1, -1], [-1, 1], [1, 1]
    ];
    final bool canJump = piece.jumpsRemaining > 0;

    for (var d in diagonals) {
      int cx = pos.x + d[0];
      int cy = pos.y + d[1];
      bool jumped = false;
      
      while (board.isInsideBoard(Position(cx, cy))) {
        final p = Position(cx, cy);
        final targetPiece = board.getPieceAt(p);
        
        if (targetPiece == null) {
          moves.add(p);
          if (jumped) {
            // El Worm debe aterrizar exactamente una casilla después de la pieza saltada.
            // Si llega aquí, el aterrizaje es válido (vacío) y la trayectoria termina.
            break; 
          }
        } else {
          if (!jumped) {
            if (canJump) {
              // Intenta saltar la pieza
              jumped = true;
            } else {
              // No puede saltar, así que puede capturar la primera pieza encontrada y terminar
              moves.add(p);
              break;
            }
          } else {
            // Ya saltó una pieza y la casilla de aterrizaje ESTÁ OCUPADA.
            // El Worm solo puede saltar si la casilla INMEDIATAMENTE detrás está vacía.
            // Por lo tanto, no puede aterrizar aquí y el salto es inválido.
            break;
          }
        }
        cx += d[0];
        cy += d[1];
      }
    }
    return moves;
  }

  List<Position> _getScriptMoves(Position pos, Piece piece) {
    List<Position> moves = [];
    final dir = piece.scriptDir;
    
    final orthogonalMoves = [
      Position(pos.x, pos.y + dir),
      Position(pos.x - 1, pos.y),
      Position(pos.x + 1, pos.y),
    ];

    if (board.isRootZone(pos)) {
      // Multi-threading: Puede moverse hacia atrás
      orthogonalMoves.add(Position(pos.x, pos.y - dir));
    }

    // Movimientos ortogonales: Solo a casillas VACÍAS
    for (var p in orthogonalMoves) {
      if (board.isInsideBoard(p) && board.getPieceAt(p) == null) {
        moves.add(p);
      }
    }

    // Movimientos diagonales: Solo para CAPTURAR
    final diagonalCaptures = [
      Position(pos.x - 1, pos.y + dir),
      Position(pos.x + 1, pos.y + dir),
    ];
    if (board.isRootZone(pos)) {
      diagonalCaptures.add(Position(pos.x - 1, pos.y - dir));
      diagonalCaptures.add(Position(pos.x + 1, pos.y - dir));
    }

    for (var p in diagonalCaptures) {
      if (board.isInsideBoard(p)) {
        final target = board.getPieceAt(p);
        if (target != null && target.color != piece.color) {
          moves.add(p);
        }
      }
    }

    return moves;
  }
}
