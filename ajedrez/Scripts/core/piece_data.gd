extends Node
class_name PieceData

## -----------------------------
## Definiciones y utilidades
## de las piezas de ajedrez
## -----------------------------

# Enumeración de todas las piezas del juego
# Las piezas blancas son POSITIVAS
# Las piezas negras son NEGATIVAS
enum PieceType {
	EMPTY = 0,
	W_PAWN = 1,
	W_KNIGHT = 2,
	W_BISHOP = 3,
	W_ROOK = 4,
	W_QUEEN = 5,
	W_KING = 6,
	B_PAWN = -1,
	B_KNIGHT = -2,
	B_BISHOP = -3,
	B_ROOK = -4,
	B_QUEEN = -5,
	B_KING = -6
}

# Tamaño estándar del tablero de ajedrez (8x8)
const BOARD_SIZE = 8

# -------------------------------------------------------------------------
# UTILIDADES DE COLOR
# -------------------------------------------------------------------------

# Verifica si una pieza es blanca
# Devuelve FALSE si la casilla está vacía
static func is_white_piece(piece: int) -> bool:
	return piece > 0


# Verifica si una pieza es negra
# Devuelve FALSE si la casilla está vacía
static func is_black_piece(piece: int) -> bool:
	return piece < 0

# Verifica si dos piezas son del mismo color
# Si alguna es vacía, devuelve FALSE
static func same_color(piece1: int, piece2: int) -> bool:
	if piece1 == 0 or piece2 == 0:
		return false
	return (piece1 > 0) == (piece2 > 0)

# -------------------------------------------------------------------------
# UTILIDADES DE INFORMACIÓN
# -------------------------------------------------------------------------

# Devuelve el nombre legible de una pieza
# Para depuración, mensajes o UI
static func get_piece_name(piece: int) -> String:
	match piece:
		1: return "Peón Blanco"
		2: return "Caballo Blanco"
		3: return "Alfil Blanco"
		4: return "Torre Blanca"
		5: return "Reina Blanca"
		6: return "Rey Blanco"
		-1: return "Peón Negro"
		-2: return "Caballo Negro"
		-3: return "Alfil Negro"
		-4: return "Torre Negra"
		-5: return "Reina Negra"
		-6: return "Rey Negro"
		_: return "Vacío"
