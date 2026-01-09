extends Sprite2D

## -----------------------------
## CONFIGURACIÓN
## -----------------------------

# YA NO USAMOS @EXPORT PORQUE NO TE SALE.
# Lo vamos a buscar automáticamente en el _ready
var game_ui: Node2D

@onready var marker_init: Marker2D = $MarkerInit
@onready var marker_fin: Marker2D = $MarkerFin
@onready var pieces: Node2D = $Pieces

@export var tamano_pieza: float = 0.75
@export var ajuste_altura: float = -6.0

const BOARD_SIZE := 8
const TEXTURE_HOLDER = preload("uid://dii7eldo2i30")

## -----------------------------
## TEXTURAS
## -----------------------------
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
var ai_thinking: bool = false
var ai_move_delay: float = 0.8

## -----------------------------
## ESTADO
## -----------------------------
var board: Array = []
var debug_rect: Rect2

## -----------------------------
## READY
## -----------------------------
func _ready() -> void:
	pieces.y_sort_enabled = true
	GameState.reset_game()

	# --- BÚSQUEDA AUTOMÁTICA DE LA UI ---
	# Esto busca en todo el juego un nodo llamado "GameUI"
	game_ui = get_tree().root.find_child("GameUI", true, false)
	
	if game_ui:
		print("✅ CONEXIÓN EXITOSA: He encontrado la UI automáticamente.")
		game_ui.update_turn_text(true)
	else:
		print("❌ ERROR CRÍTICO: No encuentro ningún nodo llamado 'GameUI'.")
		print("Asegúrate de que tu nodo CanvasLayer se llame exactamente 'GameUI'.")
	# ------------------------------------

	# Configuración inicial del tablero
	board.append([4, 2, 3, 5, 6, 3, 2, 4])
	board.append([1, 1, 1, 1, 1, 1, 1, 1])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([-1, -1, -1, -1, -1, -1, -1, -1])
	board.append([-4, -2, -3, -5, -6, -3, -2, -4])

	await get_tree().process_frame
	display_board()

## -----------------------------
## INPUT
## -----------------------------
func _input(event) -> void:
	if GameState.is_ai_turn() or ai_thinking:
		return
	
	if not (event is InputEventMouseButton): return
	if not event.pressed: return
	if event.button_index != MOUSE_BUTTON_LEFT: return

	var mouse_pos = to_local(get_global_mouse_position())
	var min_x = marker_init.position.x
	var max_x = marker_fin.position.x
	var min_y = marker_init.position.y
	var max_y = marker_fin.position.y

	if mouse_pos.x < min_x or mouse_pos.x > max_x: return
	if mouse_pos.y < min_y or mouse_pos.y > max_y: return

	var size_x = (max_x - min_x) / BOARD_SIZE
	var size_y = (max_y - min_y) / BOARD_SIZE
	var grid_x = floori((mouse_pos.x - min_x) / size_x)
	var visual_row = floori((mouse_pos.y - min_y) / size_y)
	var grid_y = (BOARD_SIZE - 1) - visual_row

	if grid_x < 0 or grid_x >= BOARD_SIZE: return
	if grid_y < 0 or grid_y >= BOARD_SIZE: return

	var pieza_clicada = board[grid_y][grid_x]

	# --- SELECCIONAR ---
	if GameState.selected_piece == Vector2(-1, -1):
		if pieza_clicada == 0: return

		if GameState.is_white_turn and pieza_clicada < 0:
			if game_ui: game_ui.show_message("⚠️ Turno de BLANCAS") 
			return
		if not GameState.is_white_turn and pieza_clicada > 0:
			if game_ui: game_ui.show_message("⚠️ Turno de NEGRAS")
			return

		GameState.selected_piece = Vector2(grid_x, grid_y)
		actualizar_debug(grid_x, visual_row, size_x, size_y)
		return

	# --- MOVER ---
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

	# Validar movimiento
	var es_legal = MoveCalculator.es_movimiento_valido(board, GameState.selected_piece, Vector2(grid_x, grid_y), GameState)

	if not es_legal:
		if game_ui: game_ui.show_message("🚫 Movimiento ilegal")
		return

	var pos_origen = GameState.selected_piece
	var pos_destino = Vector2(grid_x, grid_y)
	var pieza_mover = board[pos_origen.y][pos_origen.x]
	var pieza_comida = board[pos_destino.y][pos_destino.x]
	
	var captura_al_paso = false
	if abs(pieza_mover) == 1 and pieza_comida == 0 and pos_origen.x != pos_destino.x:
		captura_al_paso = true
		pieza_comida = board[pos_origen.y][pos_destino.x]

	# Mover en memoria
	board[pos_destino.y][pos_destino.x] = pieza_mover
	board[pos_origen.y][pos_origen.x] = 0
	
	if captura_al_paso:
		board[pos_origen.y][pos_destino.x] = 0

	# Validar Jaque
	if MoveCalculator.esta_en_jaque(board, GameState.is_white_turn):
		if game_ui: game_ui.show_message("🛡️ ¡No puedes ponerte en JAQUE!")
		# Deshacer
		board[pos_origen.y][pos_origen.x] = pieza_mover
		board[pos_destino.y][pos_destino.x] = pieza_comida if not captura_al_paso else 0
		if captura_al_paso: board[pos_origen.y][pos_destino.x] = pieza_comida
		return
		
	# --- PROMOCIÓN AUTOMÁTICA ---
	if abs(pieza_mover) == 1:
		if (pieza_mover > 0 and pos_destino.y == 7) or (pieza_mover < 0 and pos_destino.y == 0):
			if game_ui: game_ui.show_message("✨ ¡PROMOCIÓN!")
			var nueva_reina = 5 if pieza_mover > 0 else -5
			board[pos_destino.y][pos_destino.x] = nueva_reina

	# --- ENROQUE ---
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

	GameState.selected_piece = Vector2(-1, -1)
	GameState.change_turn()
	
	# --- UI: Actualizar texto de turno ---
	if game_ui: game_ui.update_turn_text(GameState.is_white_turn)

	check_game_state()

	debug_rect = Rect2()
	queue_redraw()
	display_board()

