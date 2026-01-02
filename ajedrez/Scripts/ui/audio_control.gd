extends Control
class_name AudioControl

## Control genérico de volumen con slider y popup visual
## Se puede reutilizar para música, efectos, master, etc. 

@onready var slider: HSlider = $MusicSlider
@onready var popup: Label = $VolumePopup

# Nombre del bus de audio (Music, SFX, Master, etc.)
@export var audio_bus_name:  String = "Master"

# Opciones de visualización
@export var show_percentage: bool = true
@export var popup_offset_y: float = -40.0
@export var popup_duration: float = 1.5

var audio_bus_id: int
var hide_timer:  Timer

func _ready() -> void:
	# Validar que el bus existe
	audio_bus_id = AudioServer. get_bus_index(audio_bus_name)
	if audio_bus_id == -1:
		push_error("Audio bus '" + audio_bus_name + "' no existe!")
		return
	
	# Conectar señal del slider
	if slider:
		slider.value_changed.connect(_on_value_changed)
		# Inicializar slider con el volumen actual
		_load_current_volume()
	else:
		push_warning("No se encontró el nodo 'MusicSlider'")
	
	# Configurar popup
	if popup:
		popup.visible = false
	
	# Configurar temporizador
	hide_timer = Timer.new()
	add_child(hide_timer)
	hide_timer.wait_time = popup_duration
	hide_timer.one_shot = true
	hide_timer.timeout.connect(_hide_popup)

## Carga el volumen actual del bus al slider
func _load_current_volume() -> void:
	var current_db = AudioServer.get_bus_volume_db(audio_bus_id)
	var current_linear = db_to_linear(current_db)
	slider.value = current_linear

## Callback cuando cambia el valor del slider
func _on_value_changed(new_value: float) -> void:
	# Actualizar volumen del bus
	var db = linear_to_db(new_value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
	
	# Mostrar popup si está habilitado
	if show_percentage and popup:
		_show_popup(new_value)

## Muestra el popup con el porcentaje
func _show_popup(value: float) -> void:
	# Calcular porcentaje
	var percentage = roundi(value * 100)
	popup.text = str(percentage) + "%"
	popup.visible = true
	
	# Posicionar el popup sobre el cursor del slider
	if slider:
		var handle_x = slider.size.x * value
		var global_slider_pos = slider.global_position
		popup.global_position = global_slider_pos + Vector2(
			handle_x - popup.size.x / 2, 
			popup_offset_y
		)
	
	# Reiniciar temporizador
	hide_timer.start()

## Oculta el popup
func _hide_popup() -> void:
	if popup:
		popup.visible = false

## Mutea/desmutea el bus
func set_mute(muted: bool) -> void:
	AudioServer.set_bus_mute(audio_bus_id, muted)

## Obtiene el volumen actual (0.0 a 1.0)
func get_volume() -> float:
	var db = AudioServer.get_bus_volume_db(audio_bus_id)
	return db_to_linear(db)

## Establece el volumen (0.0 a 1.0)
func set_volume(value: float) -> void:
	if slider:
		slider.value = clamp(value, 0.0, 1.0)
