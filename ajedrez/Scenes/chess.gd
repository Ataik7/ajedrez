extends Sprite2D

# --- CONFIGURACIÓN ---
@onready var marker_init: Marker2D = $MarkerInit
@onready var marker_fin: Marker2D = $MarkerFin

@export var tamano_pieza : float = 0.75
@export var ajuste_altura : float = -6.0

const BOARD_SIZE = 8
const TEXTURE_HOLDER = preload("uid://dii7eldo2i30")

# Texturas
const B_BISHOP = preload("uid://cysffjfe1h2s0")
const B_KING = preload("uid://b6usr5pro2tmv")
const B_KNIGHT = preload("uid://b8varfok64wfy")
const B_PAWN = preload("uid://bec32ampjjrqn")
const B_QUEEN = preload("uid://b7g4re3yxiuff")
const B_ROOK = preload("uid://bxrrbqinas31h")
const W_BISHOP = preload("uid://bh11p8slr2itk")
const W_KING = preload("uid://bmtuo7dclwvxc")
const W_KNIGHT = preload("uid://cs54h66hvupwj")
const W_PAWN = preload("uid://pg5uwqxvo08m")
const W_QUEEN = preload("uid://dog5vvsgxdw0r")
const W_ROOK = preload("uid://dfjihaicpkbir")

@onready var pieces: Node2D = $Pieces

var board : Array
var debug_rect : Rect2 

func _ready() -> void:
	pieces.y_sort_enabled = true
	GameState.reset_game()
	
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
	
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		var mouse_pos = to_local(get_global_mouse_position())
		
		var min_x = marker_init.position.x
		var max_x = marker_fin.position.x
		var min_y = marker_init.position.y
		var max_y = marker_fin.position.y
		
		if mouse_pos.x < min_x or mouse_pos.x > max_x or mouse_pos.y < min_y or mouse_pos.y > max_y:
			return 

		var size_x = (max_x - min_x) / BOARD_SIZE
		var size_y = (max_y - min_y) / BOARD_SIZE
		
		var grid_x = floor((mouse_pos.x - min_x) / size_x)
		var visual_row = floor((mouse_pos.y - min_y) / size_y)
		var grid_y = (BOARD_SIZE - 1) - visual_row
		
		if grid_x < 0 or grid_x >= BOARD_SIZE or grid_y < 0 or grid_y >= BOARD_SIZE:
			return

		# --- CORRECCIÓN AQUÍ: Usamos int() ---
		var pieza_clicada = board[int(grid_y)][int(grid_x)]
		
		# CASO A: INTENTO SELECCIONAR
		if GameState.selected_piece == Vector2(-1, -1):
			if pieza_clicada == 0: return
			
			if GameState.is_white_turn and pieza_clicada < 0:
				print("🚫 Turno de BLANCAS")
				return
			if not GameState.is_white_turn and pieza_clicada > 0:
				print("🚫 Turno de NEGRAS")
				return
				
			GameState.selected_piece = Vector2(grid_x, grid_y)
			print("Seleccionada: ", GameState.selected_piece)
			actualizar_debug(grid_x, visual_row, size_x, size_y)
			
		# CASO B: INTENTO MOVER
		else:
			if (GameState.is_white_turn and pieza_clicada > 0) or (not GameState.is_white_turn and pieza_clicada < 0):
				GameState.selected_piece = Vector2(grid_x, grid_y)
				actualizar_debug(grid_x, visual_row, size_x, size_y)
				return
			
			# JUEZ
			var es_legal = MoveCalculator.es_movimiento_valido(board, GameState.selected_piece, Vector2(grid_x, grid_y))
			
			if es_legal == false:
				print("🚫 Movimiento ilegal")
				return

			var pos_origen = GameState.selected_piece
			# Convertimos a INT para leer el array
			var pieza_a_mover = board[int(pos_origen.y)][int(pos_origen.x)]
			
			# Convertimos a INT para escribir en el array
			board[int(grid_y)][int(grid_x)] = pieza_a_mover
			board[int(pos_origen.y)][int(pos_origen.x)] = 0
			
			GameState.selected_piece = Vector2(-1, -1)
			GameState.change_turn() 
			
			debug_rect = Rect2(0,0,0,0)
			queue_redraw()
			display_board()

func actualizar_debug(gx, visual_r, sx, sy):
	var min_x = marker_init.position.x
	var min_y = marker_init.position.y
	var draw_x = min_x + (gx * sx)
	var draw_y = min_y + (visual_r * sy)
	debug_rect = Rect2(draw_x, draw_y, sx, sy)
	queue_redraw()

func _draw():
	if debug_rect.size.x > 0:
		draw_rect(debug_rect, Color(1, 1, 0, 0.5), true)
		draw_rect(debug_rect, Color(1, 0, 0, 1), false, 2.0)

func display_board():
	for child in pieces.get_children():
		child.queue_free()
	
	var ancho_total = marker_fin.position.x - marker_init.position.x
	var alto_total = marker_fin.position.y - marker_init.position.y
	var size_x = ancho_total / BOARD_SIZE
	var size_y = alto_total / BOARD_SIZE
	var centro_x = size_x / 2
	var centro_y = size_y / 2

	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
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
