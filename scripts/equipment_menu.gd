extends Panel

@onready var weapon_options: OptionButton = $WeaponOptions
@onready var relic_options: OptionButton = $RelicOptions
@onready var head_options: OptionButton = $HeadOptions
@onready var chest_options: OptionButton = $ChestOptions
@onready var arms_options: OptionButton = $ArmsOptions
@onready var legs_options: OptionButton = $LegsOptions
@onready var hp_label: RichTextLabel = $StatsContainer/HPContainer/HPLabel
@onready var mp_label: RichTextLabel = $StatsContainer/MPContainer/MPLabel
@onready var def_label: RichTextLabel = $StatsContainer/DefContainer/DefLabel
@onready var atk_label: RichTextLabel = $StatsContainer/AtkContainer/AtkLabel
@onready var sp_label: RichTextLabel = $StatsContainer/SPContainer/SPLabel
@onready var ui_audio: AudioStreamPlayer = $UIAudio
@onready var hp_container: HBoxContainer = $StatsContainer/HPContainer
@onready var mp_container: HBoxContainer = $StatsContainer/MPContainer
@onready var def_container: HBoxContainer = $StatsContainer/DefContainer
@onready var atk_container: HBoxContainer = $StatsContainer/AtkContainer
@onready var sp_container: HBoxContainer = $StatsContainer/SPContainer
@onready var stats_container: VBoxContainer = $StatsContainer
@onready var relic_spell_icon: TextureRect = $RelicSpellIcon
@onready var relic_spell_label: Label = $RelicSpellLabel

@export var sfx_cancel: AudioStream
@export var sfx_equip: AudioStream
@export var sfx_unequip: AudioStream
@export var sfx_hover: AudioStream
@export var sfx_select: AudioStream

signal stats_changed
signal menu_closed
signal redisplay_skills
signal redisplay_spells
signal redisplay_sellable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_equipment()
	update_stat_labels(false)

func load_sfx(sfx_to_load:AudioStream) -> void:
	if ui_audio.stream != sfx_to_load:
		ui_audio.stop()
		ui_audio.stream = sfx_to_load

func display_equipment() -> void:
	clear_equipment() # Clear any previous items
	var equipment
	# Display weapons with icon and tooltip
	for x in GameManager.stored_weapons.size():
		equipment = GameManager.stored_weapons[x]
		if is_instance_valid(equipment):
			weapon_options.add_item(equipment.name, x)
			weapon_options.set_item_icon(weapon_options.item_count - 1, equipment.icon)
			weapon_options.set_item_tooltip(weapon_options.item_count - 1, equipment.tooltip)
			if equipment.is_equipped:
				weapon_options.select(weapon_options.item_count - 1)
				weapon_options.tooltip_text = equipment.tooltip
	# Display armour with icon and tooltip
	for x in GameManager.stored_armour.size():
		equipment = GameManager.stored_armour[x]
		if is_instance_valid(equipment):
			match equipment.slot:
				"head":
					head_options.add_item(equipment.name, x)
					head_options.set_item_icon(head_options.item_count - 1, equipment.icon)
					head_options.set_item_tooltip(head_options.item_count - 1, equipment.tooltip)
					if equipment.is_equipped:
						head_options.select(head_options.item_count - 1)
						head_options.tooltip_text = equipment.tooltip
				"chest":
					chest_options.add_item(equipment.name, x)
					chest_options.set_item_icon(chest_options.item_count - 1, equipment.icon)
					chest_options.set_item_tooltip(chest_options.item_count - 1, equipment.tooltip)
					if equipment.is_equipped:
						chest_options.select(chest_options.item_count - 1)
						chest_options.tooltip_text = equipment.tooltip
				"arms":
					arms_options.add_item(equipment.name, x)
					arms_options.set_item_icon(arms_options.item_count - 1, equipment.icon)
					arms_options.set_item_tooltip(arms_options.item_count - 1, equipment.tooltip)
					if equipment.is_equipped:
						arms_options.select(arms_options.item_count - 1)
						arms_options.tooltip_text = equipment.tooltip
				"legs":
					legs_options.add_item(equipment.name, x)
					legs_options.set_item_icon(legs_options.item_count - 1, equipment.icon)
					legs_options.set_item_tooltip(legs_options.item_count - 1, equipment.tooltip)
					if equipment.is_equipped:
						legs_options.select(legs_options.item_count - 1)
						legs_options.tooltip_text = equipment.tooltip
				_:
					printerr("ERROR: Armour slot not found for displaying")
	# Display relics with icon and tooltip
	for x in GameManager.stored_relics.size():
		equipment = GameManager.stored_relics[x]
		if is_instance_valid(equipment):
			relic_options.add_item(equipment.name, x)
			relic_options.set_item_icon(relic_options.item_count - 1, equipment.icon)
			relic_options.set_item_tooltip(relic_options.item_count - 1, equipment.tooltip)
			if equipment.is_equipped:
				relic_options.select(relic_options.item_count - 1)
				relic_options.tooltip_text = equipment.tooltip
				relic_spell_icon.texture = equipment.icon
				relic_spell_icon.tooltip_text = equipment.spell.tooltip
				relic_spell_label.text = equipment.spell.name

