extends Node
class_name AIPlayer

## Obtiene el mejor movimiento para la IA
static func get_best_move(board: Array, is_white:  bool) -> Dictionary:
	var all_moves = get_all_valid_moves(board, is_white)
	
	if all_moves.is_empty():
		return {}
	
	# Separar capturas y movimientos normales
	var captures: Array[Dictionary] = []
	var normal_moves: Array[Dictionary] = []
	
	for move in all_moves:
		var to_pos = move["to"]
		var target_piece = board[int(to_pos.y)][int(to_pos.x)]
		
		if target_piece != 0:
			captures.append(move)
		else:
			normal_moves.append(move)
	
	# Priorizar capturas (más inteligente)
	if not captures.is_empty():
		# Ordenar capturas por valor de pieza
		captures.sort_custom(func(a, b):
			var piece_a = abs(board[int(a["to"].y)][int(a["to"].x)])
			var piece_b = abs(board[int(b["to"].y)][int(b["to"].x)])
			return piece_a > piece_b
		)
		return captures[0]  # Mejor captura
	
	# Si no hay capturas, movimiento aleatorio
	return normal_moves.pick_random()

## Obtiene todos los movimientos válidos para un color
static func get_all_valid_moves(board: Array, is_white: bool) -> Array[Dictionary]:
	var valid_moves: Array[Dictionary] = []
	
	for y in range(8):
		for x in range(8):
			var piece = board[y][x]
			
			# Solo piezas del color de la IA
			if piece == 0:
				continue
			if (is_white and piece < 0) or (not is_white and piece > 0):
				continue
			
			var from = Vector2(x, y)
			
			# Probar todos los destinos posibles
			for dest_y in range(8):
				for dest_x in range(8):
					var to = Vector2(dest_x, dest_y)
					
					# Validar movimiento básico
					if not MoveCalculator.es_movimiento_valido(board, from, to):
						continue
					
					# Simular movimiento para verificar que no deja en jaque
					var moving_piece = board[y][x]
					var temp_piece = board[dest_y][dest_x]
					
					board[dest_y][dest_x] = moving_piece
					board[y][x] = 0
					
					var safe = not MoveCalculator.esta_en_jaque(board, is_white)
					
					# Deshacer simulación
					board[y][x] = moving_piece
					board[dest_y][dest_x] = temp_piece
					
					if safe:
						valid_moves.append({
							"from": from,
							"to": to,
							"piece": moving_piece
						})
	
	return valid_moves
