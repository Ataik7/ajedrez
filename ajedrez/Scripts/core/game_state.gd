extends Node

## -----------------------------
## Estado global del juego
## -----------------------------

var is_white_turn: bool = true
var selected_piece: Vector2 = Vector2(-1, -1)

## -----------------------------
## Flags de enroque
## -----------------------------

var white_king_moved: bool = false
var black_king_moved: bool = false

var white_rook_left_moved: bool = false
var white_rook_right_moved: bool = false
var black_rook_left_moved: bool = false
var black_rook_right_moved: bool = false

## -----------------------------
## Captura al paso
## -----------------------------

var en_passant_target: Vector2i = Vector2i(-1, -1)

## -----------------------------
## Turnos
## -----------------------------

func change_turn() -> void:
	is_white_turn = ! is_white_turn
	
	if is_white_turn:
		print("--- 🏳️ BLANCAS ---")
	else:
		print("--- 🏴 NEGRAS ---")

## -----------------------------
## Reset
## -----------------------------

func reset_game() -> void:
	is_white_turn = true
	selected_piece = Vector2(-1, -1)

	white_king_moved = false
	black_king_moved = false
	white_rook_left_moved = false
	white_rook_right_moved = false
	black_rook_left_moved = false
	black_rook_right_moved = false

	en_passant_target = Vector2i(-1, -1)

	print("🔄 Juego reiniciado")

## -----------------------------
## Enroque – consultas
## -----------------------------

func can_castle_kingside(is_white: bool) -> bool:
	if is_white:
		return not white_king_moved and not white_rook_right_moved

	return not black_king_moved and not black_rook_right_moved


func can_castle_queenside(is_white: bool) -> bool:
	if is_white:
		return not white_king_moved and not white_rook_left_moved

	return not black_king_moved and not black_rook_left_moved

## -----------------------------
## Enroque – actualización
## -----------------------------

func update_castling_flags(from: Vector2i, piece: int) -> void:
	# Rey
	if abs(piece) == 6:
		if piece > 0:
			white_king_moved = true
		else:
			black_king_moved = true
		return

	# Torre
	if abs(piece) == 4:
		_update_rook_flags(from, piece)


func _update_rook_flags(from: Vector2i, piece: int) -> void:
	if piece > 0:
		if from.x == 0:
			white_rook_left_moved = true
		elif from.x == 7:
			white_rook_right_moved = true
	else:
		if from.x == 0:
			black_rook_left_moved = true
		elif from.x == 7:
			black_rook_right_moved = true
