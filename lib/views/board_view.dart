import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/position.dart';
import '../models/piece.dart';
import '../providers/game_provider.dart';

class BoardView extends ConsumerWidget {
  const BoardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final board = gameState.board;

    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.black87,
          border: Border.all(color: Colors.greenAccent, width: 2),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
          ),
          itemCount: 64,
          itemBuilder: (context, index) {
            final x = index % 8;
            final y = index ~/ 8;
            final position = Position(x, y);

            final piece = board.getPieceAt(position);
            final isRootZone = board.isRootZone(position);
            
            // Colores tipo ajedrez pero estilo hacker
            final isDarkSquare = (x + y) % 2 == 1;
            final squareColor = isRootZone
                ? Colors.purple.withOpacity(0.3)
                : isDarkSquare
                    ? const Color(0xFF1E2D3D)
                    : const Color(0xFF2D3E50);

            final isGhostTargeting = gameState.isGhostTargeting;
            final ghostSource = gameState.ghostSourcePosition;

            bool isGhostSelectableDaemon = false;
            bool isGhostValidTarget = false;

            if (isGhostTargeting) {
              if (ghostSource == null) {
                if (piece != null && piece.type == PieceType.daemon && piece.color == gameState.currentTurn && !piece.hasUsedGhost) {
                  isGhostSelectableDaemon = true;
                }
              } else {
                if (position == ghostSource) {
                  isGhostSelectableDaemon = true; // El origen seleccionado
                } else if (piece != null && piece.color != gameState.currentTurn && piece.type != PieceType.kernel && piece.type != PieceType.firewall && !isRootZone) {
                  isGhostValidTarget = true;
                }
              }
            }

            final selectedPos = gameState.selectedPosition;
            final isSelected = selectedPos == position;
            final isMoveTarget = selectedPos != null &&
                ref.read(gameProvider.notifier).getValidMovesFor(selectedPos).contains(position);

            Color highlightColor = Colors.transparent;
            
            Widget squareContent = DragTarget<Position>(
              onWillAcceptWithDetails: (details) {
                if (isGhostTargeting) return false; // No se puede arrastrar si estamos apuntando
                return ref.read(gameProvider.notifier).canMovePiece(details.data, position);
              },
              onAcceptWithDetails: (details) {
                ref.read(gameProvider.notifier).movePiece(details.data, position);
              },
              builder: (context, candidateData, rejectedData) {
                if (isGhostTargeting) {
                  if (isGhostSelectableDaemon && ghostSource != null) highlightColor = Colors.greenAccent; // Seleccionado
                  else if (isGhostSelectableDaemon) highlightColor = Colors.purpleAccent; // Seleccionable
                  else if (isGhostValidTarget) highlightColor = Colors.redAccent; // Blanco válido
                  else highlightColor = Colors.transparent; // No marcar nada más
                } else {
                  if (isSelected) highlightColor = Colors.cyanAccent;
                  else if (isMoveTarget && piece != null) highlightColor = Colors.redAccent; // Captura
                  else if (candidateData.isNotEmpty) highlightColor = Colors.greenAccent;
                  else if (rejectedData.isNotEmpty) highlightColor = Colors.redAccent;
                }

                return Container(
                  margin: const EdgeInsets.all(1.0),
                  decoration: BoxDecoration(
                    color: squareColor,
                    border: Border.all(
                      color: highlightColor,
                      width: 2,
                    ),
                  ),
                  child: piece != null
                      ? Draggable<Position>(
                          data: position,
                          maxSimultaneousDrags: (!isGhostTargeting && piece.color == gameState.currentTurn) ? 1 : 0, 
                          feedback: _PieceWidget(piece: piece, size: 50),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _PieceWidget(piece: piece),
                          ),
                          child: _PieceWidget(piece: piece),
                        )
                      : (isMoveTarget
                          ? Center(
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.greenAccent,
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : null),
                );
              },
            );

            return GestureDetector(
              onTap: () {
                if (isGhostTargeting) {
                  ref.read(gameProvider.notifier).useGhostOn(position);
                } else {
                  ref.read(gameProvider.notifier).selectPosition(position);
                }
              },
              child: squareContent,
            );
          },
        ),
      ),
    );
  }
}

class _PieceWidget extends StatelessWidget {
  final Piece piece;
  final double? size;

  const _PieceWidget({required this.piece, this.size});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (piece.type) {
      case PieceType.kernel:
        icon = Icons.coronavirus; 
        break;
      case PieceType.matrix:
        icon = Icons.diamond; 
        break;
      case PieceType.daemon:
        icon = Icons.adb; 
        break;
      case PieceType.script:
        icon = Icons.code; 
        break;
      case PieceType.firewall:
        icon = Icons.security; 
        break;
      case PieceType.worm:
        icon = Icons.bug_report; 
        break;
    }

    final color = piece.color == PieceColor.white ? Colors.white : Colors.black;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Icon(
          icon,
          color: color,
          size: size ?? 30,
          shadows: [
            Shadow(color: piece.color == PieceColor.white ? Colors.black : Colors.white54, blurRadius: 4),
            const Shadow(color: Colors.greenAccent, blurRadius: 10),
          ],
        ),
      ),
    );
  }
}
