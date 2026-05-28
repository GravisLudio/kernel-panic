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
      Position? whiteKernelKidnapper = state.whiteKernelKidnapper;
      Position? blackKernelKidnapper = state.blackKernelKidnapper;
      PieceColor? winner = state.winner;
      bool clearAttacker = false;
      bool clearWhiteKidnapper = false;
      bool clearBlackKidnapper = false;

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

      // 1.5 EVALUAR LIBERACIÓN / CONTRA-SECUESTRO (Modo Kidnapping)
      if (state.gameMode == GameMode.kidnapping) {
        // Si una pieza Blanca captura al secuestrador del Kernel Blanco (que es una pieza Negra en whiteKernelKidnapper)
        if (state.whiteKernelKidnapper != null && to == state.whiteKernelKidnapper) {
          _reviveKernel(currentPieces, PieceColor.white, to);
          clearWhiteKidnapper = true;
          
          // Y además captura al Kernel Negro enemigo! La pieza Blanca en 'to' se convierte en el secuestrador del Kernel Negro.
          _removePieceOfType(currentPieces, PieceType.kernel, PieceColor.black);
          blackKernelKidnapper = to;
        }
        // Si una pieza Negra captura al secuestrador del Kernel Negro (que es una pieza Blanca en blackKernelKidnapper)
        else if (state.blackKernelKidnapper != null && to == state.blackKernelKidnapper) {
          _reviveKernel(currentPieces, PieceColor.black, to);
          clearBlackKidnapper = true;
          
          // Y además captura al Kernel Blanco enemigo! La pieza Negra en 'to' se convierte en el secuestrador del Kernel Blanco.
          _removePieceOfType(currentPieces, PieceType.kernel, PieceColor.white);
          whiteKernelKidnapper = to;
        }
      }

      // 2. EVALUAR NUEVAS CAPTURAS DE KERNEL
      if (targetPiece != null) {
        if (targetPiece.type == PieceType.kernel) {
          if (state.gameMode == GameMode.assassination) {
            isKernelInDanger = true;
            attackerPosition = to;
          } else if (state.gameMode == GameMode.kidnapping) {
            if (targetPiece.color == PieceColor.white) {
              whiteKernelKidnapper = to;
            } else {
              blackKernelKidnapper = to;
            }
          }
        }
      }

      // 2.5 ACTUALIZAR POSICIÓN DE SECUESTRADOR AL MOVERSE
      if (state.gameMode == GameMode.kidnapping) {
        if (from == state.whiteKernelKidnapper) {
          whiteKernelKidnapper = to;
        }
        if (from == state.blackKernelKidnapper) {
          blackKernelKidnapper = to;
        }
      }

      // 3. EVALUAR VICTORIA POR SECUESTRO / EXTRACCIÓN
      if (state.gameMode == GameMode.kidnapping) {
        // Si el secuestrador del Kernel Negro (pieza blanca) llega a la fila 7 (fila base blanca)
        if (blackKernelKidnapper != null && blackKernelKidnapper == to) {
          if (to.y == 7) {
            winner = PieceColor.white;
          }
        }
        // Si el secuestrador del Kernel Blanco (pieza negra) llega a la fila 0 (fila base negra)
        if (whiteKernelKidnapper != null && whiteKernelKidnapper == to) {
          if (to.y == 0) {
            winner = PieceColor.black;
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
        whiteKernelKidnapper: whiteKernelKidnapper,
        blackKernelKidnapper: blackKernelKidnapper,
        clearWhiteKidnapper: clearWhiteKidnapper,
        clearBlackKidnapper: clearBlackKidnapper,
        winner: winner,
        clearSelectedPosition: true,
      );
    }
  }

  void toggleOverclock() {
    if (state.winner != null) return;

    final isWhite = state.currentTurn == PieceColor.white;
    final isAlreadyUsed = isWhite ? state.whiteOverclockUsed : state.blackOverclockUsed;

    if (state.isOverclockActive) {
      state = state.copyWith(
        isOverclockActive: false,
        whiteOverclockUsed: isWhite ? false : state.whiteOverclockUsed,
        blackOverclockUsed: !isWhite ? false : state.blackOverclockUsed,
      );
    } else {
      if (isAlreadyUsed) return;
      state = state.copyWith(
        isOverclockActive: true,
        whiteOverclockUsed: isWhite ? true : state.whiteOverclockUsed,
        blackOverclockUsed: !isWhite ? true : state.blackOverclockUsed,
      );
    }
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

    bool clearWhiteKidnapper = false;
    bool clearBlackKidnapper = false;
    bool clearAttacker = false;
    bool isKernelInDanger = state.isKernelInDanger;
    PieceColor? winner = state.winner;
    Position? whiteKernelKidnapper = state.whiteKernelKidnapper;
    Position? blackKernelKidnapper = state.blackKernelKidnapper;

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
    } else if (state.gameMode == GameMode.kidnapping) {
      // Si la pieza que usa Ghost (color = state.currentTurn) mata al secuestrador de su propio Kernel
      if (state.currentTurn == PieceColor.white && state.whiteKernelKidnapper != null && targetPos == state.whiteKernelKidnapper) {
        _reviveKernel(currentPieces, PieceColor.white, targetPos);
        clearWhiteKidnapper = true;
        
        // Y además captura al Kernel Negro enemigo! El Daemon que saltó a targetPos se convierte en el secuestrador del Kernel Negro.
        _removePieceOfType(currentPieces, PieceType.kernel, PieceColor.black);
        blackKernelKidnapper = targetPos;
      }
      else if (state.currentTurn == PieceColor.black && state.blackKernelKidnapper != null && targetPos == state.blackKernelKidnapper) {
        _reviveKernel(currentPieces, PieceColor.black, targetPos);
        clearBlackKidnapper = true;
        
        // Y además captura al Kernel Blanco enemigo! El Daemon que saltó a targetPos se convierte en el secuestrador del Kernel Blanco.
        _removePieceOfType(currentPieces, PieceType.kernel, PieceColor.white);
        whiteKernelKidnapper = targetPos;
      }
      else if (state.whiteKernelKidnapper != null && targetPos == state.whiteKernelKidnapper) {
        _reviveKernel(currentPieces, PieceColor.white, targetPos);
        clearWhiteKidnapper = true;
      }
      else if (state.blackKernelKidnapper != null && targetPos == state.blackKernelKidnapper) {
        _reviveKernel(currentPieces, PieceColor.black, targetPos);
        clearBlackKidnapper = true;
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
      clearGhostSource: true,
      isKernelInDanger: isKernelInDanger,
      winner: winner,
      clearAttacker: clearAttacker,
      clearWhiteKidnapper: clearWhiteKidnapper,
      clearBlackKidnapper: clearBlackKidnapper,
      whiteKernelKidnapper: whiteKernelKidnapper,
      blackKernelKidnapper: blackKernelKidnapper,
      clearSelectedPosition: true,
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

  void selectPosition(Position? pos) {
    if (state.winner != null) return;
    if (state.isGhostTargeting) return;

    if (state.selectedPosition != null && pos != null) {
      final validMoves = getValidMovesFor(state.selectedPosition!);
      if (validMoves.contains(pos)) {
        movePiece(state.selectedPosition!, pos);
        return;
      }
    }

    if (pos != null) {
      final piece = state.board.getPieceAt(pos);
      if (piece != null && piece.color == state.currentTurn) {
        state = state.copyWith(selectedPosition: pos);
        return;
      }
    }

    state = state.copyWith(clearSelectedPosition: true);
  }

  void _removePieceOfType(Map<Position, Piece> pieces, PieceType type, PieceColor color) {
    Position? posToRemove;
    for (var entry in pieces.entries) {
      if (entry.value.type == type && entry.value.color == color) {
        posToRemove = entry.key;
        break;
      }
    }
    if (posToRemove != null) {
      pieces.remove(posToRemove);
    }
  }

  void setGameMode(GameMode mode) {
    state = GameState.initial(mode: mode);
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(() {
  return GameNotifier();
});
