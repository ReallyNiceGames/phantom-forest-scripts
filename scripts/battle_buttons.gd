extends PanelContainer

#signal battle_btn_pressed(which: String)
@onready var inventory: Control = %Inventory
@onready var ui_audio: AudioStreamPlayer = $UIAudio
@onready var weapon_button: Button = $VBoxContainer/HBoxContainer/WeaponButton
@onready var magic_button: Button = $VBoxContainer/HBoxContainer/MagicButton
@onready var item_button: Button = $VBoxContainer/HBoxContainer2/ItemButton

@export var sfx_cancel: AudioStream
@export var sfx_select: AudioStream
@export var sfx_hover: AudioStream

func load_sfx(sfx_to_load:AudioStream) -> void:
	if ui_audio.stream != sfx_to_load:
		ui_audio.stop()
		ui_audio.stream = sfx_to_load

func _on_weapon_button_pressed() -> void:
	if inventory.active_menu == "weapon_display":
		load_sfx(sfx_cancel)
	else:
		load_sfx(sfx_select)
	ui_audio.play()
	inventory.toggle_menu("weapon_display")

func _on_magic_button_pressed() -> void:
	if inventory.active_menu == "magic_display":
		load_sfx(sfx_cancel)
	else:
		load_sfx(sfx_select)
	ui_audio.play()
	inventory.toggle_menu("magic_display")

func _on_item_button_pressed() -> void:
	if inventory.active_menu == "item_display":
		load_sfx(sfx_cancel)
	else:
		load_sfx(sfx_select)
	ui_audio.play()
	inventory.toggle_menu("item_display")

func _on_misc_button_pressed() -> void:
	if inventory.active_menu == "misc_display":
		load_sfx(sfx_cancel)
	else:
		load_sfx(sfx_select)
	ui_audio.play()
	inventory.toggle_menu("misc_display")

func play_hover_sfx() -> void:
	load_sfx(sfx_hover)
	ui_audio.play()

func _on_weapon_button_mouse_entered() -> void:
	if not weapon_button.disabled:
		load_sfx(sfx_hover)
		ui_audio.play()

func _on_magic_button_mouse_entered() -> void:
	if not magic_button.disabled:
		load_sfx(sfx_hover)
		ui_audio.play()

func _on_item_button_mouse_entered() -> void:
	if not item_button.disabled:
		load_sfx(sfx_hover)
		ui_audio.play()
