import 'board.dart';
import 'piece.dart';
import 'position.dart';

enum GameMode {
  assassination,
  kidnapping,
}

class GameState {
  final Board board;
  final PieceColor currentTurn;
  final GameMode gameMode;
  
  final PieceColor? winner;
  
  // Para Assassination: Si el kernel fue capturado en el turno anterior.
  final bool isKernelInDanger;
  // La posición de la pieza que capturó al Kernel (para que el defensor sepa a quién debe matar).
  final Position? attackerPosition;

  // Para Kidnapping: La posición de la pieza secuestradora.
  final Position? kidnapperPosition;

  // Habilidades Activas
  final bool whiteOverclockUsed;
  final bool blackOverclockUsed;
  final bool isOverclockActive; // Si el turno actual tiene 2 acciones
  final bool isGhostTargeting; // Estado de la UI para seleccionar objetivo
  final Position? ghostSourcePosition; // El Daemon que está apuntando

  const GameState({
    required this.board,
    required this.currentTurn,
    this.gameMode = GameMode.assassination,
    this.winner,
    this.isKernelInDanger = false,
    this.attackerPosition,
    this.kidnapperPosition,
    this.whiteOverclockUsed = false,
    this.blackOverclockUsed = false,
    this.isOverclockActive = false,
    this.isGhostTargeting = false,
    this.ghostSourcePosition,
  });

  factory GameState.initial({GameMode mode = GameMode.assassination}) {
    return GameState(
      board: Board.initial(),
      currentTurn: PieceColor.white,
      gameMode: mode,
    );
  }

  GameState copyWith({
    Board? board,
    PieceColor? currentTurn,
    GameMode? gameMode,
    PieceColor? winner,
    bool? isKernelInDanger,
    Position? attackerPosition,
    Position? kidnapperPosition,
    bool clearAttacker = false,
    bool clearKidnapper = false,
    bool? whiteOverclockUsed,
    bool? blackOverclockUsed,
    bool? isOverclockActive,
    bool? isGhostTargeting,
    Position? ghostSourcePosition,
    bool clearGhostSource = false,
  }) {
    return GameState(
      board: board ?? this.board,
      currentTurn: currentTurn ?? this.currentTurn,
      gameMode: gameMode ?? this.gameMode,
      winner: winner ?? this.winner,
      isKernelInDanger: isKernelInDanger ?? this.isKernelInDanger,
      attackerPosition: clearAttacker ? null : (attackerPosition ?? this.attackerPosition),
      kidnapperPosition: clearKidnapper ? null : (kidnapperPosition ?? this.kidnapperPosition),
      whiteOverclockUsed: whiteOverclockUsed ?? this.whiteOverclockUsed,
      blackOverclockUsed: blackOverclockUsed ?? this.blackOverclockUsed,
      isOverclockActive: isOverclockActive ?? this.isOverclockActive,
      isGhostTargeting: isGhostTargeting ?? this.isGhostTargeting,
      ghostSourcePosition: clearGhostSource ? null : (ghostSourcePosition ?? this.ghostSourcePosition),
    );
  }
}
