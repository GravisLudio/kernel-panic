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
          backgroundColor: Color(0xFF161B22),
          centerTitle: true,
        ),
      ),
      home: const GameScreen(),
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
    } else if (gameState.gameMode == GameMode.kidnapping && gameState.kidnapperPosition != null) {
      statusText = "¡KERNEL SECUESTRADO!\n(Detén al secuestrador antes de que escape)";
      statusColor = Colors.orangeAccent;
    } else {
      statusText = gameState.currentTurn == PieceColor.white ? "Turno: BLANCAS" : "Turno: NEGRAS";
      statusColor = gameState.currentTurn == PieceColor.white ? Colors.white : Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('KERNEL PANIC', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
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
                        ref.read(gameProvider.notifier).state = GameState.initial();
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
