extends Node

@onready var weapon_display: ItemList = $WeaponDisplay
@onready var magic_display: ItemList = $MagicDisplay
@onready var item_display: ItemList = $ItemDisplay
@onready var misc_display: ItemList = $MiscDisplay
@onready var equipment_menu: Panel = $EquipmentMenu
@onready var ui_audio: AudioStreamPlayer = $UIAudio
# SFX
@export var sfx_confirm: AudioStream
@export var sfx_hover: AudioStream
@export var sfx_loot: AudioStream
# Signals
signal weapon_used(skill: Skill)
signal magic_used(spell: Magic)
signal item_used(item: Item)
signal send_message(text: String, hide: bool, wait: bool)
signal stats_changed
signal restart_pressed

var active_menu: String = "none"

func _ready() -> void:
	display_skills()
	display_items()
	display_spells()
	display_misc()

func load_sfx(sfx_to_load:AudioStream) -> void:
	if ui_audio.stream != sfx_to_load:
		ui_audio.stop()
		ui_audio.stream = sfx_to_load

func display_skills() -> void:
	weapon_display.clear() # Clears displayed skills from any previously-equipped weapon
	var skills: Array = []
	if is_instance_valid(GameManager.player_weapon):
		skills = GameManager.player_weapon.skills # Checks the skills on the weapon
	var display_name: String # Used to assign text in weapon_display
	for x in range(skills.size()): # Iterates through the list of skills and displays them
		display_name = "%s - %s" % [skills[x].name, skills[x].type] # Set skill display text
		weapon_display.add_item(display_name, skills[x].icon, true) # Add to itemlist
		skills[x].display_index = weapon_display.get_item_count() - 1 # Store display index
		weapon_display.set_item_tooltip(skills[x].display_index, skills[x].tooltip) # Add tooltip
		weapon_display.set_item_metadata(skills[x].display_index, skills[x]) # Add skill id to metadata

func display_items() -> void:
	item_display.clear() # Clears displayed skills from any previously-equipped weapon
	var item: Item
	var display_name: String
	# Displays all items in stored_items
	for x in GameManager.stored_items.size():
		item = GameManager.stored_items[x] # Get the item
		# Change display text based on item uses remaining
		if item.uses > 1: 
			display_name = "%s - %s (%d uses)" % [item.name, item.type, item.uses]
		elif item.uses == 1:
			display_name = "%s - %s (1 use)" % [item.name, item.type]
		else:
			display_name = "%s - %s" % [item.name, item.type]
		item_display.add_item(display_name, item.icon, true) # Display item in inventory list
		item.display_index = item_display.get_item_count() - 1 # Attach the display index to the item
		item_display.set_item_tooltip(item.display_index, item.tooltip) # Add tooltip
		item_display.set_item_metadata(item.display_index, item) # Add ID to the item list metadata

func display_spells() -> void:
	magic_display.clear()
	var spell: Magic
	var display_name: String
	if is_instance_valid(GameManager.player_relic):
		spell = GameManager.player_relic.spell # Get the spell
		display_name = "%s (%d MP)" % [spell.name, spell.cost] # Set spell display text
		magic_display.add_item(display_name, spell.icon, true) # Display spell in inventory list
		spell.display_index = magic_display.get_item_count() - 1 # Attach the display index to the spell
		magic_display.set_item_tooltip(spell.display_index, spell.tooltip) # Add tooltip
		magic_display.set_item_metadata(spell.display_index, spell) # Add ID to the magic list metadata
		magic_display.set_item_custom_fg_color(-1, GameManager.get_quality_colour(GameManager.player_relic.quality)) 
	for x in GameManager.stored_magic.size():
		spell = GameManager.stored_magic[x] # Get the spell
		display_name = "%s - %s (%d MP)" % [spell.name, spell.type, spell.cost] # Set spell display text
		magic_display.add_item(display_name, spell.icon, true) # Display spell in inventory list
		spell.display_index = magic_display.get_item_count() - 1 # Attach the display index to the spell
		magic_display.set_item_tooltip(spell.display_index, spell.tooltip) # Add tooltip
		magic_display.set_item_metadata(spell.display_index, spell) # Add ID to the magic list metadata

func display_misc() -> void:
	misc_display.clear()
	# Display misc options in misc_display
	misc_display.add_item("Equipment", GameManager.icons["equipment"], true)
	misc_display.set_item_tooltip_enabled(-1, false)
	misc_display.add_item("Options", GameManager.icons["options"], true)
	misc_display.set_item_tooltip_enabled(-1, false)
	misc_display.add_item("Help", GameManager.icons["help"], true)
	misc_display.set_item_tooltip_enabled(-1, false)
	misc_display.add_item("Exit to Main Menu", GameManager.icons["restart"], true)
	misc_display.set_item_tooltip_enabled(-1, false)
	misc_display.add_item("Quit Game", GameManager.icons["disabled"], true)
	misc_display.set_item_tooltip_enabled(-1, false)