func update_stat_labels(send_signal: bool = true) -> void:
	# Update HP label
	if GameManager.player_HP_regen > 0:
		hp_label.text = "HP: %d/%d ([color=green]+%d[/color])" % [GameManager.player_HP, GameManager.player_max_HP, GameManager.player_HP_regen]
	elif GameManager.player_HP_regen < 0:
		hp_label.text = "HP: %d/%d ([color=red]%d[/color])" % [GameManager.player_HP, GameManager.player_max_HP, GameManager.player_HP_regen]
	else:
		hp_label.text = "HP: %d/%d (+%d)" % [GameManager.player_HP, GameManager.player_max_HP, GameManager.player_HP_regen]
	# Update MP label
	if GameManager.player_MP_regen > 1:
		mp_label.text = "MP: %d/%d ([color=green]+%d[/color])" % [GameManager.player_MP, GameManager.player_max_MP, GameManager.player_MP_regen]
	elif GameManager.player_MP_regen < 1:
		mp_label.text = "MP: %d/%d ([color=red]%d[/color])" % [GameManager.player_MP, GameManager.player_max_MP, GameManager.player_MP_regen]
	else:
		mp_label.text = "MP: %d/%d (+%d)" % [GameManager.player_MP, GameManager.player_max_MP, GameManager.player_MP_regen]
	# Update defence label
	if GameManager.player_temp_defence > 0:
		def_label.text = "Defence: %d ([color=green]+%d[/color])" % [GameManager.player_defence, GameManager.player_temp_defence]
	elif GameManager.player_temp_defence < 0:
		def_label.text = "Defence: %d ([color=red]%d[/color])" % [GameManager.player_defence, GameManager.player_temp_defence]
	else:
		def_label.text = "Defence: %d (+%d)" % [GameManager.player_defence, GameManager.player_temp_defence]
	# Update attack label
	if GameManager.player_temp_attack > 0:
		atk_label.text = "Attack: %d ([color=green]+%d[/color])" % [GameManager.player_attack_power, GameManager.player_temp_attack]
	elif GameManager.player_temp_attack < 0:
		atk_label.text = "Attack: %d ([color=red]%d[/color])" % [GameManager.player_attack_power, GameManager.player_temp_attack]
	else:
		atk_label.text = "Attack: %d (+%d)" % [GameManager.player_attack_power, GameManager.player_temp_attack]
	# Update spell label
	if GameManager.player_temp_spell > 0:
		sp_label.text = "Spell: %d ([color=green]+%d[/color])" % [GameManager.player_spellpower, GameManager.player_temp_spell]
	elif GameManager.player_temp_spell < 0:
		sp_label.text = "Spell: %d ([color=red]%d[/color])" % [GameManager.player_spellpower, GameManager.player_temp_spell]
	else:
		sp_label.text = "Spell: %d (+%d)" % [GameManager.player_spellpower, GameManager.player_temp_spell]
	if not send_signal: return
	stats_changed.emit()

func clear_equipment() -> void:
	# Clear lists of any previously-displayed equipment
	weapon_options.clear()
	relic_options.clear()
	head_options.clear()
	chest_options.clear()
	arms_options.clear()
	legs_options.clear()
	# Clear tooltips
	weapon_options.tooltip_text = ""
	relic_options.tooltip_text = ""
	head_options.tooltip_text = ""
	chest_options.tooltip_text = ""
	arms_options.tooltip_text = ""
	legs_options.tooltip_text = ""
	# Add default options
	weapon_options.add_item("No Weapon", 999)
	weapon_options.set_item_icon(0, GameManager.icons["disabled"])
	relic_options.add_item("No Relic", 999)
	relic_options.set_item_icon(0, GameManager.icons["disabled"])
	head_options.add_item("Empty", 999)
	head_options.set_item_icon(0, GameManager.icons["head_empty"])
	chest_options.add_item("Empty", 999)
	chest_options.set_item_icon(0, GameManager.icons["chest_empty"])
	arms_options.add_item("Empty", 999)
	arms_options.set_item_icon(0, GameManager.icons["arms_empty"])
	legs_options.add_item("Empty", 999)
	legs_options.set_item_icon(0, GameManager.icons["legs_empty"])

