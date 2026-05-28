import 'package:flutter/material.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MANUAL DE OPERACIONES',
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.greenAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado Terminal
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SYSTEM MANUAL v1.2.0 // GRAVIS LUDIO',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Bienvenido al centro de ciberseguridad táctica. A continuación se detallan las directivas de red y las especificaciones de cada elemento de software disponible.',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sección 1: Conceptos Básicos
              _buildCategoryTile(
                title: '🌐 CONCEPTOS BÁSICOS DE RED',
                icon: Icons.lan,
                color: Colors.cyanAccent,
                children: [
                  _buildInstructionItem(
                    title: 'Turnos y Operaciones',
                    description: 'El juego se desarrolla por turnos alternados entre el atacante (Negras) y el defensor (Blancas). Puedes mover tus piezas arrastrándolas o seleccionándolas para ver sus casillas disponibles.',
                  ),
                  _buildInstructionItem(
                    title: 'Habilidad Overclock',
                    description: 'Cada jugador dispone de 1 uso de Overclock por partida. Al activarlo, el sistema te otorga un turno extra inmediato consecutivo para realizar ataques sorpresa o defensas de emergencia.',
                  ),
                  _buildInstructionItem(
                    title: 'Zona Root (Servidores Centrales)',
                    description: 'Las casillas púrpuras en el centro de las primeras filas de cada jugador. Cualquier pieza aliada ubicada en su Zona Root recibe un "Network Shield", haciéndola completamente inmune a ataques Ghost de Daemons enemigos.',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Sección 2: Modos de Juego
              _buildCategoryTile(
                title: '🗡️ MODOS DE JUEGO',
                icon: Icons.games,
                color: Colors.amberAccent,
                children: [
                  _buildInstructionItem(
                    title: 'Modo Asesinato',
                    description: 'El objetivo es destruir el Kernel enemigo o proteger el tuyo. Si tu Kernel es capturado por una pieza enemiga, se activará una "Alerta Crítica". Tienes exactamente 1 turno para capturar a la pieza atacante y salvar tu Kernel; de lo contrario, el oponente gana la partida automáticamente.',
                  ),
                  _buildInstructionItem(
                    title: 'Modo Captura y Extracción',
                    description: 'Un modo de juego de alta intensidad. El objetivo es secuestrar al Kernel enemigo (capturándolo) y llevarlo con tu pieza secuestradora hasta tu propia primera fila (Fila 7 para Blancas, Fila 0 para Negras).\n\n'
                        '• Capturar al secuestrador enemigo libera a tu Kernel, haciéndolo reaparecer seguro cerca de su base.\n'
                        '• ¡Si capturas al secuestrador, además secuestras inmediatamente al Kernel del oponente!\n'
                        '• Ambos jugadores pueden tener al Kernel enemigo secuestrado a la vez; el primero en extraerlo gana.',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Sección 3: Directorio de Piezas
              _buildCategoryTile(
                title: '👾 DIRECTORIO DE PIEZAS (SOFTWARE)',
                icon: Icons.adb,
                color: Colors.greenAccent,
                children: [
                  _buildPieceItem(
                    name: 'Kernel (Núcleo)',
                    pieceIcon: Icons.coronavirus,
                    color: Colors.redAccent,
                    description: 'La unidad crítica de tu red (equivalente al Rey).\n'
                        '• Movimiento: Se mueve 1 casilla en cualquier dirección.\n'
                        '• Salto Cortafuegos: Puede moverse 2 casillas en dirección ortogonal, pero únicamente si el camino está libre (si tiene una pieza aliada o enemiga justo en frente, se bloquea el salto).',
                  ),
                  _buildPieceItem(
                    name: 'Matrix (Supercomputadora)',
                    pieceIcon: Icons.diamond,
                    color: Colors.cyanAccent,
                    description: 'La unidad más potente en términos de movilidad (equivalente a la Reina).\n'
                        '• Movimiento: Puede deslizarse cualquier cantidad de casillas libres en dirección ortogonal o diagonal.',
                  ),
                  _buildPieceItem(
                    name: 'Daemon (Proceso en Segundo Plano)',
                    pieceIcon: Icons.adb,
                    color: Colors.purpleAccent,
                    description: 'Unidad de infiltración ágil (equivalente al Caballo).\n'
                        '• Movimiento: Salto en forma de L clásica.\n'
                        '• Habilidad Ghost: Una vez por partida, el Daemon puede teletransportarse y destruir a distancia a cualquier pieza enemiga, sin importar obstáculos. No puede usar Ghost para capturar Kernels, Firewalls, ni piezas protegidas en la Zona Root enemiga.',
                  ),
                  _buildPieceItem(
                    name: 'Script (Subproceso Ligero)',
                    pieceIcon: Icons.code,
                    color: Colors.blueAccent,
                    description: 'Unidad básica de avance (equivalente al Peón).\n'
                        '• Movimiento: Se mueve 1 casilla hacia adelante o hacia los lados (solo a casillas vacías). Captura en diagonal hacia adelante.\n'
                        '• Rebote de Red: Al llegar al final del tablero, cambia de dirección y empieza a avanzar hacia el lado contrario.\n'
                        '• Zona Root: Al iniciar o estar en su propia Zona Root, puede moverse y capturar también hacia atrás (retroceso).',
                  ),
                  _buildPieceItem(
                    name: 'Firewall (Cortafuegos)',
                    pieceIcon: Icons.security,
                    color: Colors.orangeAccent,
                    description: 'Unidad de defensa pesada (equivalente a la Torre).\n'
                        '• Movimiento: Se desliza cualquier cantidad de casillas libres en dirección ortogonal (líneas rectas).',
                  ),
                  _buildPieceItem(
                    name: 'Worm (Gusano de Red)',
                    pieceIcon: Icons.bug_report,
                    color: Colors.lightGreenAccent,
                    description: 'Unidad de infiltración lineal (equivalente al Alfil).\n'
                        '• Movimiento: Se desliza cualquier cantidad de casillas libres en dirección diagonal.\n'
                        '• Salto de Nodo: Dispone de 1 carga para saltar sobre una única pieza en su diagonal de movimiento para continuar su deslizamiento o capturar la pieza inmediatamente detrás de ella.',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Botón de Volver
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2D3D),
                  foregroundColor: Colors.greenAccent,
                  side: const BorderSide(color: Colors.greenAccent, width: 1.0),
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
                child: const Text(
                  'ENTENDIDO // VOLVER AL MENÚ',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: color.withOpacity(0.3), width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Theme(
        data: ThemeData.dark().copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Icon(icon, color: color),
          title: Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 1.0,
            ),
          ),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: children,
        ),
      ),
    );
  }

  Widget _buildInstructionItem({
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.chevron_right, color: Colors.greenAccent, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Text(
              description,
              style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieceItem({
    required String name,
    required IconData pieceIcon,
    required Color color,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              border: Border.all(color: color.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(pieceIcon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