func toggle_menu(new_menu):
	# Check if menu is already open, then call the relevant open/close func
	if new_menu == active_menu:
		close_menu()
	else:
		close_menu()
		open_menu(new_menu)

func close_menu() -> void:
	# Closes the current open menu
	if active_menu != "none":
		match active_menu:
			"weapon_display":
				weapon_display.deselect_all()
				weapon_display.hide()
			"magic_display":
				magic_display.deselect_all()
				magic_display.hide()
			"item_display":
				item_display.deselect_all()
				item_display.hide()
			"misc_display":
				misc_display.deselect_all()
				misc_display.hide()
			"equipment_menu":
				equipment_menu.hide()
			_:
				printerr("ERROR: Menu not found in 'close_menu()'")
		active_menu = "none"
		hide_tooltip()

func open_menu(new_menu) -> void:
	# Opens the selected menu
	match new_menu:
		"weapon_display":
			weapon_display.show()
		"magic_display":
			magic_display.show()
		"item_display":
			item_display.show()
		"misc_display":
			misc_display.show()
		"equipment_menu":
			equipment_menu.show()
		_:
			printerr("ERROR: Menu not found in 'open_menu()'")
	active_menu = new_menu

func _on_weapon_display_item_selected(index: int) -> void:
	close_menu() # Close the menu after selecting an action
	load_sfx(sfx_confirm) # Load confirm sound
	ui_audio.play() # Play confirm sound
	# Find the skill in the metadata
	var skill: Skill = weapon_display.get_item_metadata(index)
	# Signal the battle script
	weapon_used.emit(skill)

func _on_magic_display_item_selected(index: int) -> void:
	close_menu() # Close the menu after selecting an action
	load_sfx(sfx_confirm) # Load confirm sound
	ui_audio.play() # Play confirm sound
	# Find the spell in the metadata
	var spell: Magic = magic_display.get_item_metadata(index)
	# Check if player has enough MP to use spell
	if spell.cost > GameManager.player_MP: # Don't use spell if MP too low
		var text: String = "Not enough MP to cast %s." % [spell.name]
		send_message.emit(text, true, true) 
	else:
		# Signal the battle script and use spell
		magic_used.emit(spell)

func _on_item_display_item_selected(index: int) -> void:
	close_menu() # Close the menu after selecting an action
	load_sfx(sfx_confirm) # Load confirm sound
	ui_audio.play() # Play confirm sound
	# Find the item ID in the metadata
	var item: Item = item_display.get_item_metadata(index)
	if item.uses > 0: # Check to see if item has uses left and remove one
		item.uses -= 1
		if item.uses == 0: # Remove item if no uses left
			item_display.remove_item(index)
		else:
			GameManager.update_item_tooltip(item)
			item_display.set_item_tooltip(index, item.tooltip)
			item_display.set_item_text(index, "%s - %s (%d uses)" % [item.name, item.type, item.uses])
	# Signal the battle script and use item
	item_used.emit(item)
	
func _on_misc_display_item_selected(index: int) -> void:
	load_sfx(sfx_confirm) # Load confirm sound
	ui_audio.play() # Play confirm sound
	match misc_display.get_item_text(index):
		"Equipment":
			toggle_menu("equipment_menu")
		"Options":
			close_menu()
			UI.toggle_options_menu()
		"Help":
			close_menu()
			UI.toggle_help_menu()
		"Exit to Main Menu":
			close_menu()
			restart_pressed.emit()
		"Quit Game":
			get_tree().quit()
	misc_display.deselect_all()

func _on_item_display_gui_input(event: InputEvent) -> void:
	var index: int = item_display.get_item_at_position(event.position, true)
	if index == -1: hide_tooltip()
	else:
		UI.tooltip.size.y = 20
		UI.tooltip.text = item_display.get_item_tooltip(index)
		if !UI.tooltip.text:
			hide_tooltip()
			return
		UI.set_tooltip_position(event.position, item_display.position)
		UI.tooltip.show()

func _on_weapon_display_gui_input(event: InputEvent) -> void:
	var index: int = weapon_display.get_item_at_position(event.position, true)
	if index == -1: hide_tooltip()
	else:
		UI.tooltip.size.y = 20
		UI.tooltip.text = weapon_display.get_item_tooltip(index)
		if !UI.tooltip.text:
			hide_tooltip()
			return
		UI.set_tooltip_position(event.position, weapon_display.position)
		UI.tooltip.show()

func _on_magic_display_gui_input(event: InputEvent) -> void:
	var index: int = magic_display.get_item_at_position(event.position, true)
	if index == -1: hide_tooltip()
	else:
		UI.tooltip.size.y = 20
		UI.tooltip.text = magic_display.get_item_tooltip(index)
		if !UI.tooltip.text:
			hide_tooltip()
			return
		UI.set_tooltip_position(event.position, magic_display.position)
		UI.tooltip.show()

func hide_tooltip() -> void:
	UI.tooltip.hide()
	UI.tooltip.size.y = 20

func update_stat_labels() -> void:
	equipment_menu.update_stat_labels()

func _on_equipment_menu_stats_changed() -> void:
	stats_changed.emit()
