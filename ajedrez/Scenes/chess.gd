extends Sprite2D

const BOARD_SIZE = 8
const CELL_WIDTH = 18
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

#Variables
# -6 = black king
# -5 = black queen
# -4 = black rook
# -3 = black bishop
# -2 = black knight
# -1 = black pawn
# 0 = empty
# 6 = white king
# 5 = white queen
# 4 = white rook
# 3 = white bishop
# 2 = white knight
# 1 = white pawn
var board : Array
var white : bool
var state : bool
var moves = []
var selected_piece : Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board.append([4, 2, 3, 5, 6, 3, 2, 4])
	board.append([1, 1, 1, 1, 1, 1, 1, 1])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([-1, -1, -1, -1, -1, -1, -1, -1])
	board.append([-4, -2, -3, -5, -6, -3, -2, -4])
	
	display_board()
	
	
func display_board():
	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			var holder = TEXTURE_HOLDER.instantiate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
