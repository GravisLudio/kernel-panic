import 'dart:math';
import '../models/board.dart';
import '../models/game_state.dart';
import '../models/piece.dart';
import '../models/position.dart';
import 'move_validator.dart';

class BotLogic {
  static final _random = Random();

  /// Calculates the best move for the Bot (Black) based on difficulty level.
  /// Returns a Map of options:
  /// - 'action': 'move' or 'ghost'
  /// - 'from': Position
  /// - 'to': Position
  /// - 'useOverclock': bool
  static Map<String, dynamic>? calculateMove({
    required GameState state,
    required List<MapEntry<Position, Position>> validMoves,
    required List<MapEntry<Position, Position>> validGhostMoves,
  }) {
    if (validMoves.isEmpty && validGhostMoves.isEmpty) return null;

    final difficulty = state.botDifficulty;

    if (difficulty == 1) {
      return _calculateEasyMove(validMoves, validGhostMoves);
    } else if (difficulty == 2) {
      return _calculateMediumMove(state, validMoves, validGhostMoves);
    } else {
      return _calculateHardMove(state, validMoves, validGhostMoves);
    }
  }

  // --- LEVEL 1: EASY (SCRIPT BÁSICO) ---
  static Map<String, dynamic> _calculateEasyMove(
    List<MapEntry<Position, Position>> validMoves,
    List<MapEntry<Position, Position>> validGhostMoves,
  ) {
    // 85% de movimientos normales, 15% ghost si está disponible
    if (validGhostMoves.isNotEmpty && _random.nextDouble() < 0.15) {
      final choice = validGhostMoves[_random.nextInt(validGhostMoves.length)];
      return {
        'action': 'ghost',
        'from': choice.key,
        'to': choice.value,
        'useOverclock': false,
      };
    }

    // Seleccionar movimiento normal aleatorio
    final choice = validMoves[_random.nextInt(validMoves.length)];
    return {
      'action': 'move',
      'from': choice.key,
      'to': choice.value,
      'useOverclock': false,
    };
  }

  // --- LEVEL 2: MEDIUM (FIREWALL TÁCTICO) ---
  static Map<String, dynamic> _calculateMediumMove(
    GameState state,
    List<MapEntry<Position, Position>> validMoves,
    List<MapEntry<Position, Position>> validGhostMoves,
  ) {
    // El nivel medio prefiere hacer capturas directas (greedy logic).
    // Si no hay capturas directas, hace un movimiento seguro de avance.

    // 1. Evaluar si podemos ganar el juego de inmediato
    for (var move in validMoves) {
      final targetPiece = state.board.getPieceAt(move.value);
      
      // Asesinato: Capturar el Kernel
      if (state.gameMode == GameMode.assassination && targetPiece?.type == PieceType.kernel) {
        return {'action': 'move', 'from': move.key, 'to': move.value, 'useOverclock': false};
      }
      // Secuestro: Llevar el Kernel Blanco secuestrado a Y=0
      if (state.gameMode == GameMode.kidnapping &&
          state.whiteKernelKidnapper == move.key &&
          move.value.y == 0) {
        return {'action': 'move', 'from': move.key, 'to': move.value, 'useOverclock': false};
      }
    }

    // 2. Comprobar si podemos usar Ghost para capturar una pieza valiosa enemiga (Daemon/Matrix)
    if (validGhostMoves.isNotEmpty && _random.nextDouble() < 0.35) {
      // Filtrar capturas valiosas
      final premiumGhostMoves = validGhostMoves.where((gm) {
        final target = state.board.getPieceAt(gm.value);
        return target != null && (target.type == PieceType.matrix || target.type == PieceType.daemon);
      }).toList();

      if (premiumGhostMoves.isNotEmpty) {
        final choice = premiumGhostMoves[_random.nextInt(premiumGhostMoves.length)];
        return {'action': 'ghost', 'from': choice.key, 'to': choice.value, 'useOverclock': false};
      }
    }

    // 3. Buscar movimientos normales de captura en orden de valor de pieza
    MapEntry<Position, Position>? bestCapture;
    double highestPieceVal = -1.0;

    for (var move in validMoves) {
      final target = state.board.getPieceAt(move.value);
      if (target != null && target.color == PieceColor.white) {
        double val = _getPieceValue(target.type);
        if (val > highestPieceVal) {
          highestPieceVal = val;
          bestCapture = move;
        }
      }
    }

    // Activar Overclock en Medio con un 20% si hay captura de alto valor (Matrix/Daemon)
    final canUseOverclock = !state.blackOverclockUsed && !state.isOverclockActive;
    if (bestCapture != null) {
      bool useOc = canUseOverclock && highestPieceVal >= 5.0 && _random.nextDouble() < 0.20;
      return {
        'action': 'move',
        'from': bestCapture.key,
        'to': bestCapture.value,
        'useOverclock': useOc,
      };
    }

    // 4. Si no hay capturas, elegir movimientos que nos acerquen a la base enemiga
    // Ordenar movimientos normales por avance hacia adelante (Y creciente para Black)
    final advanceMoves = List<MapEntry<Position, Position>>.from(validMoves);
    advanceMoves.sort((a, b) {
      int distA = a.value.y - a.key.y;
      int distB = b.value.y - b.key.y;
      return distB.compareTo(distA); // Mayor avance primero
    });

    if (advanceMoves.isNotEmpty) {
      // Elegir entre los 3 mejores avances aleatoriamente para no ser predecible
      final poolSize = min(3, advanceMoves.length);
      final choice = advanceMoves[_random.nextInt(poolSize)];
      return {
        'action': 'move',
        'from': choice.key,
        'to': choice.value,
        'useOverclock': false,
      };
    }

    // Fallback absoluto
    return {
      'action': 'move',
      'from': validMoves.first.key,
      'to': validMoves.first.value,
      'useOverclock': false,
    };
  }

