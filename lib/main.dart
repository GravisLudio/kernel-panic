import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/board_view.dart';
import 'providers/game_provider.dart';
import 'models/piece.dart';
import 'models/game_state.dart';
import 'views/instructions_view.dart';

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
                        onPressed: () => _showGameModeSelection(context, ref, GameMode.assassination),
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
                        onPressed: () => _showGameModeSelection(context, ref, GameMode.kidnapping),
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
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const InstructionsScreen()),
                          );
                        },
                        icon: const Icon(Icons.menu_book, size: 18),
                        label: const Text(
                          'MANUAL DE OPERACIONES',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF161B22),
                          foregroundColor: Colors.greenAccent,
                          side: const BorderSide(color: Colors.greenAccent, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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

  void _showGameModeSelection(BuildContext context, WidgetRef ref, GameMode mode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1117),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        side: BorderSide(color: Colors.greenAccent, width: 1.5),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                mode == GameMode.assassination ? 'ENLACE: MODO ASESINATO' : 'ENLACE: CAPTURA Y EXTRACCIÓN',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'SELECCIONAR PROTOCOLO DE CONEXIÓN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  letterSpacing: 1.0,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 24),
              
              // PVP Local
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(gameProvider.notifier).setGameMode(mode, isSoloMode: false);
                  Navigator.pop(context); // cerrar bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
                icon: const Icon(Icons.compare_arrows),
                label: const Text('RED LOCAL (PVP EN UN DISPOSITIVO)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF161B22),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              
              // IA Solo Match
              ElevatedButton.icon(
                onPressed: () {
                  _showIASelector(context, ref, mode);
                },
                icon: const Icon(Icons.android),
                label: const Text('SISTEMA SOLITARIO (VS CORTAFUEGOS IA)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF161B22),
                  foregroundColor: Colors.greenAccent,
                  side: const BorderSide(color: Colors.greenAccent, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              
              // Multiplayer
              ElevatedButton.icon(
                onPressed: () {
                  _showOnlineSelector(context, ref, mode);
                },
                icon: const Icon(Icons.wifi),
                label: const Text('CONEXIÓN REMOTA (2 DISPOSITIVOS)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF161B22),
                  foregroundColor: Colors.cyanAccent,
                  side: const BorderSide(color: Colors.cyanAccent, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showIASelector(BuildContext context, WidgetRef ref, GameMode mode) {
    Navigator.pop(context); // cerrar bottom sheet anterior
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1117),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        side: BorderSide(color: Colors.greenAccent, width: 1.5),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'DIFICULTAD DEL CORTAFUEGOS IA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(gameProvider.notifier).setGameMode(mode, isSoloMode: true, botDifficulty: 1);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GameScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.2),
                        foregroundColor: Colors.greenAccent,
                        side: const BorderSide(color: Colors.greenAccent, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('FÁCIL', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(gameProvider.notifier).setGameMode(mode, isSoloMode: true, botDifficulty: 2);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GameScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.withOpacity(0.2),
                        foregroundColor: Colors.amberAccent,
                        side: const BorderSide(color: Colors.amberAccent, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('MEDIO', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(gameProvider.notifier).setGameMode(mode, isSoloMode: true, botDifficulty: 3);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GameScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('DIFÍCIL', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOnlineSelector(BuildContext context, WidgetRef ref, GameMode mode) {
    Navigator.pop(context); // cerrar bottom sheet anterior
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1117),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        side: BorderSide(color: Colors.cyanAccent, width: 1.5),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'CONEXIÓN REMOTA (ONLINE)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
                  );
                  await ref.read(gameProvider.notifier).createOnlineMatch(mode);
                  Navigator.pop(context); // cerrar loader
                  
                  if (context.mounted) {
                    _showWaitingRoomDialog(context, ref, mode);
                  }
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('CREAR CANAL (HOST)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent.withOpacity(0.1),
                  foregroundColor: Colors.cyanAccent,
                  side: const BorderSide(color: Colors.cyanAccent, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _showJoinRoomDialog(context, ref, mode);
                },
                icon: const Icon(Icons.login),
                label: const Text('UNIRSE A CANAL (CLIENTE)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF161B22),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWaitingRoomDialog(BuildContext context, WidgetRef ref, GameMode mode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final gameState = ref.watch(gameProvider);
            if (gameState.opponentPresent) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pop(context); // cerrar este diálogo
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              });
            }
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1117),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(color: Colors.greenAccent, width: 1.5),
              ),
              title: const Text(
                'ESPERANDO CONEXIÓN DEL INTRUSO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 16,
                  fontFamily: 'monospace',
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'COMPARTE EL CÓDIGO DE ENLACE:',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      gameState.matchCode ?? '...',
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8.0,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(color: Colors.greenAccent),
                  const SizedBox(height: 16),
                  const Text(
                    'ESTABLECIENDO CONEXIÓN REMOTA...',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'monospace'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ref.read(gameProvider.notifier).disconnectOnlineMatch();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'CANCELAR ENLACE',
                    style: TextStyle(color: Colors.redAccent, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showJoinRoomDialog(BuildContext context, WidgetRef ref, GameMode mode) {
    final controller = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1117),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(color: Colors.cyanAccent, width: 1.5),
              ),
              title: const Text(
                'CONEXIÓN REMOTA (CLIENTE)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 16,
                  fontFamily: 'monospace',
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'INGRESA EL CÓDIGO DE ENLACE DE 4 DÍGITOS:',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6.0,
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '0000',
                      hintStyle: TextStyle(color: Colors.cyanAccent.withOpacity(0.3)),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyanAccent),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent, width: 2),
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ],
                  if (isLoading) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(color: Colors.cyanAccent),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    'CANCELAR',
                    style: TextStyle(color: Colors.grey, fontFamily: 'monospace'),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final code = controller.text.trim();
                          if (code.length != 4) {
                            setState(() {
                              errorMessage = 'EL CÓDIGO DEBE SER DE 4 DÍGITOS';
                            });
                            return;
                          }
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });
                          
                          final success = await ref.read(gameProvider.notifier).joinOnlineMatch(code);
                          
                          if (success) {
                            Navigator.pop(context); // cerrar diálogo de unirse
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const GameScreen()),
                            );
                          } else {
                            setState(() {
                              isLoading = false;
                              errorMessage = 'SALA LLENA, EN JUEGO O INEXISTENTE';
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                    foregroundColor: Colors.cyanAccent,
                    side: const BorderSide(color: Colors.cyanAccent, width: 1),
                  ),
                  child: const Text(
                    'CONECTAR',
                    style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _GameScreenContent();
  }
}

class _GameScreenContent extends ConsumerWidget {
  const _GameScreenContent();

  void _showResetConfirmation(BuildContext context, WidgetRef ref, GameState gameState) {
    final isMultiplayer = gameState.isMultiplayer;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D1117),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: isMultiplayer ? Colors.cyanAccent : Colors.redAccent,
            width: 1.5,
          ),
        ),
        title: Row(
          children: [
            Icon(
              isMultiplayer ? Icons.power_settings_new : Icons.warning_amber_rounded,
              color: isMultiplayer ? Colors.cyanAccent : Colors.redAccent,
            ),
            const SizedBox(width: 8),
            Text(
              isMultiplayer ? 'DESCONECTAR' : 'REINICIAR SISTEMA',
              style: TextStyle(
                color: isMultiplayer ? Colors.cyanAccent : Colors.redAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 18,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        content: Text(
          isMultiplayer
              ? '¿Confirmar reinicio de red?\nSe desconectará del canal y volverá al menú principal.'
              : '¿Confirmar reinicio?\nSe perderá todo el progreso actual del tablero.',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'monospace',
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCELAR',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (isMultiplayer) {
                ref.read(gameProvider.notifier).disconnectOnlineMatch();
                Navigator.pop(context); // pop dialog
                Navigator.pop(context); // pop GameScreen
              } else {
                ref.read(gameProvider.notifier).setGameMode(gameState.gameMode);
                Navigator.pop(context); // pop dialog
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: (isMultiplayer ? Colors.cyanAccent : Colors.redAccent).withOpacity(0.2),
              foregroundColor: isMultiplayer ? Colors.cyanAccent : Colors.redAccent,
              side: BorderSide(color: isMultiplayer ? Colors.cyanAccent : Colors.redAccent, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            child: const Text(
              'CONFIRMAR',
              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (gameState.isMultiplayer) {
          ref.read(gameProvider.notifier).disconnectOnlineMatch();
        }
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'KERNEL PANIC',
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.greenAccent),
            onPressed: () {
              if (gameState.isMultiplayer) {
                ref.read(gameProvider.notifier).disconnectOnlineMatch();
              }
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                gameState.isMultiplayer ? Icons.power_settings_new : Icons.refresh,
                color: gameState.isMultiplayer ? Colors.cyanAccent : Colors.redAccent,
              ),
              tooltip: gameState.isMultiplayer ? 'Desconectar partida' : 'Reiniciar partida',
              onPressed: () {
                _showResetConfirmation(context, ref, gameState);
              },
            ),
          ],
        ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(), // Prevent vertical scrolling completely to keep it fully compact
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 6),
                  
                  // TABLERO DE JUEGO (Tablero estático y compacto para caber en una sola pantalla)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320, maxHeight: 320),
                    child: const BoardView(),
                  ),
                  const SizedBox(height: 6),
                  
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

    final showButtons = isMyTurn && gameState.winner == null;

    return Container(
      padding: isMyTurn 
          ? const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0)
          : const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
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
              fontSize: 12, 
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          if (showButtons) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 6.0,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: (!isOverclockUsed || gameState.isOverclockActive) ? () {
                    ref.read(gameProvider.notifier).toggleOverclock();
                  } : null,
                  icon: const Icon(Icons.speed, size: 14),
                  label: Text(
                    gameState.isOverclockActive 
                        ? 'OVERCLOCK ACTIVO' 
                        : isOverclockUsed 
                            ? 'OVERCLOCK USADO' 
                            : 'Overclock',
                    style: const TextStyle(fontSize: 10),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gameState.isOverclockActive 
                        ? Colors.greenAccent 
                        : const Color(0xFF1E2D3D),
                    disabledBackgroundColor: Colors.transparent,
                    disabledForegroundColor: Colors.grey.withOpacity(0.3),
                    foregroundColor: gameState.isOverclockActive ? Colors.black : Colors.amberAccent,
                    side: !gameState.isOverclockActive && !isOverclockUsed 
                        ? const BorderSide(color: Colors.amberAccent, width: 0.5) 
                        : null,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(gameProvider.notifier).toggleGhostMode();
                  },
                  icon: const Icon(Icons.my_location, size: 14),
                  label: Text(
                    gameState.isGhostTargeting 
                        ? 'APUNTANDO...' 
                        : 'Usar Ghost',
                    style: const TextStyle(fontSize: 10),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gameState.isGhostTargeting 
                        ? Colors.purpleAccent 
                        : const Color(0xFF1E2D3D),
                    disabledBackgroundColor: Colors.transparent,
                    disabledForegroundColor: Colors.grey.withOpacity(0.3),
                    foregroundColor: gameState.isGhostTargeting ? Colors.white : Colors.purpleAccent,
                    side: !gameState.isGhostTargeting 
                        ? const BorderSide(color: Colors.purpleAccent, width: 0.5) 
                        : null,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
