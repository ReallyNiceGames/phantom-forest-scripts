extends PanelContainer

@onready var storage: Control = %Storage
@onready var ui_audio: AudioStreamPlayer = $UIAudio

@export var sfx_cancel: AudioStream
@export var sfx_select: AudioStream
@export var sfx_confirm: AudioStream
@export var sfx_hover: AudioStream

func load_sfx(sfx_to_load:AudioStream) -> void:
	if ui_audio.stream != sfx_to_load:
		ui_audio.stop()
		ui_audio.stream = sfx_to_load

func _on_buy_button_pressed() -> void:
	if storage.active_menu == "buy":
		load_sfx(sfx_cancel)
	else:
		load_sfx(sfx_select)
	ui_audio.play()
	storage.toggle_menu("buy")

func _on_sell_button_pressed() -> void:
	if storage.active_menu == "sell":
		load_sfx(sfx_cancel)
	else:
		load_sfx(sfx_select)
	ui_audio.play()
	storage.toggle_menu("sell")

func _on_leave_button_pressed() -> void:
	hide()
	load_sfx(sfx_confirm)
	ui_audio.play()
	storage.leave_shop()

func _on_misc_button_pressed() -> void:
	if storage.active_menu == "misc":
		load_sfx(sfx_cancel)
	else:
		load_sfx(sfx_select)
	ui_audio.play()
	storage.toggle_menu("misc")

func play_hover_sfx() -> void:
	load_sfx(sfx_hover)
	ui_audio.play()
