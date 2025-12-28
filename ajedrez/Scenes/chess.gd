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

func _ready() -> void:
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
		
		# 1. Coordenadas locales y límites (lo que ya tenías)
		var mouse_pos = to_local(get_global_mouse_position())
		var min_x = min(marker_init.position.x, marker_fin.position.x)
		var max_x = max(marker_init.position.x, marker_fin.position.x)
		var min_y = min(marker_init.position.y, marker_fin.position.y)
		var max_y = max(marker_init.position.y, marker_fin.position.y)

		# Si estamos fuera, no hacemos nada
		if mouse_pos.x < min_x or mouse_pos.x > max_x or mouse_pos.y < min_y or mouse_pos.y > max_y:
			return

		# --- CALCULAR CASILLA ---
		
		# Ancho y Alto total entre chinchetas
		# Nota: Usamos abs() (valor absoluto) para evitar líos con números negativos
		var ancho_total = abs(marker_fin.position.x - marker_init.position.x)
		var alto_total = abs(marker_fin.position.y - marker_init.position.y)
		
		# Eje X: Fácil. Distancia desde el inicio / ancho total
		var dist_x = mouse_pos.x - marker_init.position.x
		var pct_x = dist_x / (marker_fin.position.x - marker_init.position.x)
		var grid_x = round(pct_x * (BOARD_SIZE - 1))
		
		# Eje Y: Un poco más truculento porque lo invertimos antes (blancas abajo)
		# Usamos la misma lógica inversa que en el display_board
		var dist_y = mouse_pos.y - marker_fin.position.y
		var pct_y = dist_y / (marker_init.position.y - marker_fin.position.y)
		var grid_y = round(pct_y * (BOARD_SIZE - 1))
		
		# Nos aseguramos de que no de un número loco como -1 o 8
		grid_x = clamp(grid_x, 0, BOARD_SIZE - 1)
		grid_y = clamp(grid_y, 0, BOARD_SIZE - 1)
		
		print("Has hecho clic en la casilla: ", grid_x, ", ", grid_y)
		
		# Vemos qué hay en esa casilla
		var pieza_id = board[grid_y][grid_x]
		if pieza_id != 0:
			print("¡Has tocado una pieza! ID: ", pieza_id)
		else:
			print("Casilla vacía")
			
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
