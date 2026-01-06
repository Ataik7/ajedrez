extends Node

## -----------------------------
## Estado global del juego
## -----------------------------

# Función principal que valida si un movimiento es legal
func es_movimiento_valido(board: Array, start: Vector2, end: Vector2) -> bool:
	# Identificación de la pieza
	var pieza_id = board[int(start.y)][int(start.x)]
	var tipo = abs(pieza_id)
	var es_blanca = pieza_id > 0
	
	# --- REGLA 0: FUEGO AMIGO ---
	# No se puede capturar una pieza del mismo color
	var pieza_destino = board[int(end.y)][int(end.x)]
	if pieza_destino != 0:
		var destino_es_blanca = pieza_destino > 0
		if es_blanca == destino_es_blanca:
			return false
	# -----------------------------
	
	# Diferencias de movimiento
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
		
	# --- 6. REY ---
	if tipo == 6:
		return validar_rey(dif_x, dif_y)
		
	return true

# -------------------------------------------------------------------------
# REGLAS DEL REY
# -------------------------------------------------------------------------

# El rey se mueve una casilla en cualquier dirección
func validar_rey(dif_x, dif_y) -> bool:
	if abs(dif_x) <= 1 and abs(dif_y) <= 1:
		return true
	return false

# -------------------------------------------------------------------------
# REGLAS DE LA REINA
# -------------------------------------------------------------------------

# La reina combina el movimiento de la torre y el alfil
func validar_reina(board, start, end, dif_x, dif_y) -> bool:
	if validar_torre(board, start, end, dif_x, dif_y): return true
	if validar_alfil(board, start, end, dif_x, dif_y): return true
	return false

# -------------------------------------------------------------------------
# REGLAS DEL PEÓN
# -------------------------------------------------------------------------

func validar_peon(board, start, end, es_blanca, dif_x, dif_y) -> bool:
	# Dirección de avance según el color
	var direccion_avance = 1 if es_blanca else -1
	
	# Movimiento normal de una casilla
	if dif_x == 0 and dif_y == direccion_avance:
		if board[int(end.y)][int(end.x)] == 0:
			return true
	
	# Movimiento doble desde la fila inicial
	var fila_inicial = 1 if es_blanca else 6
	if int(start.y) == fila_inicial:
		if dif_x == 0 and dif_y == (2 * direccion_avance):
			if board[int(end.y)][int(end.x)] == 0 and not hay_obstaculos(board, start, end):
				return true

	# Captura en diagonal
	if abs(dif_x) == 1 and dif_y == direccion_avance:
		if board[int(end.y)][int(end.x)] != 0:
			return true

	return false

# -------------------------------------------------------------------------
# REGLAS DEL CABALLO
# -------------------------------------------------------------------------

func validar_caballo(dif_x, dif_y) -> bool:
	if abs(dif_x) == 2 and abs(dif_y) == 1: return true
	if abs(dif_x) == 1 and abs(dif_y) == 2: return true
	return false

# -------------------------------------------------------------------------
# REGLAS DEL ALFIL
# -------------------------------------------------------------------------

func validar_alfil(board, start, end, dif_x, dif_y) -> bool:
	# Debe moverse en diagonal perfecta
	if abs(dif_x) != abs(dif_y): return false
	# No puede saltar piezas
	if hay_obstaculos(board, start, end): return false
	return true

# -------------------------------------------------------------------------
# REGLAS DE LA TORRE
# -------------------------------------------------------------------------

func validar_torre(board, start, end, dif_x, dif_y) -> bool:
	# Movimiento recto horizontal o vertical
	if dif_x != 0 and dif_y != 0: return false
	# No puede saltar piezas
	if hay_obstaculos(board, start, end): return false
	return true

# -------------------------------------------------------------------------
# DETECTOR DE OBSTÁCULOS
# -------------------------------------------------------------------------

# Comprueba si hay piezas entre el inicio y el final
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

# -------------------------------------------------------------------------
# DETECTOR DE JAQUE
# -------------------------------------------------------------------------

# 1. Localiza la posición del rey de un color
func encontrar_rey(board: Array, es_blanco: bool) -> Vector2:
	var codigo_rey = 6 if es_blanco else -6
	
	for y in range(8):
		for x in range(8):
			if board[y][x] == codigo_rey:
				return Vector2(x, y)
				
	return Vector2(-1, -1) # Error extremo: no hay rey

# 2. Comprueba si el rey está siendo atacado
func esta_en_jaque(board: Array, es_blanco: bool) -> bool:
	# A. Posición del rey
	var pos_rey = encontrar_rey(board, es_blanco)
	
	# B. Revisamos todas las piezas enemigas
	for y in range(8):
		for x in range(8):
			var pieza = board[y][x]
			if pieza == 0: continue
			
			var es_pieza_blanca = pieza > 0
			
			# Ignoramos piezas aliadas
			if es_pieza_blanca == es_blanco:
				continue
			
			# ¿Puede esta pieza capturar al rey?
			var pos_enemiga = Vector2(x, y)
			if es_movimiento_valido(board, pos_enemiga, pos_rey):
				return true
				
	return false

# -------------------------------------------------------------------------
# DETECTOR DE FIN DE PARTIDA (Mate / Ahogado)
# -------------------------------------------------------------------------

# Devuelve TRUE si existe al menos un movimiento legal salvador
func hay_movimientos_salvadores(board: Array, es_turno_blancas: bool) -> bool:
	
	# 1. Buscar todas las piezas del jugador actual
	for start_y in range(8):
		for start_x in range(8):
			var pieza = board[start_y][start_x]
			
			if pieza == 0: continue
			var es_pieza_blanca = pieza > 0
			if es_pieza_blanca != es_turno_blancas: continue
			
			var start = Vector2(start_x, start_y)
			
			# 2. Probar todos los destinos posibles
			for end_y in range(8):
				for end_x in range(8):
					var end = Vector2(end_x, end_y)
					
					# A. Movimiento físico válido
					if not es_movimiento_valido(board, start, end):
						continue
					
					# B. Simulación del movimiento
					var pieza_destino = board[end_y][end_x]
					
					if pieza_destino != 0:
						if (pieza_destino > 0) == es_pieza_blanca:
							continue
					
					board[end_y][end_x] = pieza
					board[start_y][start_x] = 0
					
					# C. Verificación de jaque
					var sigo_en_jaque = esta_en_jaque(board, es_turno_blancas)
					
					# Rollback
					board[start_y][start_x] = pieza
					board[end_y][end_x] = pieza_destino
					
					# D. Resultado
					if sigo_en_jaque == false:
						return true
	
	return false
