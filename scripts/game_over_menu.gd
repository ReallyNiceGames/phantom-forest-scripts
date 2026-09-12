extends PanelContainer

@onready var ui_audio: AudioStreamPlayer = $UIAudio
@onready var retry_button: Button = $VBoxContainer/HBoxContainer/RetryButton

@export var sfx_confirm: AudioStream
@export var sfx_hover: AudioStream

signal restart_pressed
signal retry_pressed

func _ready() -> void:
	if not GameManager.checkpoint_available:
		retry_button.disabled = true

func load_sfx(sfx_to_load:AudioStream) -> void:
	if ui_audio.stream != sfx_to_load:
		ui_audio.stop()
		ui_audio.stream = sfx_to_load

func _on_retry_button_pressed() -> void:
	load_sfx(sfx_confirm)
	ui_audio.play()
	retry_pressed.emit()

func _on_main_menu_button_pressed() -> void:
	load_sfx(sfx_confirm)
	ui_audio.play()
	restart_pressed.emit()

func _on_quit_game_button_pressed() -> void:
	load_sfx(sfx_confirm)
	ui_audio.play()
	get_tree().quit()

func play_hover_sfx() -> void:
	load_sfx(sfx_hover)
	ui_audio.play()

func _on_retry_button_mouse_entered() -> void:
	if not retry_button.disabled:
		load_sfx(sfx_hover)
		ui_audio.play()
