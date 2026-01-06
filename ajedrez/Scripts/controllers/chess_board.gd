extends Sprite2D

## -----------------------------
## CONFIGURACIÓN
## -----------------------------

# Marcadores para delimitar tablero, nodo contenedor de piezas y parámetros de tamaño/altura
@onready var marker_init: Marker2D = $MarkerInit
@onready var marker_fin: Marker2D = $MarkerFin
@onready var pieces: Node2D = $Pieces

@export var tamano_pieza: float = 0.75
@export var ajuste_altura: float = -6.0

# Tamaño del tablero y contenedor de texturas reutilizable
const BOARD_SIZE := 8
const TEXTURE_HOLDER = preload("uid://dii7eldo2i30")

## -----------------------------
## TEXTURAS
## -----------------------------

# Preload de todas las texturas de piezas blancas y negras
const B_BISHOP = preload("uid://cysffjfe1h2s0")
const B_KING   = preload("uid://b6usr5pro2tmv")
const B_KNIGHT = preload("uid://b8varfok64wfy")
const B_PAWN   = preload("uid://bec32ampjjrqn")
const B_QUEEN  = preload("uid://b7g4re3yxiuff")
const B_ROOK   = preload("uid://bxrrbqinas31h")

const W_BISHOP = preload("uid://bh11p8slr2itk")
const W_KING   = preload("uid://bmtuo7dclwvxc")
const W_KNIGHT = preload("uid://cs54h66hvupwj")
const W_PAWN   = preload("uid://pg5uwqxvo08m")
const W_QUEEN  = preload("uid://dog5vvsgxdw0r")
const W_ROOK   = preload("uid://dfjihaicpkbir")

## -----------------------------
## IA
## -----------------------------

# Flags de control para IA y retraso de simulación
var ai_thinking: bool = false
var ai_move_delay: float = 0.8

## -----------------------------
## ESTADO
## -----------------------------

# Estado del tablero y rectángulo de debug para mostrar selección
var board: Array = []
var debug_rect: Rect2

## -----------------------------
## READY
## -----------------------------

# Inicializa tablero, contenedor de piezas y estado de juego
func _ready() -> void:
	pieces.y_sort_enabled = true
	GameState.reset_game()

	# Configuración inicial del tablero (8x8)
	board.append([4, 2, 3, 5, 6, 3, 2, 4])
	board.append([1, 1, 1, 1, 1, 1, 1, 1])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([-1, -1, -1, -1, -1, -1, -1, -1])
	board.append([-4, -2, -3, -5, -6, -3, -2, -4])

	await get_tree().process_frame  # Esperar que se procese un frame
	display_board()                 # Mostrar piezas iniciales

## -----------------------------
## INPUT
## -----------------------------