func _on_close_button_mouse_entered() -> void:
	load_sfx(sfx_hover)
	ui_audio.play()

func _on_close_button_pressed() -> void:
	load_sfx(sfx_cancel)
	ui_audio.play()
	menu_closed.emit()

func equipment_toggled(toggled_on: bool) -> void:
	if toggled_on:
		load_sfx(sfx_select)
	else:
		load_sfx(sfx_cancel)
	ui_audio.play()

func _on_weapon_options_item_selected(index: int) -> void:
	# Use ID to find it in storage and equip it
	var storage_index: int = weapon_options.get_item_id(index)
	if not storage_index == 999:
		GameManager.equip_weapon(storage_index)
		weapon_options.tooltip_text = GameManager.player_weapon.tooltip
		load_sfx(sfx_equip)
	else:
		GameManager.unequip_weapon() # Remove current weapon and skills from display
		weapon_options.tooltip_text = ""
		load_sfx(sfx_unequip)
	ui_audio.play()
	redisplay_skills.emit()
	redisplay_sellable.emit()

func _on_relic_options_item_selected(index: int) -> void:
	# Use ID to find it in storage and equip it
	var storage_index: int = relic_options.get_item_id(index)
	if not storage_index == 999:
		GameManager.equip_relic(storage_index)
		relic_options.tooltip_text = GameManager.player_relic.tooltip
		relic_spell_icon.texture = GameManager.player_relic.icon
		relic_spell_icon.tooltip_text = GameManager.player_relic.spell.tooltip
		relic_spell_label.text = GameManager.player_relic.spell.name
		load_sfx(sfx_equip)
	else:
		GameManager.unequip_relic()
		relic_options.tooltip_text = ""
		relic_spell_icon.texture = GameManager.icons["unknown"]
		relic_spell_icon.tooltip_text = ""
		relic_spell_label.text = "No Relic Spell"
		load_sfx(sfx_unequip)
	ui_audio.play()
	update_stat_labels() # Reflect changes on the equipment menu stats
	redisplay_spells.emit()
	redisplay_sellable.emit()

func _on_head_options_item_selected(index: int) -> void:
	# Use ID to find it in storage and equip it
	var storage_index: int = head_options.get_item_id(index)
	if not storage_index == 999:
		GameManager.equip_armour(storage_index)
		head_options.tooltip_text = GameManager.player_head.tooltip
		load_sfx(sfx_equip)
	else:
		GameManager.unequip_armour("head")
		head_options.tooltip_text = ""
		load_sfx(sfx_unequip)
	ui_audio.play()
	update_stat_labels() # Reflect changes on the equipment menu stats
	redisplay_sellable.emit()

func _on_chest_options_item_selected(index: int) -> void:
	# Use ID to find it in storage and equip it
	var storage_index: int = chest_options.get_item_id(index)
	if not storage_index == 999:
		GameManager.equip_armour(storage_index)
		chest_options.tooltip_text = GameManager.player_chest.tooltip
		load_sfx(sfx_equip)
	else:
		GameManager.unequip_armour("chest")
		chest_options.tooltip_text = ""
		load_sfx(sfx_unequip)
	ui_audio.play()
	update_stat_labels() # Reflect changes on the equipment menu stats
	redisplay_sellable.emit()

func _on_arms_options_item_selected(index: int) -> void:
	# Use ID to find it in storage and equip it
	var storage_index: int = arms_options.get_item_id(index)
	if not storage_index == 999:
		GameManager.equip_armour(storage_index)
		arms_options.tooltip_text = GameManager.player_arms.tooltip
		load_sfx(sfx_equip)
	else:
		GameManager.unequip_armour("arms")
		arms_options.tooltip_text = ""
		load_sfx(sfx_unequip)
	ui_audio.play()
	update_stat_labels() # Reflect changes on the equipment menu stats
	redisplay_sellable.emit()

func _on_legs_options_item_selected(index: int) -> void:
	# Use ID to find it in storage and equip it
	var storage_index: int = legs_options.get_item_id(index)
	if not storage_index == 999:
		GameManager.equip_armour(storage_index)
		legs_options.tooltip_text = GameManager.player_legs.tooltip
		load_sfx(sfx_equip)
	else:
		GameManager.unequip_armour("legs")
		legs_options.tooltip_text = ""
		load_sfx(sfx_unequip)
	ui_audio.play()
	update_stat_labels() # Reflect changes on the equipment menu stats
	redisplay_sellable.emit()

