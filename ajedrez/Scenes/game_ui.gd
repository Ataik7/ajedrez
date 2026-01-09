extends Node2D

# Variables vacías que rellenaremos automáticamente al arrancar
var status_label: Label
var restart_button: Button

func _ready() -> void:
	# -----------------------------------------------------------
	# INTENTO 1: Buscar en la ruta antigua (dentro del Panel)
	if has_node("Panel/StatusLabel"):
		status_label = $Panel/StatusLabel
	# INTENTO 2: Buscar si lo has sacado fuera (hijo directo)
	elif has_node("StatusLabel"):
		status_label = $StatusLabel
	# -----------------------------------------------------------

	# Buscamos el botón igual
	if has_node("Panel/RestartButton"):
		restart_button = $Panel/RestartButton
	elif has_node("RestartButton"):
		restart_button = $RestartButton

	# Conectamos el botón si existe
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
		restart_button.visible = false

func update_turn_text(is_white: bool) -> void:
	if status_label:
		if is_white:
			status_label.text = "Turno: BLANCAS"
			status_label.modulate = Color(1, 1, 1) # Blanco
		else:
			status_label.text = "Turno: NEGRAS"
			status_label.modulate = Color(0.7, 0.7, 0.7) # Gris

func show_message(text: String) -> void:
	if status_label:
		status_label.text = text
		status_label.modulate = Color(1, 1, 0) # Amarillo

func show_game_over(text: String) -> void:
	if status_label:
		status_label.text = text
		status_label.modulate = Color(1, 0, 0) # Rojo
	
	if restart_button:
		restart_button.visible = true

func _on_restart_pressed() -> void:
	GameState.reset_game()
	get_tree().reload_current_scene()
