extends CanvasLayer

@onready var tooltip: RichTextLabel = $Tooltip
@onready var comparison: RichTextLabel = $Comparison
@onready var options_menu: PanelContainer = $OptionsMenu
@onready var master_volume_label: Label = $OptionsMenu/Content/MasterVolumeLabel
@onready var master_volume_bar: HSlider = $OptionsMenu/Content/MasterVolume/MasterVolumeBar
@onready var text_speed_label: Label = $OptionsMenu/Content/TextSpeedLabel
@onready var text_speed_bar: HSlider = $OptionsMenu/Content/TextSpeed/TextSpeedBar
@onready var battle_anims_toggle: CheckButton = $OptionsMenu/Content/BattleAnims/BattleAnimsToggle
@onready var ui_audio: AudioStreamPlayer = $UIAudio
@onready var input_blocker: TextureRect = $InputBlocker
@onready var help_menu: PanelContainer = $HelpMenu
@onready var confirm_menu: PanelContainer = $ConfirmMenu
@onready var confirm_desc: Label = $ConfirmMenu/Content/Description

@export var sfx_hover: AudioStream
@export var sfx_select: AudioStream
@export var sfx_confirm: AudioStream
@export var sfx_cancel: AudioStream

signal confirmed

enum MENU {
	NONE = 0,
	OPTIONS = 1,
	HELP = 2,
	CREDITS = 3,
}

const VOLUME_INTERP_WEIGHT: float = 4.0

var tooltip_relative_position: Vector2 # Tooltip position relative to the mouse cursor
var window_size: Vector2
var active_menu: int = MENU.NONE
var master_volume_changing: bool = false
var master_volume: float # Current set volume
var old_volume: float # Previous volume value
var new_volume: float # New volume value to set
var volume_change: float = 0.0 # Gradual change in volume
var confirm_choice: bool = false

func _ready() -> void:
	tooltip_relative_position = Vector2(tooltip.size.x * 0.25, tooltip.size.y * 1)
	window_size = DisplayServer.window_get_size()
	set_options_default()

func _physics_process(delta:float) -> void:
	if master_volume_changing:
		volume_change += delta * VOLUME_INTERP_WEIGHT
		master_volume = snapped(old_volume + (new_volume - old_volume) * volume_change, 0.01)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
		if master_volume == new_volume or master_volume >= 1.0 or master_volume <= 0.0:
			master_volume_changing = false
			volume_change = 0

func hide_tooltip() -> void:
	tooltip.hide()
	tooltip.size.y = 20

func hide_comparison() -> void:
	comparison.hide()
	comparison.size.y = 20

func load_sfx(sfx_to_load:AudioStream) -> void:
	if ui_audio.stream != sfx_to_load:
		ui_audio.stop()
		ui_audio.stream = sfx_to_load

func play_hover_sfx() -> void:
	load_sfx(sfx_hover)
	ui_audio.play()

func play_select_sfx() -> void:
	load_sfx(sfx_select)
	ui_audio.play()

func toggle_options_menu() -> void:
	if active_menu == MENU.NONE:
		active_menu = MENU.OPTIONS
		input_blocker.show()
		options_menu.show()
	else:
		active_menu = MENU.NONE
		options_menu.hide()
		input_blocker.hide()

func toggle_help_menu() -> void:
	if active_menu == MENU.NONE:
		active_menu = MENU.HELP
		input_blocker.show()
		help_menu.show()
	else:
		active_menu = MENU.NONE
		help_menu.hide()
		input_blocker.hide()

func toggle_battle_anims(toggled_on: bool) -> void:
	if toggled_on:
		load_sfx(sfx_confirm)
	else:
		load_sfx(sfx_cancel)
	ui_audio.play()
	GameManager.hide_battle_anims = toggled_on

func toggle_fullscreen(toggled_on: bool) -> void:
	if toggled_on:
		load_sfx(sfx_confirm)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		load_sfx(sfx_cancel)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	ui_audio.play()

func display_confirmation(desc: String) -> bool:
	input_blocker.show()
	confirm_desc.text = desc
	confirm_menu.show()
	await confirmed
	confirm_menu.hide()
	input_blocker.hide()
	return confirm_choice

func set_options_default() -> void:
	master_volume = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	master_volume_bar.value = master_volume
	master_volume_label.text = "Master Volume - %d%%" % [master_volume * 100]
	text_speed_bar.value = GameManager.text_speed
	match text_speed_bar.value:
		30.0:
			text_speed_label.text = "Text Speed - Slow"
		45.0:
			text_speed_label.text = "Text Speed - Standard"
		60.0:
			text_speed_label.text = "Text Speed - Fast"
		75.0:
			text_speed_label.text = "Text Speed - Faster"
		90.0:
			text_speed_label.text = "Text Speed - Fastest"

func set_tooltip_position(event_position: Vector2, UI_position: Vector2) -> void:
	tooltip.position = event_position + UI_position + tooltip_relative_position
	comparison.position = tooltip.position + Vector2(tooltip.size.x, 0)
	if tooltip.position.y + tooltip.size.y > window_size.y:
		tooltip.position.y = window_size.y - tooltip.size.y
	if tooltip.position.x + tooltip.size.x > window_size.x:
		tooltip.position.x = window_size.x - tooltip.size.x

func set_master_volume(value: float) -> void:
	if value:
		new_volume = value
		old_volume = master_volume
		volume_change = 0
		master_volume_changing = true
	else:
		master_volume_changing = false
		master_volume = value
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	master_volume_label.text = "Master Volume - %d%%" % [value * 100]

func set_text_speed(value: float) -> void:
	GameManager.text_speed = value
	match value:
		30.0:
			text_speed_label.text = "Text Speed - Slow"
		45.0:
			text_speed_label.text = "Text Speed - Standard"
		60.0:
			text_speed_label.text = "Text Speed - Fast"
		75.0:
			text_speed_label.text = "Text Speed - Faster"
		90.0:
			text_speed_label.text = "Text Speed - Fastest"

func _on_close_button_pressed() -> void:
	load_sfx(sfx_cancel)
	ui_audio.play()
	toggle_options_menu()

func _on_help_menu_close_pressed() -> void:
	load_sfx(sfx_cancel)
	ui_audio.play()
	toggle_help_menu()

func _on_yes_button_pressed() -> void:
	load_sfx(sfx_confirm)
	ui_audio.play()
	confirm_choice = true
	confirmed.emit()

func _on_no_button_pressed() -> void:
	load_sfx(sfx_cancel)
	ui_audio.play()
	confirm_choice = false
	confirmed.emit()
