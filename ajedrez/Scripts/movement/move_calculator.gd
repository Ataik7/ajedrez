extends Node

func es_movimiento_valido(board: Array, start: Vector2, end: Vector2) -> bool:
	var pieza_id = board[int(start.y)][int(start.x)]
	var tipo = abs(pieza_id)
	var es_blanca = pieza_id > 0
	
	# --- REGLA 0: FUEGO AMIGO ---
	var pieza_destino = board[int(end.y)][int(end.x)]
	if pieza_destino != 0:
		var destino_es_blanca = pieza_destino > 0
		if es_blanca == destino_es_blanca:
			return false 
	# -----------------------------
	
	var dif_x = end.x - start.x
	var dif_y = end.y - start.y
	
	# --- 1. PEÓN ---
	if tipo == 1:
		return validar_peon(board, start, end, es_blanca, dif_x, dif_y)
	
	# --- 2. CABALLO ---
	if tipo == 2:
		return validar_caballo(dif_x, dif_y)
	
	# --- 3. ALFIL ---
	if tipo == 3:
		return validar_alfil(board, start, end, dif_x, dif_y)
	
	# --- 4. TORRE ---
	if tipo == 4:
		return validar_torre(board, start, end, dif_x, dif_y)
		
	# --- 5. REINA ---
	if tipo == 5:
		return validar_reina(board, start, end, dif_x, dif_y)
		
	# --- 6. REY (Nuevo) ---
	if tipo == 6:
		return validar_rey(dif_x, dif_y)
		
	return true

# -------------------------------------------------------------------------

# --- REGLAS DEL REY (Nuevo) ---
func validar_rey(dif_x, dif_y) -> bool:
	# El rey se mueve a cualquier lado, pero solo 1 casilla.
	if abs(dif_x) <= 1 and abs(dif_y) <= 1:
		return true
	return false

# -------------------------------------------------------------------------

func validar_reina(board, start, end, dif_x, dif_y) -> bool:
	if validar_torre(board, start, end, dif_x, dif_y): return true
	if validar_alfil(board, start, end, dif_x, dif_y): return true
	return false

func validar_peon(board, start, end, es_blanca, dif_x, dif_y) -> bool:
	var direccion_avance = 1 if es_blanca else -1
	
	if dif_x == 0 and dif_y == direccion_avance:
		if board[int(end.y)][int(end.x)] == 0: return true
	
	var fila_inicial = 1 if es_blanca else 6
	if int(start.y) == fila_inicial:
		if dif_x == 0 and dif_y == (2 * direccion_avance):
			if board[int(end.y)][int(end.x)] == 0 and not hay_obstaculos(board, start, end):
				return true

	if abs(dif_x) == 1 and dif_y == direccion_avance:
		if board[int(end.y)][int(end.x)] != 0: return true

	return false

func validar_caballo(dif_x, dif_y) -> bool:
	if abs(dif_x) == 2 and abs(dif_y) == 1: return true
	if abs(dif_x) == 1 and abs(dif_y) == 2: return true
	return false

func validar_alfil(board, start, end, dif_x, dif_y) -> bool:
	if abs(dif_x) != abs(dif_y): return false
	if hay_obstaculos(board, start, end): return false
	return true

func validar_torre(board, start, end, dif_x, dif_y) -> bool:
	if dif_x != 0 and dif_y != 0: return false
	if hay_obstaculos(board, start, end): return false
	return true

func hay_obstaculos(board, start, end) -> bool:
	var dx = end.x - start.x
	var dy = end.y - start.y
	
	var paso_x = sign(dx)
	var paso_y = sign(dy)
	
	var actual = start + Vector2(paso_x, paso_y)
	
	while actual != end:
		var x_int = int(actual.x)
		var y_int = int(actual.y)
		if board[y_int][x_int] != 0: return true
		actual += Vector2(paso_x, paso_y)
		
	return false

# --- DETECTOR DE JAQUE ---
# 1. Busca dónde está el Rey de un color
func encontrar_rey(board: Array, es_blanco: bool) -> Vector2:
	var codigo_rey = 6 if es_blanco else -6
	
	for y in range(8):
		for x in range(8):
			if board[y][x] == codigo_rey:
				return Vector2(x, y)
				
	return Vector2(-1, -1) # Error raro (no hay rey)

# 2. Comprueba si el Rey de ese color está siendo atacado
func esta_en_jaque(board: Array, es_blanco: bool) -> bool:
	# A. ¿Dónde está mi Rey?
	var pos_rey = encontrar_rey(board, es_blanco)
	
	# B. Miramos todas las piezas del tablero
	for y in range(8):
		for x in range(8):
			var pieza = board[y][x]
			if pieza == 0: continue
			
			var es_pieza_blanca = pieza > 0
			
			# Si la pieza es AMIGA, no me ataca (saltamos)
			if es_pieza_blanca == es_blanco:
				continue
			
			# Si la pieza es ENEMIGA, preguntamos:
			# "¿Puedes moverte legalmente hasta la cabeza de mi Rey?"
			var pos_enemiga = Vector2(x, y)
			
			# Usamos tu función maestra para validar el ataque
			if es_movimiento_valido(board, pos_enemiga, pos_rey):
				return true # ¡SÍ! Hay alguien que puede matarme
				
	return false # Nadie me apunta
