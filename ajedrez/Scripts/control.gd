extends Control

@onready var slider: HSlider = $MusicSlider
@onready var popup: Label = $VolumePopup
@export var audio_bus_name: String = "Music"

var audio_bus_id: int
var hide_timer := Timer.new()

func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	slider.value_changed.connect(_on_value_changed)

	# Configurar el popup
	popup.visible = false
	add_child(hide_timer)
	hide_timer.wait_time = 1.5
	hide_timer.one_shot = true
	hide_timer.timeout.connect(_hide_popup)

func _on_value_changed(new_value: float) -> void:
	var db = linear_to_db(new_value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)

	# Mostrar el popup con el porcentaje
	popup.text = str(int(new_value * 100)) + "%"
	popup.visible = true

	# Posicionar el popup sobre el cursor del slider
	var handle_x = slider.size.x * new_value
	var global_slider_pos = slider.global_position
	popup.global_position = global_slider_pos + Vector2(handle_x - popup.size.x / 2, -40)

	# Reiniciar el temporizador para ocultar
	hide_timer.start()

func _hide_popup() -> void:
	popup.visible = false