  // --- LEVEL 3: HARD (KERNEL OVERLORD) ---
  static Map<String, dynamic> _calculateHardMove(
    GameState state,
    List<MapEntry<Position, Position>> validMoves,
    List<MapEntry<Position, Position>> validGhostMoves,
  ) {
    // Minimax de Profundidad 2. Evaluamos todos los movimientos posibles del Bot (Negro)
    // y para cada uno estimamos la mejor respuesta posible del Humano (Blanco).
    // Tomamos la decisión maximizando la puntuación neta.

    double bestScore = -double.infinity;
    MapEntry<Position, Position>? bestNormalMove;
    MapEntry<Position, Position>? bestGhostMove;
    bool shouldOverclock = false;

    // Evaluamos movimientos normales
    for (var move in validMoves) {
      final simulatedBoard = _simulateMove(state.board, move.key, move.value);
      final currentScore = _evaluateMinimax(state, simulatedBoard, PieceColor.white, 1);

      if (currentScore > bestScore) {
        bestScore = currentScore;
        bestNormalMove = move;
        bestGhostMove = null;
      }
    }

    // Evaluamos movimientos de Ghost
    for (var gmove in validGhostMoves) {
      final simulatedBoard = _simulateGhost(state.board, gmove.key, gmove.value);
      // Ghost tiene un valor premium adicional por el salto estratégico
      final currentScore = _evaluateMinimax(state, simulatedBoard, PieceColor.white, 1) + 2.0;

      if (currentScore > bestScore) {
        bestScore = currentScore;
        bestGhostMove = gmove;
        bestNormalMove = null;
      }
    }

    // Lógica para decidir si activar Overclock (solo si no se ha usado)
    final canUseOverclock = !state.blackOverclockUsed && !state.isOverclockActive;
    if (canUseOverclock && bestScore > 50.0) {
      // Si la mejor jugada otorga una ventaja considerable (como una captura mayor o amenaza de victoria),
      // activamos Overclock para duplicar la agresión.
      shouldOverclock = true;
    }

    if (bestGhostMove != null) {
      return {
        'action': 'ghost',
        'from': bestGhostMove.key,
        'to': bestGhostMove.value,
        'useOverclock': false, // Ghost no activa Overclock directamente
      };
    }

    final finalMove = bestNormalMove ?? validMoves.first;
    return {
      'action': 'move',
      'from': finalMove.key,
      'to': finalMove.value,
      'useOverclock': shouldOverclock,
    };
  }

  // --- FUNCIONES DE EVALUACIÓN HEURÍSTICA DE MINIMAX ---

  /// Simula el turno del oponente (Blanco) que buscará minimizar el puntaje para Negro
  static double _evaluateMinimax(GameState state, Board board, PieceColor turnColor, int depth) {
    if (depth == 0) {
      return _evaluateBoard(state, board);
    }

    final validator = MoveValidator(board);
    final moves = <MapEntry<Position, Position>>[];

    // Obtener movimientos del oponente
    for (var entry in board.pieces.entries) {
      if (entry.value.color == turnColor) {
        final destinations = validator.getValidMoves(entry.key);
        for (var dest in destinations) {
          moves.add(MapEntry(entry.key, dest));
        }
      }
    }

    if (moves.isEmpty) {
      return _evaluateBoard(state, board);
    }

    // Turno Blanco: El oponente busca MINIMIZAR la puntuación de Negro
    double minScore = double.infinity;
    for (var move in moves.take(20)) { // Limitado a los primeros 20 para evitar explosión
      final nextBoard = _simulateMove(board, move.key, move.value);
      final score = _evaluateBoard(state, nextBoard);
      if (score < minScore) {
        minScore = score;
      }
    }
    return minScore;
  }

