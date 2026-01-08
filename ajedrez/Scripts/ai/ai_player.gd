extends Node
class_name AIPlayer

## Obtiene el mejor movimiento para la IA
static func get_best_move(board: Array, is_white: bool) -> Dictionary:
	var all_moves = get_all_valid_moves(board, is_white)
	
	if all_moves.is_empty():
		return {}
	
	# Separar movimientos importantes (capturas/promociones) de normales
	var high_priority_moves: Array[Dictionary] = []
	var normal_moves: Array[Dictionary] = []
	
	for move in all_moves:
		var from_pos = move["from"]
		var to_pos = move["to"]
		var piece_moving = board[int(from_pos.y)][int(from_pos.x)]
		var target_piece = board[int(to_pos.y)][int(to_pos.x)]
		
		# 1. Detectar En Passant (Captura especial)
		var es_en_passant = false
		if GameState.en_passant_target.x != -1:
			if int(to_pos.x) == GameState.en_passant_target.x and int(to_pos.y) == GameState.en_passant_target.y:
				if abs(piece_moving) == 1:
					es_en_passant = true

		# 2. Detectar Promoción (Llegar al final con peón)
		var es_promocion = false
		if abs(piece_moving) == 1:
			# Si IA es blanca (fila 7) o negra (fila 0)
			if (piece_moving > 0 and to_pos.y == 7) or (piece_moving < 0 and to_pos.y == 0):
				es_promocion = true

		# Clasificar
		if target_piece != 0 or es_en_passant or es_promocion:
			high_priority_moves.append(move)
		else:
			normal_moves.append(move)
	
	# Priorizar movimientos de alto valor
	if not high_priority_moves.is_empty():
		# Ordenar: Promociones primero, luego capturas valiosas
		high_priority_moves.sort_custom(func(a, b):
			var from_a = a["from"]
			var to_a = a["to"]
			var val_target_a = abs(board[int(to_a.y)][int(to_a.x)])
			var es_promo_a = (abs(board[int(from_a.y)][int(from_a.x)]) == 1) and (to_a.y == 0 or to_a.y == 7)
			
			var from_b = b["from"]
			var to_b = b["to"]
			var val_target_b = abs(board[int(to_b.y)][int(to_b.x)])
			var es_promo_b = (abs(board[int(from_b.y)][int(from_b.x)]) == 1) and (to_b.y == 0 or to_b.y == 7)
			
			# Darle valor infinito (100) a la promoción
			var score_a = 100 if es_promo_a else val_target_a
			var score_b = 100 if es_promo_b else val_target_b
			
			# Ajuste En Passant (vale como comer un peón = 1)
			if val_target_a == 0 and not es_promo_a: score_a = 1
			if val_target_b == 0 and not es_promo_b: score_b = 1
			
			return score_a > score_b
		)
		return high_priority_moves[0]  # El mejor movimiento
	
	# Si no hay nada interesante, movimiento aleatorio
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
					
					# Validar movimiento (pasando GameState para Enroque/En Passant)
					if not MoveCalculator.es_movimiento_valido(board, from, to, GameState):
						continue
					
					# Simular movimiento para verificar seguridad del Rey
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
