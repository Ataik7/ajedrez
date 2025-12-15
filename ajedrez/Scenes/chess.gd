extends Sprite2D

const BOARD_SIZE = 8

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