func hide_tooltip() -> void:
	UI.tooltip.hide()
	UI.tooltip.size.y = 20

func _on_weapon_options_gui_input(event: InputEvent) -> void:
	UI.tooltip.size.y = 20
	UI.tooltip.text = weapon_options.tooltip_text
	if !UI.tooltip.text:
		hide_tooltip()
		return
	UI.set_tooltip_position(event.position, self.position + weapon_options.position)
	UI.tooltip.show()

func _on_relic_options_gui_input(event: InputEvent) -> void:
	UI.tooltip.size.y = 20
	UI.tooltip.text = relic_options.tooltip_text
	if !UI.tooltip.text:
		hide_tooltip()
		return
	UI.set_tooltip_position(event.position, self.position + relic_options.position)
	UI.tooltip.show()

func _on_head_options_gui_input(event: InputEvent) -> void:
	UI.tooltip.size.y = 20
	UI.tooltip.text = head_options.tooltip_text
	if !UI.tooltip.text:
		hide_tooltip()
		return
	UI.set_tooltip_position(event.position, self.position + head_options.position)
	UI.tooltip.show()

func _on_chest_options_gui_input(event: InputEvent) -> void:
	UI.tooltip.size.y = 20
	UI.tooltip.text = chest_options.tooltip_text
	if !UI.tooltip.text:
		hide_tooltip()
		return
	UI.set_tooltip_position(event.position, self.position + chest_options.position)
	UI.tooltip.show()

func _on_arms_options_gui_input(event: InputEvent) -> void:
	UI.tooltip.size.y = 20
	UI.tooltip.text = arms_options.tooltip_text
	if !UI.tooltip.text:
		hide_tooltip()
		return
	UI.set_tooltip_position(event.position, self.position + arms_options.position)
	UI.tooltip.show()

func _on_legs_options_gui_input(event: InputEvent) -> void:
	UI.tooltip.size.y = 20
	UI.tooltip.text = legs_options.tooltip_text
	if !UI.tooltip.text:
		hide_tooltip()
		return
	UI.set_tooltip_position(event.position, self.position + legs_options.position)
	UI.tooltip.show()

func _on_hp_container_gui_input(event: InputEvent) -> void:
	UI.tooltip.size.y = 20
	UI.tooltip.text = hp_container.tooltip_text
	if !UI.tooltip.text:
		hide_tooltip()
		return
	UI.set_tooltip_position(event.position, self.position + stats_container.position + hp_container.position)
	UI.tooltip.show()

func _on_mp_container_gui_input(event: InputEvent) -> void:
	UI.tooltip.size.y = 20
	UI.tooltip.text = mp_container.tooltip_text
	if !UI.tooltip.text:
		hide_tooltip()
		return
	UI.set_tooltip_position(event.position, self.position + stats_container.position + mp_container.position)
	UI.tooltip.show()

func _on_def_container_gui_input(event: InputEvent) -> void:
	UI.tooltip.size.y = 20
	UI.tooltip.text = def_container.tooltip_text
	if !UI.tooltip.text:
		hide_tooltip()
		return
	UI.set_tooltip_position(event.position, self.position + stats_container.position + def_container.position)
	UI.tooltip.show()

func _on_atk_container_gui_input(event: InputEvent) -> void:
	UI.tooltip.size.y = 20
	UI.tooltip.text = atk_container.tooltip_text
	if !UI.tooltip.text:
		hide_tooltip()
		return
	UI.set_tooltip_position(event.position, self.position + stats_container.position + atk_container.position)
	UI.tooltip.show()

func _on_sp_container_gui_input(event: InputEvent) -> void:
	UI.tooltip.size.y = 20
	UI.tooltip.text = sp_container.tooltip_text
	if !UI.tooltip.text:
		hide_tooltip()
		return
	UI.set_tooltip_position(event.position, self.position + stats_container.position + sp_container.position)
	UI.tooltip.show()

func _on_relic_spell_icon_gui_input(event: InputEvent) -> void:
	UI.tooltip.size.y = 20
	UI.tooltip.text = relic_spell_icon.tooltip_text
	if !UI.tooltip.text:
		hide_tooltip()
		return
	UI.set_tooltip_position(event.position, self.position + relic_spell_icon.position)
	UI.tooltip.show()
