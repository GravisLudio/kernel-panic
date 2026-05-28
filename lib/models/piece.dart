enum PieceType { kernel, matrix, daemon, script, firewall, worm }
enum PieceColor { white, black }

class Piece {
  final String id;
  final PieceType type;
  final PieceColor color;
  
  // Habilidad especial 'Ghost' para la pieza Daemon (Caballo)
  final bool hasGhost;
  final bool hasUsedGhost;
  
  // Dirección actual para el Script (1 o -1). Se invierte al rebotar.
  final int scriptDir;
  
  // Usos restantes de la habilidad de salto (ej. Worm inicia con 2).
  final int jumpsRemaining;

  const Piece({
    required this.id,
    required this.type,
    required this.color,
    this.hasGhost = false, 
    this.hasUsedGhost = false,
    this.scriptDir = 1, 
    this.jumpsRemaining = 2,
  });

  Piece copyWith({
    String? id,
    PieceType? type,
    PieceColor? color,
    bool? hasGhost,
    bool? hasUsedGhost,
    int? scriptDir,
    int? jumpsRemaining,
  }) {
    return Piece(
      id: id ?? this.id,
      type: type ?? this.type,
      color: color ?? this.color,
      hasGhost: hasGhost ?? this.hasGhost,
      hasUsedGhost: hasUsedGhost ?? this.hasUsedGhost,
      scriptDir: scriptDir ?? this.scriptDir,
      jumpsRemaining: jumpsRemaining ?? this.jumpsRemaining,
    );
  }
}