## -----------------------------
## IA
## -----------------------------
func _process(_delta: float) -> void:
	if GameState.is_ai_turn() and not ai_thinking:
		ai_thinking = true
		execute_ai_turn()

func execute_ai_turn() -> void:
	if game_ui: game_ui.show_message("🤖 IA Pensando...")
	
	await get_tree().create_timer(ai_move_delay).timeout
	if not AIPlayer:
		ai_thinking = false
		return

	var ai_move = AIPlayer.get_best_move(board, GameState.AI_IS_WHITE)

	if ai_move.is_empty():
		ai_thinking = false
		return

	var from = ai_move["from"]
	var to = ai_move["to"]

	var pos_origen = from
	var pos_destino = to
	var pieza_mover = board[int(pos_origen.y)][int(pos_origen.x)]
	var pieza_comida = board[int(pos_destino.y)][int(pos_destino.x)]
	
	var captura_al_paso = false
	if abs(pieza_mover) == 1 and pieza_comida == 0 and pos_origen.x != pos_destino.x:
		captura_al_paso = true
		pieza_comida = board[int(pos_origen.y)][int(pos_destino.x)]
		board[int(pos_origen.y)][int(pos_destino.x)] = 0

	board[int(pos_destino.y)][int(pos_destino.x)] = pieza_mover
	board[int(pos_origen.y)][int(pos_origen.x)] = 0
	
	if abs(pieza_mover) == 1:
		if (pieza_mover > 0 and pos_destino.y == 7) or (pieza_mover < 0 and pos_destino.y == 0):
			var nueva_reina = 5 if pieza_mover > 0 else -5
			board[int(pos_destino.y)][int(pos_destino.x)] = nueva_reina
	
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
	
	# --- UI: Actualizar texto tras turno IA ---
	if game_ui: game_ui.update_turn_text(GameState.is_white_turn)
	
	check_game_state()
	display_board()
	ai_thinking = false

## -----------------------------
## ESTADO DEL JUEGO
## -----------------------------
func check_game_state() -> void:
	var turno_blancas = GameState.is_white_turn
	var rey_en_peligro = MoveCalculator.esta_en_jaque(board, turno_blancas)
	var tiene_salida = MoveCalculator.hay_movimientos_salvadores(board, turno_blancas)

	if rey_en_peligro:
		if tiene_salida:
			if game_ui: game_ui.show_message("⚠️ ¡JAQUE!") 
		else:
			var winner = "Ganan NEGRAS" if turno_blancas else "Ganan BLANCAS"
			# --- GAME OVER UI ---
			if game_ui:
				game_ui.show_game_over("👑 ¡JAQUE MATE!\n" + winner) 
			
			set_process_input(false)
			set_process(false)
	else:
		if not tiene_salida:
			# --- GAME OVER UI ---
			if game_ui:
				game_ui.show_game_over("🤝 REY AHOGADO\nEmpate")
			
			set_process_input(false)
			set_process(false)

func update_en_passant(from: Vector2i, to: Vector2i, piece: int) -> void:
	if abs(piece) != 1:
		GameState.en_passant_target = Vector2i(-1, -1)
		return
	if abs(to.y - from.y) == 2:
		var target_row: int = (from.y + to.y) / 2
		GameState.en_passant_target = Vector2i(from.x, target_row)
	else:
		GameState.en_passant_target = Vector2i(-1, -1)

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
			if board[i][j] == 0: continue
			var holder = TEXTURE_HOLDER.instantiate()
			pieces.add_child(holder)
			holder.y_sort_enabled = true
			holder.scale = Vector2(tamano_pieza, tamano_pieza)
			var pos_x = marker_init.position.x + (j * size_x) + centro_x
			var fila_visual = (BOARD_SIZE - 1) - i
			var pos_y = marker_init.position.y + (fila_visual * size_y) + centro_y
			holder.position = Vector2(pos_x, pos_y + ajuste_altura)
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
