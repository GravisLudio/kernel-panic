import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board.dart';
import '../models/game_state.dart';
import '../models/position.dart';
import '../models/piece.dart';
import '../logic/move_validator.dart';

class GameNotifier extends Notifier<GameState> {
  @override
  GameState build() {
    return GameState.initial();
  }

  bool canMovePiece(Position from, Position to) {
    if (state.winner != null) return false;
    if (from == to) return false;
    final piece = state.board.getPieceAt(from);
    if (piece == null || piece.color != state.currentTurn) return false;

    final validator = MoveValidator(state.board);
    final validMoves = validator.getValidMoves(from);
    return validMoves.contains(to);
  }

  void movePiece(Position from, Position to) {
    if (!canMovePiece(from, to)) return;

    final currentPieces = Map<Position, Piece>.from(state.board.pieces);
    var pieceToMove = currentPieces[from];
    final targetPiece = currentPieces[to];

    if (pieceToMove != null) {
      currentPieces.remove(from);

      // Lógica de rebote para Script
      if (pieceToMove.type == PieceType.script) {
        if ((pieceToMove.scriptDir == 1 && to.y == 7) || (pieceToMove.scriptDir == -1 && to.y == 0)) {
          pieceToMove = pieceToMove.copyWith(scriptDir: pieceToMove.scriptDir * -1);
        }
      }

      // Lógica de salto para Worm
      if (pieceToMove.type == PieceType.worm && pieceToMove.jumpsRemaining > 0) {
        int dx = (to.x - from.x).sign;
        int dy = (to.y - from.y).sign;
        int cx = from.x + dx;
        int cy = from.y + dy;
        bool didJump = false;
        
        while (cx != to.x || cy != to.y) {
          if (currentPieces[Position(cx, cy)] != null) {
            didJump = true;
            break;
          }
          cx += dx;
          cy += dy;
        }

        if (didJump) {
          pieceToMove = pieceToMove.copyWith(jumpsRemaining: pieceToMove.jumpsRemaining - 1);
        }
      }

      currentPieces[to] = pieceToMove;

      bool isKernelInDanger = state.isKernelInDanger;
      Position? attackerPosition = state.attackerPosition;
      Position? kidnapperPosition = state.kidnapperPosition;
      PieceColor? winner = state.winner;
      bool clearAttacker = false;
      bool clearKidnapper = false;

      // 1. EVALUAR RESCATE (Modo Assassination)
      if (state.gameMode == GameMode.assassination && state.isKernelInDanger) {
        if (to == state.attackerPosition) {
          // ¡Rescate exitoso! El Kernel revive
          _reviveKernel(currentPieces, state.currentTurn, to);
          isKernelInDanger = false;
          clearAttacker = true;
        } else {
          // Falló el rescate. El oponente gana.
          winner = state.currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
        }
      }

      // 2. EVALUAR NUEVAS CAPTURAS
      if (targetPiece != null) {
        if (targetPiece.type == PieceType.kernel) {
          if (state.gameMode == GameMode.assassination) {
            isKernelInDanger = true;
            attackerPosition = to;
          } else if (state.gameMode == GameMode.kidnapping) {
            kidnapperPosition = to;
          }
        } else if (to == state.kidnapperPosition) {
           // Asesinaron al secuestrador, el Kernel revive
           _reviveKernel(currentPieces, state.currentTurn, to);
           clearKidnapper = true;
        }
      }

      // 3. EVALUAR VICTORIA POR SECUESTRO
      if (state.gameMode == GameMode.kidnapping && kidnapperPosition != null) {
         if (from == state.kidnapperPosition) {
            kidnapperPosition = to; // Actualizamos la posición del secuestrador si se movió
         }
         // Si el secuestrador llega a su propia fila base (0 para negro, 7 para blanco)
         if ((pieceToMove.color == PieceColor.black && to.y == 0) || 
             (pieceToMove.color == PieceColor.white && to.y == 7)) {
            if (to == kidnapperPosition) {
               winner = pieceToMove.color;
            }
         }
      }

      bool isOverclockActive = state.isOverclockActive;
      PieceColor nextTurn = state.currentTurn;
      if (isOverclockActive) {
        isOverclockActive = false;
      } else {
        nextTurn = state.currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
      }

      state = state.copyWith(
        board: state.board.copyWith(pieces: currentPieces),
        currentTurn: nextTurn,
        isOverclockActive: isOverclockActive,
        isGhostTargeting: false,
        isKernelInDanger: isKernelInDanger,
        attackerPosition: attackerPosition,
        clearAttacker: clearAttacker,
        kidnapperPosition: kidnapperPosition,
        clearKidnapper: clearKidnapper,
        winner: winner,
      );
    }
  }

