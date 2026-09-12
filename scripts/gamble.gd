extends "res://assets/scripts/event.gd"

@onready var wizard: AnimatedSprite2D = $CanvasLayer/Wizard
@onready var gamble_animator: AnimationPlayer = $GambleAnimator
@onready var wizard_label: Label = $CanvasLayer/Wizard/WizardLabel
@onready var chest_1: Button = $CanvasLayer/Chest1
@onready var chest_2: Button = $CanvasLayer/Chest2
@onready var chest_3: Button = $CanvasLayer/Chest3
@onready var treasure_1: TextureRect = $CanvasLayer/Treasure1
@onready var treasure_2: TextureRect = $CanvasLayer/Treasure2
@onready var treasure_3: TextureRect = $CanvasLayer/Treasure3
@onready var choice_boxes: HBoxContainer = $UILayer/ChoiceBoxes
@onready var key_label: Label = $UILayer/ChoiceBoxes/KeyBox/KeyLabel
@onready var choose_label: Label = $UILayer/ChooseLabel
@onready var loot_display: ItemList = $UILayer/LootDisplay

@export var sfx_chest: AudioStream

const weapon_chance: float = 0.1
const magic_chance: float = 0.25

var chest_loot: Array = []
var chest_1_contents: Variant
var chest_2_contents: Variant
var chest_3_contents: Variant
var chests_clickable: bool = false
var best_loot: String = ""
var key_price: int 

func play_scene_intro() -> void:
	animation_player.play("scene_reveal")
	player_animator.play("entering_gamble")
	await player_animator.animation_finished
	if not GameManager.gamble_seen:
		display_message("\"Aha! A traveller!\"\n\n\"You see these treasures?\nObserve!\"")
		await(screen_text.text_finished) # Wait for text to finish animating
		await(get_tree().create_timer(GameManager.text_pause).timeout)
		await(get_tree().create_timer(2).timeout)
		wizard.play("cast")
		load_sfx(sfx_fog)
		sfx_player.play()
		await wizard.animation_finished
		wizard.play("cast_loop")
		gamble_animator.play("loot_hide")
		await gamble_animator.animation_finished
		set_treasure_positions()
		wizard.play("idle")
		display_message("\"I have an offer for you!\"")
		await(screen_text.text_finished) # Wait for text to finish animating
		await(get_tree().create_timer(GameManager.text_pause).timeout)
		await(get_tree().create_timer(1).timeout)
		display_message("\"If you buy this key from me, you can open one chest of your choosing!\"\n\n\"What do you say, Traveller?\"")
		await(screen_text.text_finished) # Wait for text to finish animating
		await(get_tree().create_timer(GameManager.text_pause).timeout)
		GameManager.gamble_seen = true
	else:
		display_message("\"We meet again, traveller!\"\n\n\"Allow me to tempt you once more.\"")
		await(screen_text.text_finished) # Wait for text to finish animating
		wizard.play("cast")
		load_sfx(sfx_fog)
		sfx_player.play()
		await wizard.animation_finished
		wizard.play("cast_loop")
		gamble_animator.play("loot_hide")
		await gamble_animator.animation_finished
		set_treasure_positions()
		wizard.play("idle")
	choice_boxes.show()

func set_stage_label() -> void:
	stage_label.text = "Gamble"

func set_rewards() -> void:
	set_key_price()
	var add_weapon: bool = false
	var add_spell: bool = false
	var add_armour: bool = false
	var order: Array = [1,2,3]
	if weapon_chance >= randf():
		add_weapon = true
	elif magic_chance >= randf():
		add_spell = true
	else:
		add_armour = true
	for x in range(3):
		if add_weapon:
			add_weapon = false
			if not generate_weapon():
				if not generate_magic():
					generate_armour()
		elif add_spell:
			add_spell = false
			if not generate_magic():
				generate_armour()
		elif add_armour:
			add_armour = false
			generate_armour()
		else:
			generate_item()
	set_treasure_icons()
	for loot in chest_loot:
		var chest_num: int = order.pick_random()
		order.erase(chest_num)
		match chest_num:
			1:
				chest_1_contents = loot
				if !best_loot:
					best_loot = "chest_1"
					chest_1.icon = GameManager.icons["chest2"]
			2:
				chest_2_contents = loot
				if !best_loot:
					best_loot = "chest_2"
					chest_2.icon = GameManager.icons["chest2"]
			3:
				chest_3_contents = loot
				if !best_loot:
					best_loot = "chest_3"
					chest_3.icon = GameManager.icons["chest2"]

func set_key_price() -> void:
	if GameManager.level < 90:
		key_price = GameManager.gamble_base_cost * ((GameManager.level / 10) + 1)
	else:
		key_price = GameManager.gamble_base_cost * 10
	key_label.text = "Buy\n-%dG" % [key_price]

func set_treasure_icons() -> void:
	treasure_1.texture = chest_loot[0].icon
	treasure_2.texture = chest_loot[1].icon
	treasure_3.texture = chest_loot[2].icon