# Maneja la selección y movimiento de piezas con mouse
func _input(event) -> void:
	# Bloquear input si es turno de la IA o si IA está pensando
	if GameState.is_ai_turn() or ai_thinking:
		return
	
	# Filtrar solo clicks izquierdo
	if not (event is InputEventMouseButton):
		return
	if not event.pressed:
		return
	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	var mouse_pos = to_local(get_global_mouse_position())

	# Limitar a área del tablero
	var min_x = marker_init.position.x
	var max_x = marker_fin.position.x
	var min_y = marker_init.position.y
	var max_y = marker_fin.position.y

	if mouse_pos.x < min_x or mouse_pos.x > max_x:
		return
	if mouse_pos.y < min_y or mouse_pos.y > max_y:
		return

	# Obtener coordenadas de celda en el tablero
	var size_x = (max_x - min_x) / BOARD_SIZE
	var size_y = (max_y - min_y) / BOARD_SIZE

	var grid_x = floori((mouse_pos.x - min_x) / size_x)
	var visual_row = floori((mouse_pos.y - min_y) / size_y)
	var grid_y = (BOARD_SIZE - 1) - visual_row

	if grid_x < 0 or grid_x >= BOARD_SIZE:
		return
	if grid_y < 0 or grid_y >= BOARD_SIZE:
		return

	var pieza_clicada = board[grid_y][grid_x]

	# -----------------------------
	# CASO A: SELECCIONAR PIEZA
	# -----------------------------
	
	if GameState.selected_piece == Vector2(-1, -1):
		if pieza_clicada == 0:
			return

		# Validar turno
		if GameState.is_white_turn and pieza_clicada < 0:
			print("🚫 Turno de BLANCAS")
			return
		if not GameState.is_white_turn and pieza_clicada > 0:
			print("🚫 Turno de NEGRAS")
			return

		GameState.selected_piece = Vector2(grid_x, grid_y)
		print("✅ Seleccionada: ", GameState.selected_piece)
		actualizar_debug(grid_x, visual_row, size_x, size_y)
		return

	# -----------------------------
	# CASO B: MOVER PIEZA
	# -----------------------------
	
	if GameState.is_white_turn:
		if pieza_clicada > 0:
			GameState.selected_piece = Vector2(grid_x, grid_y)
			actualizar_debug(grid_x, visual_row, size_x, size_y)
			return
	else:
		if pieza_clicada < 0:
			GameState.selected_piece = Vector2(grid_x, grid_y)
			actualizar_debug(grid_x, visual_row, size_x, size_y)
			return

	# Validar movimiento legal
	# IMPORTANTE: Aquí se pasa GameState. Si MoveCalculator no está actualizado, fallará aquí.
	var es_legal = MoveCalculator.es_movimiento_valido(
		board,
		GameState.selected_piece,
		Vector2(grid_x, grid_y),
		GameState
	)

	if not es_legal:
		print("🚫 Movimiento ilegal")
		return

	# Guardar posiciones y piezas involucradas
	var pos_origen = GameState.selected_piece
	var pos_destino = Vector2(grid_x, grid_y)
	var pieza_mover = board[pos_origen.y][pos_origen.x]
	var pieza_comida = board[pos_destino.y][pos_destino.x]
	
	# Detectar En Passant para comer la pieza correcta
	var captura_al_paso = false
	# Es un peón, se mueve en diagonal, pero la casilla destino está vacía
	if abs(pieza_mover) == 1 and pieza_comida == 0 and pos_origen.x != pos_destino.x:
		captura_al_paso = true
		pieza_comida = board[pos_origen.y][pos_destino.x] # Pieza que está detrás

	# Ejecutar movimiento en memoria
	board[pos_destino.y][pos_destino.x] = pieza_mover
	board[pos_origen.y][pos_origen.x] = 0
	
	if captura_al_paso:
		board[pos_origen.y][pos_destino.x] = 0 # Eliminar peón capturado al paso

	# Validar que no se deje en jaque
	if MoveCalculator.esta_en_jaque(board, GameState.is_white_turn):
		print("🚫 ¡No puedes ponerte en JAQUE!")
		# Deshacer cambios
		board[pos_origen.y][pos_origen.x] = pieza_mover
		board[pos_destino.y][pos_destino.x] = pieza_comida if not captura_al_paso else 0
		if captura_al_paso:
			board[pos_origen.y][pos_destino.x] = pieza_comida # Restaurar peón enemigo
		return

	# --- EJECUTAR MOVIMIENTO ESPECIAL: ENROQUE ---
	# Si el Rey se ha movido 2 casillas, debemos mover la torre también
	if abs(pieza_mover) == 6 and abs(pos_destino.x - pos_origen.x) == 2:
		var rook_y = int(pos_origen.y)
		var rook_x_origen = 7 if pos_destino.x > pos_origen.x else 0
		var rook_x_destino = int(pos_origen.x + 1) if pos_destino.x > pos_origen.x else int(pos_origen.x - 1)
		
		# Mover torre
		var torre = board[rook_y][rook_x_origen]
		board[rook_y][rook_x_destino] = torre
		board[rook_y][rook_x_origen] = 0

	# Reproducir sonido
	if pieza_comida != 0:
		if SFXPlayer: SFXPlayer.play_capture()
	else:
		if SFXPlayer: SFXPlayer.play_move()

	# Actualizar flags de enroque y en passant
	GameState.update_castling_flags(Vector2i(pos_origen), pieza_mover)
	update_en_passant(Vector2i(pos_origen), Vector2i(pos_destino), pieza_mover)

	GameState.selected_piece = Vector2(-1, -1)
	GameState.change_turn()

	# Revisar estado del juego (jaque/mate/ahogado)
	check_game_state()

	debug_rect = Rect2()
	queue_redraw()
	display_board()

## -----------------------------
## IA
## -----------------------------
# Procesa turno de IA
func _process(_delta: float) -> void:
	if GameState.is_ai_turn() and not ai_thinking:
		ai_thinking = true
		execute_ai_turn()