  void toggleOverclock() {
    if (state.winner != null) return;
    if (state.currentTurn == PieceColor.white && state.whiteOverclockUsed) return;
    if (state.currentTurn == PieceColor.black && state.blackOverclockUsed) return;

    state = state.copyWith(
      isOverclockActive: true,
      whiteOverclockUsed: state.currentTurn == PieceColor.white ? true : state.whiteOverclockUsed,
      blackOverclockUsed: state.currentTurn == PieceColor.black ? true : state.blackOverclockUsed,
    );
  }

  void toggleGhostMode() {
    if (state.winner != null) return;
    
    if (state.isGhostTargeting) {
      // Cancelar
      state = state.copyWith(isGhostTargeting: false, clearGhostSource: true);
      return;
    }

    // Buscar si hay un Daemon disponible
    final availableDaemons = state.board.pieces.entries.where(
      (e) => e.value.type == PieceType.daemon && e.value.color == state.currentTurn && !e.value.hasUsedGhost
    ).toList();

    if (availableDaemons.isEmpty) return;

    Position? sourcePos;
    // Si solo hay 1 Daemon disponible, autoseleccionarlo para ahorrar un click
    if (availableDaemons.length == 1) {
      sourcePos = availableDaemons.first.key;
    }

    state = state.copyWith(isGhostTargeting: true, ghostSourcePosition: sourcePos);
  }

  void useGhostOn(Position targetPos) {
    if (!state.isGhostTargeting) return;

    if (state.ghostSourcePosition == null) {
      // Estamos en la fase de seleccionar el Daemon a usar
      final piece = state.board.getPieceAt(targetPos);
      if (piece != null && piece.type == PieceType.daemon && piece.color == state.currentTurn && !piece.hasUsedGhost) {
        state = state.copyWith(ghostSourcePosition: targetPos);
      }
      return;
    }

    // Si hace click en sí mismo, deseleccionarlo
    if (targetPos == state.ghostSourcePosition) {
      state = state.copyWith(clearGhostSource: true);
      return;
    }

    final targetPiece = state.board.getPieceAt(targetPos);
    if (targetPiece == null || targetPiece.color == state.currentTurn) return; // Debe ser enemigo
    if (targetPiece.type == PieceType.kernel || targetPiece.type == PieceType.firewall) return;
    if (state.board.isRootZone(targetPos)) return; // Root zone da Network Shield

    final currentPieces = Map<Position, Piece>.from(state.board.pieces);
    
    // Sacar el Daemon de su posición original
    final daemon = currentPieces.remove(state.ghostSourcePosition!);
    
    // Destruir la pieza enemiga y colocar al Daemon ahí, marcando su uso
    if (daemon != null) {
      currentPieces[targetPos] = daemon.copyWith(hasUsedGhost: true);
    }

    bool clearKidnapper = false;
    bool clearAttacker = false;
    bool isKernelInDanger = state.isKernelInDanger;
    PieceColor? winner = state.winner;

    // Rescate si el fantasma mató al atacante/secuestrador
    if (state.gameMode == GameMode.assassination && state.isKernelInDanger) {
      if (targetPos == state.attackerPosition) {
        _reviveKernel(currentPieces, state.currentTurn, targetPos);
        isKernelInDanger = false;
        clearAttacker = true;
      } else {
        // Falló el rescate.
        winner = state.currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
      }
    } else if (state.gameMode == GameMode.kidnapping && targetPos == state.kidnapperPosition) {
      _reviveKernel(currentPieces, state.currentTurn, targetPos);
      clearKidnapper = true;
    }

    bool isOverclockActive = state.isOverclockActive;
    PieceColor nextTurn = state.currentTurn;
    if (isOverclockActive) {
      isOverclockActive = false;
    } else {
      nextTurn = state.currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
    }

    state = state.copyWith(
      board: state.board.copyWith(pieces: currentPieces),
      currentTurn: nextTurn,
      isOverclockActive: isOverclockActive,
      isGhostTargeting: false,
      clearGhostSource: true,
      isKernelInDanger: isKernelInDanger,
      winner: winner,
      clearAttacker: clearAttacker,
      clearKidnapper: clearKidnapper,
    );
  }

