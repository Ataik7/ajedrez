extends Node

var is_white_turn : bool = true
var selected_piece : Vector2 = Vector2(-1, -1)

# Función para cambiar turno de forma segura
func change_turn():
	is_white_turn = !is_white_turn # Invierte el valor
	
	if is_white_turn:
		print("--- 🏳️ Turno BLANCAS ---")
	else:
		print("--- 🏴 Turno NEGRAS ---")

# Función para resetear datos (útil para reiniciar partida)
func reset_game():
	is_white_turn = true
	selected_piece = Vector2(-1, -1)