func set_treasure_positions() -> void:
	treasure_1.texture = chest_1_contents.icon
	treasure_2.texture = chest_2_contents.icon
	treasure_3.texture = chest_3_contents.icon

func display_rewards(loot: Variant) -> void:
	# Add loot to the list of rewards
	loot_display.add_item(loot.name, loot.icon, false)
	loot_display.set_item_tooltip(-1, loot.tooltip)
	loot_display.set_item_custom_fg_color(-1, GameManager.get_quality_colour(loot.quality))
	# Show loot display
	loot_display.show()
	gamble_animator.play("loot_popup")
	await(get_tree().create_timer(1.2).timeout)

func generate_weapon() -> bool:
	var weapon: Weapon
	var selected: int
	var best_weapon_owned: int = 0
	for owned in GameManager.stored_weapons:
		if owned.id > best_weapon_owned:
			best_weapon_owned = owned.id
	if best_weapon_owned == 0:
		selected = 1
	elif best_weapon_owned == 1 and GameManager.level > 25:
		selected = 2
	elif best_weapon_owned == 2 and GameManager.level > 50:
		selected = 3
	elif best_weapon_owned == 3 and GameManager.level > 75:
		selected = 4
	else:
		selected = -1
	if selected != -1: # Add the weapon if no copies found in player storage
		weapon = GameManager.create_weapon(selected)
		chest_loot.append(weapon)
		weapon.storage_index = chest_loot.size() - 1
		return true
	else: # If duplicate weapon is found, skip adding
		return false

func generate_magic() -> bool:
	var magic: Magic
	var stock_chance: int = randi() % round(((GameManager.max_level * GameManager.max_level) / GameManager.level) + 1)
	var options: Array = []
	if GameManager.level < stock_chance: # Select a random early-game spell
		options = range(1,5)
	else: # Select a random late-game spell
		options = range(6,11)
	for y in GameManager.stored_magic.size(): # Prevents seeing a spell that's already owned
		if GameManager.stored_magic[y].id in options:
			options.erase(GameManager.stored_magic[y].id)
	if options: # If there's still options left, pick one at random and add it to chest
		magic = GameManager.create_magic(options.pick_random())
		chest_loot.append(magic)
		magic.storage_index = chest_loot.size() - 1
		return true
	else: # If no options left, prevent adding
		return false
	
func generate_armour() -> void:
	var selected: int
	if GameManager.level < 11: # Select a random quality 1 armour piece
		selected = randi_range(0,3)
	elif GameManager.level < 21: # Select a random quality 1 or 2 armour piece
		selected = randi_range(0,7)
	elif GameManager.level < 41: # Select a random quality 2 armour piece
		selected = randi_range(4,11)
	elif GameManager.level < 61: # Select a random quality 3 armour piece
		selected = randi_range(12,19)
	elif GameManager.level < 81: # Select a random quality 3 or 4 armour piece
		selected = randi_range(12,23)
	elif GameManager.level < 91: # Select a random quality 4 or 5 armour piece
		selected = randi_range(20,27)
	else: # Select a random quality 5 armour piece
		selected = randi_range(24,27)
	chest_loot.append(GameManager.create_armour(selected))

func generate_item() -> void:
	var loot_chance: int = randi() % round(((GameManager.max_level * GameManager.max_level) / GameManager.level) + 1)
	var selected: int
	if GameManager.level < loot_chance: # Select an early-game item
		selected = randi_range(1,4)
	else: # Select a late-game item
		selected = randi_range(5,10)
	chest_loot.append(GameManager.create_item(selected))

func play_hover_sfx() -> void:
	load_ui_sfx(sfx_hover)
	ui_player.play()

func _on_buy_button_pressed() -> void:
	choice_boxes.hide()
	GameManager.set_coins(-key_price)
	update_coin_label()
	load_ui_sfx(sfx_confirm)
	ui_player.play()
	gamble_animator.play("reveal_choose_label")
	await gamble_animator.animation_finished
	chests_clickable = true

func _on_leave_button_pressed() -> void:
	choice_boxes.hide()
	load_ui_sfx(sfx_confirm)
	ui_player.play()
	display_message("\"No interest?\"\n\n\"Hmph. I would've expected a bolder choice from someone like you.\"")
	await(screen_text.text_finished) # Wait for text to finish animating
	await(get_tree().create_timer(GameManager.text_pause).timeout)
	# Play leaving animation
	player_sprite.play("run")
	player_animator.play("leaving_gamble")
	# Play fade animation
	animation_player.play("scene_fade")
	await(get_tree().create_timer(2.5).timeout)
	# Pre-transition storing, updating, and cleaning
	GameManager.refresh_storage() # Clean up any empty storage entries
	# Change scene
	var next_scene: String = get_next_scene()
	get_tree().change_scene_to_file(GameManager.scenes[next_scene])