  void _reviveKernel(Map<Position, Piece> pieces, PieceColor color, Position capturedAt) {
    Position initialPos = color == PieceColor.white ? Position(4, 7) : Position(4, 0);
    
    // 1. Intentar en la casilla de aparición al inicio si está libre
    if (pieces[initialPos] == null) {
      pieces[initialPos] = Piece(id: '${color.name}_kernel_revived_${DateTime.now().millisecondsSinceEpoch}', type: PieceType.kernel, color: color);
      return;
    }

    final dirs = [
      [-1, -1], [0, -1], [1, -1],
      [-1, 0],           [1, 0],
      [-1, 1],  [0, 1],  [1, 1],
    ];

    // 2. Si no está libre, buscar alrededor la más cercana disponible y SEGURA
    for (var d in dirs) {
      final adj = Position(initialPos.x + d[0], initialPos.y + d[1]);
      if (adj.x >= 0 && adj.x < 8 && adj.y >= 0 && adj.y < 8 && pieces[adj] == null) {
        if (_isSquareSafe(adj, color, pieces)) {
          pieces[adj] = Piece(id: '${color.name}_kernel_revived_${DateTime.now().millisecondsSinceEpoch}', type: PieceType.kernel, color: color);
          return;
        }
      }
    }

    // 3. Si no hay disponible, en las 8 casillas alrededor de donde fue capturado, que sea segura y más cercana a su origen
    List<Position> fallbackPositions = [];
    for (var d in dirs) {
      final adj = Position(capturedAt.x + d[0], capturedAt.y + d[1]);
      if (adj.x >= 0 && adj.x < 8 && adj.y >= 0 && adj.y < 8 && pieces[adj] == null) {
        if (_isSquareSafe(adj, color, pieces)) {
          fallbackPositions.add(adj);
        }
      }
    }

    if (fallbackPositions.isNotEmpty) {
      // Ordenar por distancia (en el eje Y) al lado de aparición
      fallbackPositions.sort((a, b) {
        int distA = (a.y - initialPos.y).abs();
        int distB = (b.y - initialPos.y).abs();
        return distA.compareTo(distB);
      });
      pieces[fallbackPositions.first] = Piece(id: '${color.name}_kernel_revived_${DateTime.now().millisecondsSinceEpoch}', type: PieceType.kernel, color: color);
      return;
    }

    // 4. Extremo (fallback de seguridad para no crashear): Cualquier casilla vacía
    for(int i=0; i<8; i++){
       for(int j=0; j<8; j++){
          if(pieces[Position(j,i)] == null){
             pieces[Position(j,i)] = Piece(id: '${color.name}_kernel_revived_${DateTime.now().millisecondsSinceEpoch}', type: PieceType.kernel, color: color);
             return;
          }
       }
    }
  }

  bool _isSquareSafe(Position pos, PieceColor kernelColor, Map<Position, Piece> pieces) {
    // Crear un tablero temporal con el Kernel ahí para validar amenazas
    final tempPieces = Map<Position, Piece>.from(pieces);
    tempPieces[pos] = Piece(id: 'temp_kernel', type: PieceType.kernel, color: kernelColor);
    final tempBoard = Board(pieces: tempPieces);
    final validator = MoveValidator(tempBoard);

    // Revisar si alguna pieza enemiga puede atacar esta posición
    for (var entry in tempPieces.entries) {
      if (entry.value.color != kernelColor) {
        final enemyMoves = validator.getValidMoves(entry.key);
        if (enemyMoves.contains(pos)) {
          return false; // Está bajo amenaza
        }
      }
    }
    return true; // Es segura
  }

  List<Position> getValidMovesFor(Position pos) {
    if (state.winner != null) return [];
    final piece = state.board.getPieceAt(pos);
    if (piece == null || piece.color != state.currentTurn) return [];
    final validator = MoveValidator(state.board);
    return validator.getValidMoves(pos);
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(() {
  return GameNotifier();
});
