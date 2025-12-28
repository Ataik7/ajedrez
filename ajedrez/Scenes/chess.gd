extends Sprite2D

# --- CONFIGURACIÓN ---
@onready var marker_init: Marker2D = $MarkerInit
@onready var marker_fin: Marker2D = $MarkerFin

# 1. ESCALA: Bajar esto si se ven gigantes 
@export var tamano_pieza : float = 0.75

# 2. ALTURA: Subir o bajar las piezas sin mover los markers
@export var ajuste_altura : float = -8.0

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
	
func display_board():
	for child in pieces.get_children():
		child.queue_free()
		
	var pos_inicio = marker_init.position
	var pos_fin = marker_fin.position

	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			if board[i][j] == 0:
				continue
			
			var holder = TEXTURE_HOLDER.instantiate()
			pieces.add_child(holder)
			
			holder.scale = Vector2(tamano_pieza, tamano_pieza)
			
			var porcentaje_x = float(j) / (BOARD_SIZE - 1)
			var porcentaje_y = float(i) / (BOARD_SIZE - 1)
			
			var x_final = lerp(pos_inicio.x, pos_fin.x, porcentaje_x)
			var y_final = lerp(pos_fin.y, pos_inicio.y, porcentaje_y)
			
			# Sumamos el ajuste de altura
			holder.position = Vector2(x_final, y_final + ajuste_altura)
			
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