# Ejecuta el turno de la IA
func execute_ai_turn() -> void:
	print("🤖 IA pensando...")
	await get_tree().create_timer(ai_move_delay).timeout
	
	# Aseguramos que AIPlayer existe antes de llamar
	if not AIPlayer:
		print("ERROR: AIPlayer no está definido.")
		ai_thinking = false
		return

	var ai_move = AIPlayer.get_best_move(board, GameState.AI_IS_WHITE)

	if ai_move.is_empty():
		print("❌ IA sin movimientos válidos")
		ai_thinking = false
		return

	var from = ai_move["from"]
	var to = ai_move["to"]

	print("🤖 IA mueve: ", from, " → ", to)

	# Ejecutar movimiento
	var pos_origen = from
	var pos_destino = to
	var pieza_mover = board[int(pos_origen.y)][int(pos_origen.x)]
	var pieza_comida = board[int(pos_destino.y)][int(pos_destino.x)]
	
	# Lógica En Passant para IA
	var captura_al_paso = false
	if abs(pieza_mover) == 1 and pieza_comida == 0 and pos_origen.x != pos_destino.x:
		captura_al_paso = true
		pieza_comida = board[int(pos_origen.y)][int(pos_destino.x)]
		board[int(pos_origen.y)][int(pos_destino.x)] = 0

	board[int(pos_destino.y)][int(pos_destino.x)] = pieza_mover
	board[int(pos_origen.y)][int(pos_origen.x)] = 0
	
	# Lógica Enroque para IA
	if abs(pieza_mover) == 6 and abs(pos_destino.x - pos_origen.x) == 2:
		var rook_y = int(pos_origen.y)
		var rook_x_origen = 7 if pos_destino.x > pos_origen.x else 0
		var rook_x_destino = int(pos_origen.x + 1) if pos_destino.x > pos_origen.x else int(pos_origen.x - 1)
		
		var torre = board[rook_y][rook_x_origen]
		board[rook_y][rook_x_destino] = torre
		board[rook_y][rook_x_origen] = 0

	if pieza_comida != 0:
		if SFXPlayer: SFXPlayer.play_capture()
	else:
		if SFXPlayer: SFXPlayer.play_move()

	GameState.update_castling_flags(Vector2i(pos_origen), pieza_mover)
	update_en_passant(Vector2i(pos_origen), Vector2i(pos_destino), pieza_mover)

	GameState.change_turn()
	check_game_state()
	display_board()

	ai_thinking = false

## -----------------------------
## ESTADO DEL JUEGO
## -----------------------------
# Verifica jaque, mate o ahogado
func check_game_state() -> void:
	var turno_blancas = GameState.is_white_turn
	var rey_en_peligro = MoveCalculator.esta_en_jaque(board, turno_blancas)
	var tiene_salida = MoveCalculator.hay_movimientos_salvadores(board, turno_blancas)

	if rey_en_peligro:
		if tiene_salida:
			print("⚠️ ¡JAQUE!")
		else:
			var winner = "NEGRAS (IA)" if turno_blancas else "BLANCAS (TÚ)"
			print("👑 ¡¡¡JAQUE MATE!!!")
			print("🏆 Ganador: ", winner)

			set_process_input(false)
			set_process(false)
	else:
		if not tiene_salida:
			print("🤝 REY AHOGADO - EMPATE")
			set_process_input(false)
			set_process(false)

## -----------------------------
## EN PASSANT
## -----------------------------
func update_en_passant(from: Vector2i, to: Vector2i, piece: int) -> void:
	if abs(piece) != 1:
		GameState.en_passant_target = Vector2i(-1, -1)
		return

	if abs(to.y - from.y) == 2:
		var target_row: int = (from.y + to.y) / 2
		GameState.en_passant_target = Vector2i(from.x, target_row)
	else:
		GameState.en_passant_target = Vector2i(-1, -1)

## -----------------------------
## DEBUG
## -----------------------------
func actualizar_debug(gx, visual_r, sx, sy) -> void:
	var min_x = marker_init.position.x
	var min_y = marker_init.position.y

	var draw_x = min_x + (gx * sx)
	var draw_y = min_y + (visual_r * sy)

	debug_rect = Rect2(draw_x, draw_y, sx, sy)
	queue_redraw()

func _draw() -> void:
	if debug_rect.size.x > 0:
		draw_rect(debug_rect, Color(1, 1, 0, 0.5), true)
		draw_rect(debug_rect, Color(1, 0, 0, 1), false, 2.0)

## -----------------------------
## DIBUJAR TABLERO
## -----------------------------
# Crea instancias de piezas según board y aplica texturas
func display_board() -> void:
	for child in pieces.get_children():
		child.queue_free()

	var ancho_total = marker_fin.position.x - marker_init.position.x
	var alto_total = marker_fin.position.y - marker_init.position.y

	var size_x = ancho_total / BOARD_SIZE
	var size_y = alto_total / BOARD_SIZE

	var centro_x = size_x / 2
	var centro_y = size_y / 2

	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):
			if board[i][j] == 0:
				continue

			var holder = TEXTURE_HOLDER.instantiate()
			pieces.add_child(holder)

			holder.y_sort_enabled = true
			holder.scale = Vector2(tamano_pieza, tamano_pieza)

			var pos_x = marker_init.position.x + (j * size_x) + centro_x
			var fila_visual = (BOARD_SIZE - 1) - i
			var pos_y = marker_init.position.y + (fila_visual * size_y) + centro_y

			holder.position = Vector2(pos_x, pos_y + ajuste_altura)

			# Asignar textura según pieza
			match board[i][j]:
				-6: holder.texture = B_KING
				-5: holder.texture = B_QUEEN
				-4: holder.texture = B_ROOK
				-3: holder.texture = B_BISHOP
				-2: holder.texture = B_KNIGHT
				-1: holder.texture = B_PAWN
				6: holder.texture = W_KING
				5: holder.texture = W_QUEEN
				4: holder.texture = W_ROOK
				3: holder.texture = W_BISHOP
				2: holder.texture = W_KNIGHT
				1: holder.texture = W_PAWN
