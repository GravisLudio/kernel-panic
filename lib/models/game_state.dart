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

  // Para Kidnapping: La posición de la pieza secuestradora del Kernel Blanco (pieza negra).
  final Position? whiteKernelKidnapper;
  // Para Kidnapping: La posición de la pieza secuestradora del Kernel Negro (pieza blanca).
  final Position? blackKernelKidnapper;

  // Habilidades Activas
  final bool whiteOverclockUsed;
  final bool blackOverclockUsed;
  final bool isOverclockActive; // Si el turno actual tiene 2 acciones
  final bool isGhostTargeting; // Estado de la UI para seleccionar objetivo
  final Position? ghostSourcePosition; // El Daemon que está apuntando

  // Para selección de pieza
  final Position? selectedPosition;

  const GameState({
    required this.board,
    required this.currentTurn,
    this.gameMode = GameMode.assassination,
    this.winner,
    this.isKernelInDanger = false,
    this.attackerPosition,
    this.whiteKernelKidnapper,
    this.blackKernelKidnapper,
    this.whiteOverclockUsed = false,
    this.blackOverclockUsed = false,
    this.isOverclockActive = false,
    this.isGhostTargeting = false,
    this.ghostSourcePosition,
    this.selectedPosition,
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
    Position? whiteKernelKidnapper,
    Position? blackKernelKidnapper,
    bool clearAttacker = false,
    bool clearWhiteKidnapper = false,
    bool clearBlackKidnapper = false,
    bool? whiteOverclockUsed,
    bool? blackOverclockUsed,
    bool? isOverclockActive,
    bool? isGhostTargeting,
    Position? ghostSourcePosition,
    bool clearGhostSource = false,
    Position? selectedPosition,
    bool clearSelectedPosition = false,
  }) {
    return GameState(
      board: board ?? this.board,
      currentTurn: currentTurn ?? this.currentTurn,
      gameMode: gameMode ?? this.gameMode,
      winner: winner ?? this.winner,
      isKernelInDanger: isKernelInDanger ?? this.isKernelInDanger,
      attackerPosition: clearAttacker ? null : (attackerPosition ?? this.attackerPosition),
      whiteKernelKidnapper: clearWhiteKidnapper ? null : (whiteKernelKidnapper ?? this.whiteKernelKidnapper),
      blackKernelKidnapper: clearBlackKidnapper ? null : (blackKernelKidnapper ?? this.blackKernelKidnapper),
      whiteOverclockUsed: whiteOverclockUsed ?? this.whiteOverclockUsed,
      blackOverclockUsed: blackOverclockUsed ?? this.blackOverclockUsed,
      isOverclockActive: isOverclockActive ?? this.isOverclockActive,
      isGhostTargeting: isGhostTargeting ?? this.isGhostTargeting,
      ghostSourcePosition: clearGhostSource ? null : (ghostSourcePosition ?? this.ghostSourcePosition),
      selectedPosition: clearSelectedPosition ? null : (selectedPosition ?? this.selectedPosition),
    );
  }
}