func _on_chest_1_pressed() -> void:
	if chests_clickable:
		chests_clickable = false
		chest_1.hide()
		treasure_1.show()
		choose_label.hide()
		load_sfx(sfx_chest)
		sfx_player.play()
		GameManager.store_rewards([chest_1_contents], 0) # Add rewards to GameManager
		await(get_tree().create_timer(1).timeout)
		if best_loot == "chest_1":
			display_message("\"Oho! Fortune smiles upon you, Traveller.\"")
		else:
			display_message("\"Ah, not what you were hoping for?\nBetter luck next time, Traveller.\"")
		await(screen_text.text_finished) # Wait for text to finish animating
		await(get_tree().create_timer(GameManager.text_pause).timeout)
		chest_2.hide()
		treasure_2.show()
		load_sfx(sfx_chest)
		sfx_player.play()
		await(get_tree().create_timer(1).timeout)
		chest_3.hide()
		treasure_3.show()
		load_sfx(sfx_chest)
		sfx_player.play()
		await(get_tree().create_timer(1).timeout)
		display_rewards(chest_1_contents)

func _on_chest_1_mouse_entered() -> void:
	if chests_clickable:
		if not chest_1.expand_icon:
			play_hover_sfx()
		chest_2.expand_icon = false
		chest_3.expand_icon = false
		chest_1.expand_icon = true

func _on_chest_2_pressed() -> void:
	if chests_clickable:
		chests_clickable = false
		chest_2.hide()
		treasure_2.show()
		choose_label.hide()
		load_sfx(sfx_chest)
		sfx_player.play()
		GameManager.store_rewards([chest_2_contents], 0) # Add rewards to GameManager
		await(get_tree().create_timer(1).timeout)
		if best_loot == "chest_2":
			display_message("\"Oho! Fortune smiles upon you, Traveller.\"")
		else:
			display_message("\"Ah, not what you were hoping for?\nBetter luck next time, Traveller.\"")
		await(screen_text.text_finished) # Wait for text to finish animating
		await(get_tree().create_timer(GameManager.text_pause).timeout)
		chest_1.hide()
		treasure_1.show()
		load_sfx(sfx_chest)
		sfx_player.play()
		await(get_tree().create_timer(1).timeout)
		chest_3.hide()
		treasure_3.show()
		load_sfx(sfx_chest)
		sfx_player.play()
		await(get_tree().create_timer(1).timeout)
		display_rewards(chest_2_contents)

func _on_chest_2_mouse_entered() -> void:
	if chests_clickable:
		if not chest_2.expand_icon:
			play_hover_sfx()
		chest_1.expand_icon = false
		chest_3.expand_icon = false
		chest_2.expand_icon = true

func _on_chest_3_pressed() -> void:
	if chests_clickable:
		chests_clickable = false
		chest_3.hide()
		treasure_3.show()
		choose_label.hide()
		load_sfx(sfx_chest)
		sfx_player.play()
		GameManager.store_rewards([chest_3_contents], 0) # Add rewards to GameManager
		await(get_tree().create_timer(1).timeout)
		if best_loot == "chest_3":
			display_message("\"Oho! Fortune smiles upon you, Traveller.\"")
		else:
			display_message("\"Ah, not what you were hoping for?\nBetter luck next time, Traveller.\"")
		await(screen_text.text_finished) # Wait for text to finish animating
		await(get_tree().create_timer(GameManager.text_pause).timeout)
		chest_1.hide()
		treasure_1.show()
		load_sfx(sfx_chest)
		sfx_player.play()
		await(get_tree().create_timer(1).timeout)
		chest_2.hide()
		treasure_2.show()
		load_sfx(sfx_chest)
		sfx_player.play()
		await(get_tree().create_timer(1).timeout)
		display_rewards(chest_3_contents)

func _on_chest_3_mouse_entered() -> void:
	if chests_clickable:
		if not chest_3.expand_icon:
			play_hover_sfx()
		chest_1.expand_icon = false
		chest_2.expand_icon = false
		chest_3.expand_icon = true

func _on_loot_display_gui_input(event: InputEvent) -> void:
	var index: int = loot_display.get_item_at_position(event.position, true)
	if index == -1: hide_tooltip()
	else:
		UI.tooltip.size.y = 20
		UI.tooltip.text = loot_display.get_item_tooltip(index)
		if !UI.tooltip.text:
			hide_tooltip()
			return
		UI.set_tooltip_position(event.position, loot_display.position)
		UI.tooltip.show()

func end_scene() -> void:
	loot_display.hide()
	load_ui_sfx(sfx_loot)
	ui_player.play()
	# Wait briefly
	await(get_tree().create_timer(0.2).timeout)
	# Play leaving animation
	player_sprite.play("run")
	player_animator.play("leaving_gamble")
	# Play fade animation
	animation_player.play("scene_fade")
	await(get_tree().create_timer(2.5).timeout)
	# Pre-transition storing, updating, and cleaning
	GameManager.refresh_storage() # Clean up any empty storage entries
	# Change scene
	var next_scene: String = get_next_scene()
	get_tree().change_scene_to_file(GameManager.scenes[next_scene])
