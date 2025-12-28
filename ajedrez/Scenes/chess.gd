extends Sprite2D

# --- CONFIGURACIÓN ---
@onready var marker_init: Marker2D = $MarkerInit
@onready var marker_fin: Marker2D = $MarkerFin

# 1. ESCALA: Bajar esto si se ven gigantes 
@export var tamano_pieza : float = 0.75

# 2. ALTURA: Subir o bajar las piezas sin mover los markers
@export var ajuste_altura : float = -6.0

const BOARD_SIZE = 8
const TEXTURE_HOLDER = preload("uid://dii7eldo2i30")

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
@onready var dots: Node2D = $Dots
@onready var turn: Sprite2D = $Turn

var board : Array
var white : bool
var state : bool
var moves = []
var selected_piece : Vector2
var debug_rect : Rect2 # Variable para guardar el dibujo

func _ready() -> void:
	# Importante: Activar ordenamiento Y para que se tapen bien
	pieces.y_sort_enabled = true
	
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
		
		# --- LÓGICA DE BORDES (FLOOR) ---
		# Usamos esta porque tus markers están en las esquinas del tablero
		var min_x = marker_init.position.x
		var max_x = marker_fin.position.x
		var min_y = marker_init.position.y
		var max_y = marker_fin.position.y
		
		# Verificar si estamos dentro del tablero
		if mouse_pos.x < min_x or mouse_pos.x > max_x or mouse_pos.y < min_y or mouse_pos.y > max_y:
			return

		# Calculamos tamaño de casilla (Total / 8)
		var ancho_total = max_x - min_x
		var alto_total = max_y - min_y
		
		var size_x = ancho_total / BOARD_SIZE
		var size_y = alto_total / BOARD_SIZE
		
		# Fórmulas de Grid
		var grid_x = floor((mouse_pos.x - min_x) / size_x)
		var visual_row = floor((mouse_pos.y - min_y) / size_y)
		var grid_y = (BOARD_SIZE - 1) - visual_row # Invertir Y
		
		# Seguridad
		if grid_x >= 0 and grid_x < BOARD_SIZE and grid_y >= 0 and grid_y < BOARD_SIZE:
			var id = board[grid_y][grid_x]
			print("Clic: ", grid_x, ", ", grid_y, " | ID: ", id)
			
			if id != 0:
				selected_piece = Vector2(grid_x, grid_y)
			
			# --- DIBUJAR DEBUG ---
			var draw_x = min_x + (grid_x * size_x)
			var draw_y = min_y + (visual_row * size_y)
			debug_rect = Rect2(draw_x, draw_y, size_x, size_y)
			queue_redraw()

func _draw():
	# Dibuja un cuadrado amarillo transparente donde hiciste clic
	if debug_rect.size.x > 0:
		draw_rect(debug_rect, Color(1, 1, 0, 0.5), true) # Relleno amarillo
		draw_rect(debug_rect, Color(1, 0, 0, 1), false, 2.0) # Borde rojo

func display_board():
	for child in pieces.get_children():
		child.queue_free()
	
	# Calculamos cuánto mide UNA casilla automáticamente (Ancho Total / 8)
	var ancho_total = marker_fin.position.x - marker_init.position.x
	var alto_total = marker_fin.position.y - marker_init.position.y
	
	var size_x = ancho_total / BOARD_SIZE
	var size_y = alto_total / BOARD_SIZE
	
	# Offset para centrar la pieza (mitad del tamaño de la casilla)
	var centro_x = size_x / 2
	var centro_y = size_y / 2

	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			if board[i][j] == 0: continue
			
			var holder = TEXTURE_HOLDER.instantiate()
			pieces.add_child(holder)
			holder.y_sort_enabled = true
			holder.scale = Vector2(tamano_pieza, tamano_pieza)
			
			# LÓGICA DE POSICIÓN: Origen + (Columna * Tamaño) + Mitad para centrar
			var pos_x = marker_init.position.x + (j * size_x) + centro_x
			
			# Para la Y, invertimos la fila visual porque i=0 (Blancas) están abajo
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
