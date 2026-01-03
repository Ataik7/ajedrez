extends Node

func es_movimiento_valido(board: Array, start: Vector2, end: Vector2) -> bool:
	var pieza_id = board[int(start.y)][int(start.x)]
	var tipo = abs(pieza_id)
	var es_blanca = pieza_id > 0
	
	var dif_x = end.x - start.x
	var dif_y = end.y - start.y
	
	# --- 1. PEÓN ---
	if tipo == 1:
		return validar_peon(board, start, end, es_blanca, dif_x, dif_y)
	
	# --- 4. TORRE ---
	if tipo == 4:
		return validar_torre(board, start, end, dif_x, dif_y)
		
	return true

# -------------------------------------------------------------------------

# --- REGLAS DEL PEÓN ---
func validar_peon(board, start, end, es_blanca, dif_x, dif_y) -> bool:
	var direccion_avance = 1 if es_blanca else -1
	
	# 1. AVANCE NORMAL
	if dif_x == 0 and dif_y == direccion_avance:
		if board[int(end.y)][int(end.x)] == 0: return true
	
	# 2. AVANCE DOBLE
	var fila_inicial = 1 if es_blanca else 6
	if int(start.y) == fila_inicial:
		if dif_x == 0 and dif_y == (2 * direccion_avance):
			if board[int(end.y)][int(end.x)] == 0 and not hay_obstaculos(board, start, end):
				return true

	# 3. COMER
	if abs(dif_x) == 1 and dif_y == direccion_avance:
		if board[int(end.y)][int(end.x)] != 0: return true

	return false

# --- REGLAS DE LA TORRE ---
func validar_torre(board, start, end, dif_x, dif_y) -> bool:
	if dif_x != 0 and dif_y != 0:
		return false
	
	if hay_obstaculos(board, start, end):
		return false
		
	return true

# --- DETECTOR DE OBSTÁCULOS ---
func hay_obstaculos(board, start, end) -> bool:
	var dx = end.x - start.x
	var dy = end.y - start.y
	
	var paso_x = sign(dx)
	var paso_y = sign(dy)
	
	var actual = start + Vector2(paso_x, paso_y)
	
	while actual != end:
		var x_int = int(actual.x)
		var y_int = int(actual.y)
		
		if board[y_int][x_int] != 0:
			return true
		
		actual += Vector2(paso_x, paso_y)
		
	return false