  /// Función Heurística de Puntuación de Tablero.
  /// Valores altos benefician a NEGRO, valores bajos a BLANCO.
  static double _evaluateBoard(GameState state, Board board) {
    double score = 0.0;

    bool hasBlackKernel = false;
    bool hasWhiteKernel = false;

    for (var entry in board.pieces.entries) {
      final pos = entry.key;
      final piece = entry.value;

      double val = _getPieceValue(piece.type);

      if (piece.color == PieceColor.black) {
        score += val;
        // Positional bonus: Avanzar piezas (Y creciente) hacia la base blanca
        if (piece.type != PieceType.kernel) {
          score += pos.y * 0.15;
        } else {
          hasBlackKernel = true;
        }
      } else {
        score -= val;
        // Positional bonus: Avanzar piezas blancas (Y decreciente) hacia la base negra
        if (piece.type != PieceType.kernel) {
          score -= (7 - pos.y) * 0.15;
        } else {
          hasWhiteKernel = true;
        }
      }
    }

    // 1. CONDICIONES DE VICTORIA DIRECTAS (Modo Asesinato)
    if (state.gameMode == GameMode.assassination) {
      if (!hasWhiteKernel) score += 5000.0; // Ganamos
      if (!hasBlackKernel) score -= 5000.0; // Perdemos
    }

    // 2. CONDICIONES DE VICTORIA DIRECTAS Y SECUESTROS (Modo Secuestro)
    if (state.gameMode == GameMode.kidnapping) {
      // Buscar quién tiene secuestrado a quién en este tablero simulado
      Position? whiteKidnapperPos;
      Position? blackKidnapperPos;

      for (var entry in board.pieces.entries) {
        final pos = entry.key;
        final piece = entry.value;

        // Si es una pieza blanca secuestrando al Kernel Negro
        if (piece.color == PieceColor.white && piece.type != PieceType.kernel) {
          // Buscamos si en la lista original era secuestrador y se movió a pos
          if (pos == state.blackKernelKidnapper) {
            blackKidnapperPos = pos;
          }
        }
        // Si es una pieza negra secuestrando al Kernel Blanco
        if (piece.color == PieceColor.black && piece.type != PieceType.kernel) {
          if (pos == state.whiteKernelKidnapper) {
            whiteKidnapperPos = pos;
          }
        }
      }

      // Si Negro tiene secuestrado al Kernel Blanco
      if (whiteKidnapperPos != null) {
        // Bono masivo por acercar al Kernel Blanco secuestrado a la base de Negro (Y = 0)
        score += (7 - whiteKidnapperPos.y) * 80.0;
        if (whiteKidnapperPos.y == 0) score += 3000.0; // ¡Ganamos partida!
      }

      // Si Blanco tiene secuestrado al Kernel Negro
      if (blackKidnapperPos != null) {
        // Penalización masiva si el Kernel Negro secuestrado se acerca a la base blanca (Y = 7)
        score -= blackKidnapperPos.y * 80.0;
        if (blackKidnapperPos.y == 7) score -= 3000.0; // ¡Perdemos partida!
      }
    }

    return score;
  }

  // --- AUXILIAR SIMULATION AND UTILITIES ---

  static double _getPieceValue(PieceType type) {
    switch (type) {
      case PieceType.kernel:
        return 1000.0;
      case PieceType.matrix:
        return 9.0;
      case PieceType.daemon:
        return 5.5;
      case PieceType.worm:
        return 3.5;
      case PieceType.script:
        return 1.5;
      case PieceType.firewall:
        return 2.0;
    }
  }

  static Board _simulateMove(Board board, Position from, Position to) {
    final currentPieces = Map<Position, Piece>.from(board.pieces);
    var piece = currentPieces.remove(from);

    if (piece != null) {
      // Inversión de Script
      if (piece.type == PieceType.script) {
        if ((piece.scriptDir == 1 && to.y == 7) || (piece.scriptDir == -1 && to.y == 0)) {
          piece = piece.copyWith(scriptDir: piece.scriptDir * -1);
        }
      }
      currentPieces[to] = piece;
    }
    return Board(pieces: currentPieces);
  }

  static Board _simulateGhost(Board board, Position from, Position to) {
    final currentPieces = Map<Position, Piece>.from(board.pieces);
    final daemon = currentPieces.remove(from);
    if (daemon != null) {
      currentPieces[to] = daemon.copyWith(hasUsedGhost: true);
    }
    return Board(pieces: currentPieces);
  }
}
