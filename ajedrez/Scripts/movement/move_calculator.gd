extends Node

# Esta función recibe el tablero, el punto de inicio y el destino.
# Devuelve TRUE si el movimiento es legal, FALSE si es trampa.
static func es_movimiento_valido(board: Array, start: Vector2, end: Vector2) -> bool:
	var pieza_id = board[start.y][start.x]
	var tipo = abs(pieza_id) # 1=Peón, 4=Torre, etc. (quitamos el negativo)
	
	var dif_x = end.x - start.x
	var dif_y = end.y - start.y
	
	# Detectar color (Positivo = Blanca, Negativo = Negra)
	var es_blanca = pieza_id > 0
	
	# ---- LÓGICA DEL PEÓN (ID 1) ---
	if tipo == 1:
		return validar_peon(board, start, end, es_blanca, dif_x, dif_y)
		
	# (Aquí añadiremos Torre, Caballo, etc. más tarde)
	
	# Si es otra pieza, de momento dejamos moverla libre (para probar)
	return true

# --- REGLAS DEL PEÓN ---
static func validar_peon(board, start, end, es_blanca, dif_x, dif_y) -> bool:
	var direccion_avance = 0
	
	# 1. Definir hacia dónde avanza según el color
	# En el array: Fila 0 son Blancas, Fila 7 son Negras.
	# Blancas suben (y aumenta), Negras bajan (y disminuye).
	if es_blanca:
		direccion_avance = 1 
	else:
		direccion_avance = -1
		
	# 2. MOVIMIENTO BÁSICO (1 paso adelante)
	# Tiene que ser la misma columna (dif_x == 0)
	# Tiene que avanzar 1 casilla en su dirección
	if dif_x == 0 and dif_y == direccion_avance:
		# El peón NO puede comer de frente. La casilla debe estar vacía.
		if board[end.y][end.x] == 0:
			return true
	
	# 3. COMER (Diagonal)
	if abs(dif_x) == 1 and dif_y == direccion_avance:
		# Debe haber una pieza enemiga en el destino
		var pieza_destino = board[end.y][end.x]
		if pieza_destino != 0:
			return true

	# Si no cumple nada de lo anterior, es ilegal
	return false
