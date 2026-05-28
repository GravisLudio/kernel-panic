import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/board_view.dart';
import 'providers/game_provider.dart';
import 'models/piece.dart';
import 'models/game_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: KernelPanicApp(),
    ),
  );
}

class KernelPanicApp extends StatelessWidget {
  const KernelPanicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kernel Panic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.greenAccent,
        scaffoldBackgroundColor: const Color(0xFF0D1117), // Estilo hacker/terminal
        appBarTheme: const AppBarTheme(
          backgroundColor: const Color(0xFF161B22),
          centerTitle: true,
        ),
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.coronavirus,
                  size: 80,
                  color: Colors.greenAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'KERNEL PANIC',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.0,
                    shadows: [
                      Shadow(color: Colors.greenAccent, blurRadius: 15),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'SISTEMA DE SEGURIDAD AJEDRECÍSTICO',
                  style: TextStyle(
                    color: Colors.greenAccent.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 1.5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'SELECCIONAR MODO DE JUEGO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(gameProvider.notifier).setGameMode(GameMode.assassination);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const GameScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2D3D),
                          foregroundColor: Colors.greenAccent,
                          side: const BorderSide(color: Colors.greenAccent, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'MODO ASESINATO',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Protege tu Kernel o destruye al atacante',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(gameProvider.notifier).setGameMode(GameMode.kidnapping);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const GameScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2D3D),
                          foregroundColor: Colors.amberAccent,
                          side: const BorderSide(color: Colors.amberAccent, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'CAPTURA Y EXTRACCIÓN',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Secuestra al Kernel enemigo y llévalo a tu base',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  'v1.2.0-STABLE // GRAVIS LUDIO',
                  style: TextStyle(
                    color: Colors.greenAccent.withOpacity(0.4),
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final bool shouldRotateBoard = gameState.currentTurn == PieceColor.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KERNEL PANIC', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.greenAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // PANEL JUGADOR NEGRO (Arriba, rotado 180 grados para quedar de frente al oponente)
                RotatedBox(
                  quarterTurns: 2,
                  child: _PlayerPanel(
                    playerColor: PieceColor.black,
                    gameState: gameState,
                    ref: ref,
                  ),
                ),
                const SizedBox(height: 16),
                
                // TABLERO DE JUEGO (Se rota 180 grados en el turno de las negras para que jueguen cómodamente)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
                  child: RotatedBox(
                    quarterTurns: shouldRotateBoard ? 2 : 0,
                    child: const BoardView(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // PANEL JUGADOR BLANCO (Abajo, vista estándar normal)
                _PlayerPanel(
                  playerColor: PieceColor.white,
                  gameState: gameState,
                  ref: ref,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerPanel extends StatelessWidget {
  final PieceColor playerColor;
  final GameState gameState;
  final WidgetRef ref;

  const _PlayerPanel({
    required this.playerColor,
    required this.gameState,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final isMyTurn = gameState.currentTurn == playerColor;
    final isOverclockUsed = playerColor == PieceColor.white 
        ? gameState.whiteOverclockUsed 
        : gameState.blackOverclockUsed;

    String statusText = "";
    Color statusColor = Colors.white;

    if (gameState.winner != null) {
      statusText = "¡VICTORIA: ${gameState.winner!.name.toUpperCase()}!";
      statusColor = Colors.greenAccent;
    } else if (gameState.isKernelInDanger) {
      statusText = "¡ALERTA CRÍTICA: KERNEL EXPUESTO!\n(Neutralizar la amenaza)";
      statusColor = Colors.redAccent;
    } else if (gameState.gameMode == GameMode.kidnapping &&
        (gameState.whiteKernelKidnapper != null || gameState.blackKernelKidnapper != null)) {
      if (gameState.whiteKernelKidnapper != null && gameState.blackKernelKidnapper != null) {
        statusText = "¡AMBOS KERNELS SECUESTRADOS!\n¡Entrega el tuyo para ganar!";
        statusColor = Colors.orangeAccent;
      } else if (gameState.whiteKernelKidnapper != null) {
        statusText = playerColor == PieceColor.white 
            ? "¡TU KERNEL HA SIDO SECUESTRADO!" 
            : "¡HAS SECUESTRADO EL KERNEL BLANCO!";
        statusColor = playerColor == PieceColor.white ? Colors.redAccent : Colors.cyanAccent;
      } else {
        statusText = playerColor == PieceColor.black 
            ? "¡TU KERNEL HA SIDO SECUESTRADO!" 
            : "¡HAS SECUESTRADO EL KERNEL NEGRO!";
        statusColor = playerColor == PieceColor.black ? Colors.redAccent : Colors.cyanAccent;
      }
    } else {
      statusText = isMyTurn ? "TU TURNO" : "ESPERANDO AL OPONENTE...";
      statusColor = isMyTurn ? Colors.greenAccent : Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isMyTurn ? const Color(0xFF161B22) : Colors.transparent,
        border: Border.all(
          color: isMyTurn ? Colors.greenAccent.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            statusText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: statusColor, 
              fontSize: 14, 
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: isMyTurn ? () {
                  ref.read(gameProvider.notifier).state = GameState.initial(mode: gameState.gameMode);
                } : null,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reiniciar', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2D3D),
                  disabledBackgroundColor: Colors.transparent,
                  disabledForegroundColor: Colors.grey.withOpacity(0.3),
                  foregroundColor: Colors.greenAccent,
                  side: isMyTurn ? const BorderSide(color: Colors.greenAccent, width: 0.5) : null,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
              ElevatedButton.icon(
                onPressed: isMyTurn && !isOverclockUsed ? () {
                  ref.read(gameProvider.notifier).toggleOverclock();
                } : null,
                icon: const Icon(Icons.speed, size: 16),
                label: Text(
                  isMyTurn && gameState.isOverclockActive 
                      ? 'OVERCLOCK ACTIVO' 
                      : isOverclockUsed 
                          ? 'OVERCLOCK USADO' 
                          : 'Activar Overclock',
                  style: const TextStyle(fontSize: 11),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMyTurn && gameState.isOverclockActive 
                      ? Colors.greenAccent 
                      : const Color(0xFF1E2D3D),
                  disabledBackgroundColor: Colors.transparent,
                  disabledForegroundColor: Colors.grey.withOpacity(0.3),
                  foregroundColor: isMyTurn && gameState.isOverclockActive ? Colors.black : Colors.amberAccent,
                  side: isMyTurn && !gameState.isOverclockActive && !isOverclockUsed 
                      ? const BorderSide(color: Colors.amberAccent, width: 0.5) 
                      : null,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
              ElevatedButton.icon(
                onPressed: isMyTurn ? () {
                  ref.read(gameProvider.notifier).toggleGhostMode();
                } : null,
                icon: const Icon(Icons.my_location, size: 16),
                label: Text(
                  isMyTurn && gameState.isGhostTargeting 
                      ? 'APUNTANDO...' 
                      : 'Usar Ghost',
                  style: const TextStyle(fontSize: 11),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMyTurn && gameState.isGhostTargeting 
                      ? Colors.purpleAccent 
                      : const Color(0xFF1E2D3D),
                  disabledBackgroundColor: Colors.transparent,
                  disabledForegroundColor: Colors.grey.withOpacity(0.3),
                  foregroundColor: isMyTurn && gameState.isGhostTargeting ? Colors.white : Colors.purpleAccent,
                  side: isMyTurn && !gameState.isGhostTargeting 
                      ? const BorderSide(color: Colors.purpleAccent, width: 0.5) 
                      : null,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
