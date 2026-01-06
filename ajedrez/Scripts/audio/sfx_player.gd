extends Node

# -------------------------------------------------------------------------
# PRECARGA DE SONIDOS
# -------------------------------------------------------------------------

# Sonido al mover una pieza
var move_sound: AudioStream = preload("res://Sounds/sfx/move.wav")

# Sonido al capturar una pieza
var capture_sound: AudioStream = preload("res://Sounds/sfx/capture.wav")

# -------------------------------------------------------------------------
# POOL DE REPRODUCTORES DE AUDIO
# -------------------------------------------------------------------------

# Lista de reproductores reutilizables
var audio_players: Array[AudioStreamPlayer] = []

# Máximo de sonidos simultáneos
const MAX_PLAYERS = 4

# -------------------------------------------------------------------------
# CICLO DE VIDA
# -------------------------------------------------------------------------

func _ready() -> void:
	# Crear y configurar los reproductores de audio
	for i in range(MAX_PLAYERS):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		audio_players.append(player)
	
	print("✅ SFXPlayer inicializado")

# -------------------------------------------------------------------------
# REPRODUCCIÓN DE SONIDOS
# -------------------------------------------------------------------------

# Reproduce cualquier sonido usando el pool
func play_sound(sound: AudioStream, volume_db: float = 0.0) -> void:
	# Validación básica
	if not sound:
		push_warning("⚠️ Sonido no encontrado")
		return
	
	# Buscar un reproductor libre
	var player = get_available_player()
	if player:
		player.stream = sound
		player.volume_db = volume_db
		player.play()

# -------------------------------------------------------------------------
# GESTIÓN DEL POOL
# -------------------------------------------------------------------------

# Devuelve un reproductor disponible
# Si todos están ocupados, reutiliza el primero
func get_available_player() -> AudioStreamPlayer:
	for player in audio_players:
		if not player.playing:
			return player
	
	return audio_players[0]

# -------------------------------------------------------------------------
# SONIDOS ESPECÍFICOS DEL JUEGO
# -------------------------------------------------------------------------

# Reproduce el sonido de movimiento de pieza
func play_move() -> void:
	play_sound(move_sound, -5.0)
	print("🔊 SFX: Move")


# Reproduce el sonido de captura
func play_capture() -> void:
	play_sound(capture_sound, -3.0)
	print("🔊 SFX: Capture")
