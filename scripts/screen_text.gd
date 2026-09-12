extends Label

@onready var arrow: AnimatedSprite2D = $Arrow
@onready var ui_player: AudioStreamPlayer = $UIPlayer

@export var sfx_cancel: AudioStream
@export var sfx_text: AudioStream

signal text_finished
signal skipping

const DEFAULT_TEXT_SOUND_FREQUENCY: float = 0.1

var animating_text: bool = false
var text_sound_frequency: float = DEFAULT_TEXT_SOUND_FREQUENCY
var current_text_speed: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_text_speed = GameManager.text_speed

func _process(delta: float) -> void:
	if animating_text:
		animate_screen_text(delta)

func set_screen_text(new_text:String) -> void:
	# Hides and sets a new text to the battle text box
	visible_ratio = 0.0
	text_sound_frequency = DEFAULT_TEXT_SOUND_FREQUENCY
	text = new_text
	current_text_speed = GameManager.text_speed
	# Enables the text to be animated on each frame
	animating_text = true
	arrow.play("idle")
	arrow.show()
	mouse_default_cursor_shape = CURSOR_POINTING_HAND

func get_screen_text() -> String:
	return text
	
func animate_screen_text(delta: float) -> void:
	# Increase text visibility
	visible_ratio = min(1.0, visible_ratio + (1.0 / get_total_character_count() * (current_text_speed * delta)))
	if visible_ratio > text_sound_frequency:
		text_sound_frequency += DEFAULT_TEXT_SOUND_FREQUENCY
		load_sfx(sfx_text)
		ui_player.play()
	# Check if text is fully visible and stop animating
	if visible_ratio == 1.0:
		animating_text = false
		text_sound_frequency = DEFAULT_TEXT_SOUND_FREQUENCY
		arrow.hide()
		mouse_default_cursor_shape = CURSOR_ARROW
		text_finished.emit()
		
func skip_screen_text(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if animating_text:
				visible_ratio = 1.0
				animating_text = false
				text_sound_frequency = DEFAULT_TEXT_SOUND_FREQUENCY
				arrow.play("hit")
				load_sfx(sfx_cancel)
				ui_player.play()
				await(get_tree().create_timer(0.2).timeout)
				arrow.hide()
				mouse_default_cursor_shape = CURSOR_ARROW
				text_finished.emit()
			else:
				skipping.emit()

func load_sfx(sfx_to_load:AudioStream) -> void:
	if ui_player.stream != sfx_to_load:
		ui_player.stop()
		ui_player.stream = sfx_to_load
