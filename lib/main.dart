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
    
    String statusText = "";
    Color statusColor = Colors.white;

    if (gameState.winner != null) {
      statusText = "¡VICTORIA: ${gameState.winner!.name.toUpperCase()}!";
      statusColor = Colors.greenAccent;
    } else if (gameState.isKernelInDanger) {
      statusText = "¡ALERTA CRÍTICA: KERNEL EXPUESTO!\n(Tienes 1 turno para neutralizar la amenaza)";
      statusColor = Colors.redAccent;
    } else if (gameState.gameMode == GameMode.kidnapping &&
        (gameState.whiteKernelKidnapper != null || gameState.blackKernelKidnapper != null)) {
      if (gameState.whiteKernelKidnapper != null && gameState.blackKernelKidnapper != null) {
        statusText = "¡AMBOS KERNELS SECUESTRADOS!\n¡El primero en entregar el suyo en su base gana!";
        statusColor = Colors.orangeAccent;
      } else if (gameState.whiteKernelKidnapper != null) {
        statusText = "¡KERNEL BLANCO SECUESTRADO!\n¡El secuestrador negro intenta escapar!";
        statusColor = Colors.redAccent;
      } else {
        statusText = "¡KERNEL NEGRO SECUESTRADO!\n¡El secuestrador blanco intenta escapar!";
        statusColor = Colors.cyanAccent;
      }
    } else {
      statusText = gameState.currentTurn == PieceColor.white ? "Turno: BLANCAS" : "Turno: NEGRAS";
      statusColor = gameState.currentTurn == PieceColor.white ? Colors.white : Colors.grey;
    }

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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  statusText,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: statusColor, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
                  child: const BoardView(),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16.0,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(gameProvider.notifier).state = GameState.initial(mode: gameState.gameMode);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reiniciar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E2D3D),
                        foregroundColor: Colors.greenAccent,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(gameProvider.notifier).toggleOverclock();
                      },
                      icon: const Icon(Icons.speed),
                      label: Text(gameState.isOverclockActive ? 'OVERCLOCK ACTIVO' : 'Activar Overclock'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gameState.isOverclockActive ? Colors.greenAccent : const Color(0xFF1E2D3D),
                        foregroundColor: gameState.isOverclockActive ? Colors.black : Colors.amberAccent,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(gameProvider.notifier).toggleGhostMode();
                      },
                      icon: const Icon(Icons.my_location),
                      label: Text(gameState.isGhostTargeting ? 'APUNTANDO...' : 'Usar Ghost'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gameState.isGhostTargeting ? Colors.purpleAccent : const Color(0xFF1E2D3D),
                        foregroundColor: gameState.isGhostTargeting ? Colors.white : Colors.purpleAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
