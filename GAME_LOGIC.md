# Kernel Panic - Game Logic Summary

Este documento recopila todas las reglas, movimientos y lógicas implementadas en la versión actual (MVP local) para tener un punto de referencia sólido y evitar divagar o olvidar cómo funcionan las piezas y habilidades.

## 1. El Tablero y las Zonas
- Tablero de 8x8.
- Casillas normales (negro/azul oscuro).
- **Root Zone (Zona Root):** Casilla 4x4 en el centro del tablero. Otorga "Network Shield" (Inmunidad contra capturas externas, específicamente contra la habilidad Ghost).

## 2. Movimiento de las Piezas

### Kernel (Rey)
- **Normal:** 1 casilla en cualquier dirección (ortogonal o diagonal).
- **Salto (Firewall Bypass):** Puede moverse 2 casillas en línea recta (solo de forma ortogonal, no diagonal).

### Matrix (Reina)
- **Normal:** Cualquier número de casillas libres en cualquier dirección (ortogonal o diagonal).

### Daemon (Caballo + Habilidad Especial)
- **Normal:** Movimiento en "L" clásico (2 casillas en una dirección ortogonal y 1 en perpendicular). Salta sobre otras piezas en su trayecto.
- **Habilidad Especial - "Ghost" (Francotirador/Teletransporte):** 
  - Solo 1 carga por partida por cada Daemon.
  - Al activarse, permite apuntar a cualquier pieza enemiga válida (que no sea Kernel, Firewall, ni esté en la Root Zone).
  - Al seleccionar un objetivo válido, el Daemon se teletransporta instantáneamente a esa casilla y aniquila la pieza enemiga, perdiendo su carga de Ghost y consumiendo el turno.

### Firewall (Torre)
- **Normal:** Cualquier número de casillas libres solo en direcciones ortogonales (horizontal o vertical).

### Worm (Alfil)
- **Normal:** Cualquier número de casillas libres solo en direcciones diagonales.
- **Salto:** Puede saltar **exactamente una vez** sobre otra pieza (aliada o enemiga) en su trayectoria, con la condición inquebrantable de que la casilla de aterrizaje inmediatamente detrás de la pieza saltada esté **completamente vacía**.

### Script (Peón)
- **Normal:** 1 casilla libre hacia adelante, izquierda o derecha (direcciones ortogonales laterales y frontales).
- **Captura:** Solo captura en **diagonal hacia adelante** a las casillas inmediatamente adyacentes.
- **Rebote en bordes:** Al llegar al fondo (fila 0 o 7, dependiendo del equipo), su dirección frontal se invierte (rebota hacia atrás en lugar de coronar).
- **En la Root Zone:** Obtiene "Multi-threading", que le permite retroceder 1 casilla libre hacia atrás de forma ortogonal.

---

## 3. Condiciones de Victoria y Modos de Juego

Existen dos mecánicas simultáneas de juego en la versión actual, que funcionan en paralelo: "Assassination" y "Kidnapping".

### Assassination (Asesinato / Rescate)
Cuando una pieza enemiga (el Atacante) captura al Kernel, el juego no termina de inmediato.
- **Modo Alarma (Kernel in Danger):** El equipo que perdió a su Kernel tiene exactamente **1 turno de gracia** (rescue turn) para intentar capturar a la pieza Atacante enemiga.
- Si en ese turno capturan al Atacante, el rescate es exitoso y el Kernel activa su **Algoritmo de Reaparición**.
- Si no logran capturar al Atacante en ese turno (ya sea moviendo otra pieza o fallando la captura), se declara el **Jaque Mate** y el equipo del Atacante gana el juego.

### Algoritmo de Reaparición del Kernel
Si el rescate es exitoso, el Kernel revive instantáneamente siguiendo estas prioridades estrictas:
1. **Punto Cero:** Su casilla original de inicio en el tablero (fila 7 para blancas, fila 0 para negras). Solo reaparece aquí si la casilla está completamente libre.
2. **Perímetro Seguro de Origen:** Si su base está ocupada, buscará en las 8 casillas adyacentes a su base original. Para elegirse, la casilla debe estar libre y **no estar bajo amenaza directa** de captura enemiga.
3. **Respawner de Zona de Rescate:** Si ninguna casilla en la zona base es segura/libre, el Kernel buscará en las 8 casillas adyacentes a la posición donde fue capturado (es decir, alrededor de donde está parada la pieza que lo acaba de rescatar). Solo elegirá casillas vacías y que **no estén bajo amenaza enemiga**. Si hay varias opciones válidas, elegirá la que esté físicamente más cerca a su zona base original (calculando la distancia Y).
4. **Fallback Extremo:** Si absolutamente todo lo anterior falla (para evitar bugs fatales), buscará la primera casilla vacía en el tablero y reaparecerá ahí.

### Kidnapping (Secuestro)
- Si una pieza secuestra al Kernel y este no es rescatado en el turno correspondiente, y la partida no se termina por Asesinato normal (por configuración u otros motivos), el Secuestrador debe volver físicamente a su propia fila base con el rehén.
- Si el secuestrador alcanza la fila base de su color con éxito, su equipo gana automáticamente la partida.
- Si la pieza secuestradora es capturada antes de llegar, ocurre lo mismo que en el rescate de asesinato: el Kernel activa su Algoritmo de Reaparición y el juego continúa.

---

## 4. Habilidades Activas Generales

### Overclock
- Disponible 1 vez por partida para cada equipo.
- Al pulsar el botón "Activar Overclock", el jugador en turno obtiene el poder de **hacer dos movimientos seguidos**.
- Una vez finaliza el doble turno, la habilidad se bloquea permanentemente para ese equipo y el turno pasa con normalidad al oponente.
