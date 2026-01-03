extends Control

@onready var slider: HSlider = $MusicSlider
@onready var popup: Label = $VolumePopup
@export var audio_bus_name: String = "Music"

var audio_bus_id: int
var hide_timer := Timer.new()

func _ready() -> void:
	# Validar que el bus existe
	audio_bus_id = AudioServer. get_bus_index(audio_bus_name)
	if audio_bus_id == -1:
		push_error("❌ Audio bus '" + audio_bus_name + "' no existe!")
		push_error("Crea el bus en: Editor → Audio (pestaña inferior)")
		return

	# Conectar señal del slider
	if slider:
		# Establecer valor inicial al 50%
		slider.value = 0.5
		
		# Establecer el volumen del bus también al 50%
		var db = linear_to_db(0.5)
		AudioServer.set_bus_volume_db(audio_bus_id, db)
		
		slider.value_changed.connect(_on_value_changed)
		
		print("🔊 Volumen inicial establecido a: 50%")
	else:
		push_warning("⚠️ No se encontró el nodo 'MusicSlider'")
	
	# Configurar popup
	if popup: 
		popup.visible = false
	else:
		push_warning("⚠️ No se encontró el nodo 'VolumePopup'")
	
	# Configurar temporizador
	add_child(hide_timer)
	hide_timer.wait_time = 1.5
	hide_timer.one_shot = true
	hide_timer.timeout. connect(_hide_popup)

# Carga el volumen actual del bus
func _load_current_volume() -> void:
	var current_db = AudioServer.get_bus_volume_db(audio_bus_id)
	var current_linear = db_to_linear(current_db)
	slider.value = current_linear

func _on_value_changed(new_value: float) -> void:
	# Actualizar volumen del bus
	var db = linear_to_db(new_value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
	
	print("🔊 Volumen cambiado a: ", int(new_value * 100), "%")
	
	# Mostrar popup
	if popup:
		popup.text = str(int(new_value * 100)) + "%"
		popup.visible = true
		
		# Posicionar el popup sobre el cursor del slider
		var handle_x = slider.size.x * new_value
		var global_slider_pos = slider.global_position
		popup. global_position = global_slider_pos + Vector2(handle_x - popup.size.x / 2, -40)
		
		# Reiniciar temporizador
		hide_timer.start()

func _hide_popup() -> void:
	if popup: 
		popup.visible = false
