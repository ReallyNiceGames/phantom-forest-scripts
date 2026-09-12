extends Node
# References
@onready var player_container: VBoxContainer = $CanvasLayer/PlayerContainer
@onready var enemy_container: VBoxContainer = $CanvasLayer/EnemyContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var screen_text: Label = %ScreenText
@onready var battle_buttons: PanelContainer = $CanvasLayer/BattleButtons
@onready var loot_display: ItemList = $CanvasLayer/LootDisplay
@onready var game_over_menu: PanelContainer = $CanvasLayer/GameOverMenu
@onready var stage_label: Label = $CanvasLayer/Stage
@onready var enemy_status_display: ItemList = $CanvasLayer/EnemyStatusDisplay
@onready var player_status_display: ItemList = $CanvasLayer/PlayerStatusDisplay
@onready var coin_label: Label = $CanvasLayer/CoinLabel
@onready var inventory: Control = %Inventory
@onready var background: TextureRect = $CanvasLayer/Background
@onready var sfx_player: AudioStreamPlayer = $SfxPlayer
@onready var zone: Label = $CanvasLayer/Zone
# Exports
@export var sfx_sword: AudioStream
@export var sfx_miss: AudioStream
@export var sfx_fireball: AudioStream
@export var sfx_explosion: AudioStream
@export var sfx_block: AudioStream
@export var sfx_buff: AudioStream
@export var sfx_debuff: AudioStream
@export var sfx_fear: AudioStream
@export var sfx_throw: AudioStream
@export var sfx_heal: AudioStream
@export var sfx_swipe: AudioStream
@export var sfx_impact: AudioStream
@export var sfx_screech: AudioStream
@export var sfx_fog: AudioStream
@export var sfx_siphon: AudioStream
@export var sfx_leech: AudioStream
@export var sfx_runikesh_flame: AudioStream
@export var sfx_phantom_retreat: AudioStream
@export var sfx_buster: AudioStream
@export var sfx_break: AudioStream
# Signals
signal turn_change
# Constants
const zone_names = {
	0: "Mistborne Meadows",
	1: "Darkwoven Woods",
	2: "Deepwood Haze",
	3: "Fiendfelled Peaks",
	4: "Ecliptic Outskirts",
	5: "Craven's Dread"
}
# Strings for SFX
@onready var sfx = {
	"sword": sfx_sword,
	"miss": sfx_miss,
	"fireball": sfx_fireball,
	"explosion": sfx_explosion,
	"block": sfx_block,
	"buff": sfx_buff,
	"debuff": sfx_debuff,
	"fear": sfx_fear,
	"throw": sfx_throw,
	"heal": sfx_heal,
	"swipe": sfx_swipe,
	"impact": sfx_impact,
	"screech": sfx_screech,
	"fog": sfx_fog,
	"siphon": sfx_siphon,
	"leech": sfx_leech,
	"runikesh_flame": sfx_runikesh_flame,
	"phantom_retreat": sfx_phantom_retreat,
	"buster": sfx_buster
}
# Scene vars
var player_alive: bool = true
var player_turn_skip: bool = false
var player_turn_speed: float = 1.0
var player_buffs: Array = []
var player_debuffs: Array = []
var animating_text: bool = false
var loot_reward: Array = []
var coin_reward: int = 0
var enemy: Enemy
var enemy_next_action: int = -1
var fade_music_out: bool = false
var fade_music_in: bool = false
var event_playing: bool = false
var intro_playing: bool = true
var outro_playing: bool = false
var loading: bool = false
# Node refs
var player_sprite: AnimatedSprite2D
var enemy_sprite: AnimatedSprite2D
var enemy_animator: AnimationPlayer
var player_animator: AnimationPlayer
var player_health_bar: ProgressBar
var player_magic_bar: ProgressBar
var enemy_health_bar: ProgressBar
var weapon_button: Button
var magic_button: Button
var item_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_enemy()
	set_background()
	stage_label.text = "Stage: %d" % [GameManager.level]
	update_coin_label()
	set_node_refs()
	set_resource_bar(player_health_bar, GameManager.player_HP, GameManager.player_max_HP)
	set_resource_bar(enemy_health_bar, enemy.HP, enemy.max_HP)
	set_resource_bar(player_magic_bar, GameManager.player_MP, GameManager.player_max_MP)
	set_rewards()
	set_music()
	play_scene_intro()

func _process(delta:float) -> void:
	if fade_music_in:
		GameManager.music_volume += GameManager.music_fade_rate * delta
		if GameManager.music_volume >= GameManager.music_volume_limit:
			GameManager.music_volume = GameManager.music_volume_limit
			fade_music_in = false
		set_music_volume(GameManager.music_volume)
	elif fade_music_out:
		GameManager.music_volume -= GameManager.music_fade_rate * delta
		if GameManager.music_volume <= 0:
			GameManager.music_volume = 0
			fade_music_out = false
		set_music_volume(GameManager.music_volume)

func play_scene_intro() -> void:
	battle_buttons.hide()
	animation_player.play("scene_reveal")
	player_animator.play("entering_scene")
	await(get_tree().create_timer(1.2).timeout)
	player_sprite.play("idle")
	match GameManager.level:
		1,20,40,60,80,101:
			display_zone_label()
	if enemy.type == "boss":
		match enemy.name:
			"Phantom":
				display_message("??? blocks your way!\n\n\"...?!\"")
			"Runikesh":
				display_message("Runikesh harnesses the\nancient power of the cemetery!\n\n\"No esssscape...\"")
	else:
		display_message("%s blocks your way!" % [enemy.name])
	battle_buttons.show()
	intro_playing = false

func display_zone_label() -> void:
	match GameManager.level:
		1:
			zone.text = zone_names[0]
		20:
			zone.text = zone_names[1]
		40:
			zone.text = zone_names[2]
		60:
			zone.text = zone_names[3]
		80:
			zone.text = zone_names[4]
		101:
			zone.text = zone_names[5]
	zone.show()
	await(get_tree().create_timer(4).timeout)
	animation_player.queue("zone_fade")

func set_enemy() -> void:
	var id: int = GameManager.enemy_id
	# Prevent same enemy appearing twice in a row
	while id == GameManager.enemy_id: 
		id = GameManager.get_enemy_id()
	# Create new enemy from ID and store ID
	enemy = GameManager.create_enemy(id)
	GameManager.enemy_id = id
	# Check for special enemy, if not then use typical naming system
	if enemy.name == "Runikesh":
		enemy_sprite = enemy_container.get_node("Sprites/Phantom")
	else:
		enemy_sprite = enemy_container.get_node("Sprites/" + enemy.name)
	enemy.set_stats(enemy_sprite.get_stats())
	enemy_sprite.show()
	enemy_sprite.play("idle")
	enemy_container.get_node("Name").text = enemy.full_name

func set_background() -> void:
	if GameManager.level < 20:
		background.texture = GameManager.backgrounds["background1"]
	elif GameManager.level < 40:
		background.texture = GameManager.backgrounds["background2"]
	elif GameManager.level < 60:
		background.texture = GameManager.backgrounds["background3"]
	elif GameManager.level < 80:
		background.texture = GameManager.backgrounds["background4"]
	elif GameManager.level < 100:
		background.texture = GameManager.backgrounds["background5"]
	elif GameManager.level == 100:
		background.texture = GameManager.backgrounds["background6"]
	else:
		background.texture = GameManager.backgrounds["background7"]

func set_rewards() -> void:
	if GameManager.level == 100:
		loot_reward.append(GameManager.create_armour(randi_range(24,27)))
		loot_reward.append(GameManager.create_armour(randi_range(24,27)))
		loot_reward.append(GameManager.create_magic(12))
		coin_reward = 1000
	elif GameManager.level == 50:
		loot_reward.append(GameManager.create_armour(randi_range(12,19)))
		coin_reward = 200
	else:
		loot_reward = GameManager.generate_loot()
		coin_reward = GameManager.generate_coins()

func set_music() -> void:
	if GameManager.level < 20:
		GameManager.play_music("stage1")
	elif GameManager.level < 40:
		GameManager.play_music("stage20")
	elif GameManager.level < 60:
		GameManager.play_music("stage40")
	elif GameManager.level < 80:
		GameManager.play_music("stage60")
	elif GameManager.level < 100:
		GameManager.play_music("stage80")
	elif GameManager.level == 100:
		GameManager.play_music("boss1")
	else:
		GameManager.play_music("stage101")
	if GameManager.music_volume != GameManager.music_volume_limit:
		set_music_fade("in")

func set_music_volume(amount:float) -> void:
	if amount > GameManager.music_volume_limit:
		amount = GameManager.music_volume_limit
	GameManager.music_volume = amount
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(amount))

func set_music_fade(fade:String, on:bool = true) -> void:
	if on:
		if fade == "out":
			fade_music_out = true
		elif fade == "in":
			fade_music_in = true
	else:
		if fade == "out":
			fade_music_out = false
		elif fade == "in":
			fade_music_in = false

func set_node_refs() -> void:
	player_sprite = player_container.get_node("Player")
	player_health_bar = player_container.get_node("ResourceContainer/HealthBar")
	player_magic_bar = player_container.get_node("ResourceContainer/MagicBar")
	player_animator = player_container.get_node("AnimationPlayer")
	enemy_health_bar = enemy_container.get_node("ResourceContainer/HealthBar")
	enemy_animator = enemy_container.get_node("AnimationPlayer")
	weapon_button = battle_buttons.get_node("VBoxContainer/HBoxContainer/WeaponButton")
	magic_button = battle_buttons.get_node("VBoxContainer/HBoxContainer/MagicButton")
	item_button = battle_buttons.get_node("VBoxContainer/HBoxContainer2/ItemButton")

func set_resource_bar(bar:ProgressBar, new_value:int, max_value:int) -> void:
	# Assign new values to the progress bar
	bar.max_value = max_value
	bar.value = new_value
	# Update the bar's label based on the type of bar
	match bar.name:
		"HealthBar":
			bar.get_node("Label").text = "HP: %d/%d" % [new_value, max_value]
		"MagicBar":
			bar.get_node("Label").text = "MP: %d/%d" % [new_value, max_value]
		_:
			printerr("ERROR: Resource bar not found")
	
func use_enemy_action() -> void:
	var turn_speed: float = 0.0
	while enemy.speed >= randf() + turn_speed and player_alive:
		if turn_speed > 0.0:
			display_message("%s prepares to attack again!" % enemy.name)
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
		turn_speed += 1.0
		var action: Action
		if enemy_next_action == -1:
			action = enemy.get_random_action()
		else:
			action = enemy.get_action(enemy_next_action)
			enemy_next_action = -1
		# Change battle text
		display_message(action.text)
		await(screen_text.text_finished) # Wait for text to finish animating
		await(get_tree().create_timer(GameManager.text_pause).timeout)
		# Play enemy animations/sounds
		if action.self_sprite and not GameManager.hide_battle_anims: # Use enemy sprite animation
			enemy_sprite.play(action.self_sprite)
			if action.self_sprite_sfx: # Pair a sound with the anim
				load_sfx(sfx[action.self_sprite_sfx])
				await(get_tree().create_timer(0.3).timeout)
				sfx_player.play()
			# Get frame total of current anim and divide by arbitrary value to get approximate delay for anim
			#var frames: float = enemy_sprite.sprite_frames.get_frame_count(action.self_sprite)
			#await(get_tree().create_timer(frames/8).timeout) # Wait for animation to finish
			await enemy_sprite.animation_finished
			enemy_sprite.play("idle")
		if action.battle_anim and not GameManager.hide_battle_anims: # Use battle animation player
			animation_player.queue(action.battle_anim)
			if action.battle_anim_sfx: # Pair a sound with the anim
				load_sfx(sfx[action.battle_anim_sfx])
				sfx_player.play()
			await animation_player.animation_finished
		if action.self_anim: # Use enemy animation player
			enemy_animator.queue(action.self_anim)
			if action.self_anim_sfx: # Pair a sound with the anim
				load_sfx(sfx[action.self_anim_sfx])
				sfx_player.play()
		# Add any status effects
		if action.statuses_to_apply:
			for status in action.statuses_to_apply:
				store_status(status)
			display_status() # Display the status effects
		# Set stat changes
		if action.player_HP_damage: # Decrease player HP
			set_player_HP(-action.player_HP_damage)
		if action.player_HP_degen: # Decrease player HP regen
			GameManager.player_HP_regen -= action.player_HP_degen
		if action.player_MP_damage: # Decrease player MP
			set_player_MP(-action.player_MP_damage)
		if action.player_def_down: # Decrease player defence
			GameManager.player_temp_defence -= action.player_def_down
		if action.player_speed_down: # Decrease player speed
			GameManager.player_speed -= action.player_speed_down
		if action.player_accuracy_down: # Decrease player accuracy
			GameManager.player_accuracy -= action.player_accuracy_down
		if action.player_disable_weapon: # Disable weapon skills
			weapon_button.disabled = true
		if action.player_disable_magic: # Disable magic spells
			magic_button.disabled = true
		if action.player_disable_items: # Disable items
			item_button.disabled = true
		if action.self_HP_heal: # Increase enemy HP
			set_enemy_HP(action.self_HP_heal)
		# Play player animations/sounds
		if action.player_anim: # Use player animation player
			player_animator.queue(action.player_anim)
			if action.player_anim_sfx: # Pair a sound with the anim
				load_sfx(sfx[action.player_anim_sfx])
				sfx_player.play()
		if action.player_sprite and not GameManager.hide_battle_anims: # Use player sprite animation
			player_sprite.play(action.player_sprite)
			if action.player_sprite_sfx: # Pair a sound with the anim
				load_sfx(sfx[action.player_sprite_sfx])
				sfx_player.play()
			await player_sprite.animation_finished
			if player_alive:
				player_sprite.play("idle")
	if turn_speed == 0.0:
		display_message("%s is too slow to get going." % enemy.name)
		await(screen_text.text_finished) # Wait for text to finish animating
		await(get_tree().create_timer(GameManager.text_pause).timeout)
	turn_change.emit() # Signal for the turn to change

func set_enemy_HP(health_change:int) -> void:
	if enemy.is_alive:
		# Update the GameManager enemy health value
		enemy.HP = max(0, enemy.HP + health_change)
		# Prevent the HP change from exceeding the limit
		if enemy.HP > enemy.max_HP:
			enemy.HP = enemy.max_HP
		# Display the change on the enemy health bar
		set_resource_bar(enemy_health_bar, enemy.HP, enemy.max_HP)
		# Check if enemy HP has reached 0
		if enemy.HP <= 0:
			# Check to see if the player loses in a tie
			if GameManager.player_wins_tiebreaks:
				enemy.is_alive = false
			else:
				if player_alive:
					enemy.is_alive = false

func set_player_HP(health_change:int) -> void:
	if player_alive:
		# Update the GameManager player health value
		GameManager.player_HP = max(0, GameManager.player_HP + health_change)
		# Prevent the HP change from exceeding the limit
		if GameManager.player_HP > GameManager.player_max_HP:
			GameManager.player_HP = GameManager.player_max_HP
		# Display the change on the player health bar
		set_resource_bar(player_health_bar, GameManager.player_HP, GameManager.player_max_HP)
		# Check if player HP is 0
		if GameManager.player_HP <= 0:
			player_alive = false
			if not GameManager.player_wins_tiebreaks:
				enemy.is_alive = true # Player loses in a tie

func set_player_MP(magic_change:int) -> void:
	if player_alive:
		# Update the GameManager player magic value
		GameManager.player_MP = max(0, GameManager.player_MP + magic_change)
		# Prevent the MP change from exceeding the limit
		if GameManager.player_MP > GameManager.player_max_MP:
			GameManager.player_MP = GameManager.player_max_MP
		# Display the change on the player magic bar
		set_resource_bar(player_magic_bar, GameManager.player_MP, GameManager.player_max_MP)

func load_sfx(sfx_to_load:AudioStream) -> void:
	if sfx_player.stream != sfx_to_load:
		sfx_player.stop()
		sfx_player.stream = sfx_to_load

func display_rewards() -> void:
	# Add coins to the list of rewards
	loot_display.add_item("%dG" % [coin_reward], GameManager.icons["coin"], false)
	# Add loot to the list of rewards
	for loot in loot_reward:
		loot_display.add_item(loot.name, loot.icon, false)
		loot_display.set_item_tooltip(-1, loot.tooltip)
		loot_display.set_item_custom_fg_color(-1, GameManager.get_quality_colour(loot.quality))
	# Show loot display
	loot_display.show()
	animation_player.play("loot_popup")
	await(get_tree().create_timer(1.2).timeout)

func begin_enemy_turn() -> void:
	display_status() # Display the status effects
	# Begin enemy's turn if alive
	if enemy.is_alive:
		# Chooses and performs the action an enemy will take on their turn
		use_enemy_action() 
		await(turn_change) # Wait for the enemy action to finish
		# Count down buff/debuff durations and apply their effects
		update_player_status()
		update_enemy_status()
		display_status() # Display the status effects
		# Begin player's turn if both are alive
		if enemy.is_alive:
			if player_alive:
				if not player_turn_skip:
					begin_player_turn() # Prepare variables for player's turn
				else:
					player_turn_skip = false
					display_message("You struggle to move fast enough to take your turn...")
					await(screen_text.text_finished) # Wait for text to finish animating
					await(get_tree().create_timer(GameManager.text_pause).timeout)
					begin_enemy_turn()
			else:
				game_over() # End the game
		else:
			if enemy.type == "boss":
				play_special_event()
			else:
				end_battle() # End the battle
	else:
		if GameManager.player_HP_regen > 0: # if player positive has HP regen, apply one final tick
			set_player_HP(GameManager.player_HP_regen)
			player_animator.queue("heal_flash")
		if GameManager.player_MP_regen > 0: # if player has positive MP regen, apply one final tick
			set_player_MP(GameManager.player_MP_regen)
			#player_animator.queue("mana_flash")
		if enemy.type == "boss":
			play_special_event()
		else:
			end_battle() # End the battle

func play_special_event() -> void:
	event_playing = true
	match enemy.full_name:
		"Shade of\nThe Phantom":
			enemy.is_alive = true
			set_enemy_HP(1)
			enemy_sprite.stop()
			enemy_container.get_node("Name").hide()
			enemy_health_bar.hide()
			enemy_status_display.hide()
			hide_tooltip()
			display_message("\"Ennnough...!\nMusssst renewww powerrr...\"")
			await(screen_text.text_finished)
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			# Play retreat animation
			enemy_sprite.play("retreat")
			await(get_tree().create_timer(1).timeout)
			enemy_animator.play("phantom_retreat")
			await enemy_animator.animation_finished
			end_battle("The Phantom retreats and vanishes deep into the fog!", false) 
		"The Phantom\nRunikesh":
			# Prevent death
			enemy.is_alive = true
			set_enemy_HP(1)
			# Swap sprite
			var frame: int = enemy_sprite.get_frame()
			var progress: float = enemy_sprite.get_frame_progress()
			var anim_name: String = enemy_sprite.animation
			enemy_sprite = enemy_container.get_node("Sprites/Runikesh")
			enemy_sprite.play(anim_name)
			enemy_sprite.set_frame_and_progress(frame, progress)
			enemy_sprite.show()
			enemy_container.get_node("Sprites/Phantom").hide()
			# Hide UI and fade music
			enemy_container.get_node("Name").hide()
			enemy_health_bar.hide()
			enemy_status_display.hide()
			hide_tooltip()
			set_music_fade("out")
			# Player breaks the phylactery
			if GameManager.favor_active:
				display_message("The sheer force of Phylactery Buster has shattered the Lich's phylactery!")
				await(screen_text.text_finished)
				await(get_tree().create_timer(GameManager.text_pause).timeout)
				await(get_tree().create_timer(1).timeout)
			else:
				display_message("You quickly strike at the Lich's phylactery, preventing his escape!")
				await(screen_text.text_finished)
				await(get_tree().create_timer(GameManager.text_pause).timeout)
				await(get_tree().create_timer(0.5).timeout)
				player_sprite.play("attack")
				await(get_tree().create_timer(0.2).timeout)
				load_sfx(sfx_sword)
				sfx_player.play()
				await(get_tree().create_timer(0.3).timeout)
				enemy_sprite.play("taunt")
				load_sfx(sfx_break)
				sfx_player.play()
				await player_sprite.animation_finished
				player_sprite.play("idle")
				display_message("The phylactery shatters!")
				await(screen_text.text_finished)
				await(get_tree().create_timer(GameManager.text_pause).timeout)
				await(get_tree().create_timer(1).timeout)
			# Make variable changes during phasing animation
			enemy_sprite.stop()
			enemy_animator.play("runikesh_phasing")
			enemy.full_name = "Demon Lich\nRunikesh"
			enemy_container.get_node("Name").text = enemy.full_name
			for debuff in enemy.debuffs:
				clear_status(debuff)
			display_status()
			enemy.set_stats(enemy_sprite.get_stats())
			set_enemy_HP(enemy.max_HP)
			await enemy_animator.animation_finished
			# Final anim
			enemy_sprite.play("attack")
			display_message("\"...!\"\n\n\"Foooool...!\"")
			load_sfx(sfx_fear)
			sfx_player.play()
			await enemy_sprite.animation_finished # Wait for animation to finish
			# Reactivate fight
			enemy_sprite.play("idle")
			enemy_container.get_node("Name").show()
			enemy_health_bar.show()
			enemy_status_display.show()
			Music.stop()
			set_music_volume(GameManager.music_volume_limit)
			GameManager.play_music("boss2")
			display_message("Runikesh's mortality has been exposed!")
			event_playing = false
			begin_player_turn()
		"Demon Lich\nRunikesh":
			enemy_sprite.play("death")
			enemy_sprite.pause()
			set_music_fade("out")
			display_message("\"Imposssssible...!\"\n\n\"How...? ...!\"")
			# hide interface
			coin_label.hide()
			stage_label.hide()
			enemy_container.get_node("Name").hide()
			enemy_container.get_node("ResourceContainer").hide()
			enemy_status_display.hide()
			player_container.get_node("Name").hide()
			player_container.get_node("ResourceContainer").hide()
			player_status_display.hide()
			hide_tooltip()
			await(screen_text.text_finished)
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			await(get_tree().create_timer(2).timeout)
			screen_text.hide()
			# play death animation
			enemy_sprite.play()
			await(get_tree().create_timer(2).timeout)
			set_music_fade("in")
			GameManager.play_music("main_menu", 43)
			animation_player.play("runikesh_explode")
			enemy_animator.play("runikesh_death")
			await enemy_animator.animation_finished
			await(get_tree().create_timer(1).timeout)
			enemy_animator.play("enemy_death")
			await enemy_animator.animation_finished
			screen_text.show() # redisplay screen text
			end_battle("Runikesh the Demon Lich has been vanquished! ", false)
		_:
			end_battle()

func check_player_speed() -> bool:
	if GameManager.player_speed >= player_turn_speed:
		if GameManager.player_speed > randf() + player_turn_speed:
			player_turn_speed += 1.0
			return true
		else:
			player_turn_speed = 1.0
			return false
	else:
		if GameManager.player_speed >= randf():
			player_turn_speed = 1.0
			return false
		else:
			player_turn_speed = 1.0
			player_turn_skip = true
			return false

func update_coin_label() -> void:
	coin_label.text = ": %d" % [GameManager.coins]

func update_player_status() -> void:
	var status: Status
	var clear_list: Array = []
	# Check for HP/MP changes
	if GameManager.player_HP_regen != 0:
		set_player_HP(GameManager.player_HP_regen) # Add/reduce HP
		if GameManager.player_HP_regen > 0:
			player_animator.queue("heal_flash")
		elif GameManager.player_HP_regen < 0:
			player_animator.queue("damage_flash")
	if GameManager.player_MP_regen != 0:
		set_player_MP(GameManager.player_MP_regen) # Add/reduce MP
		#player_animator.queue("mana_flash")
	# Update buffs
	for x in player_buffs.size():
		if is_instance_valid(player_buffs[x]):
			status = player_buffs[x]
			status.duration -= 1
			if status.duration <= 0:
					clear_list.push_front(x)
	# Remove any expired buffs from storage
	for x in clear_list:
		clear_status(player_buffs[x])
	clear_list.clear()
	# Update debuffs
	for x in player_debuffs.size():
		if is_instance_valid(player_debuffs[x]):
			status = player_debuffs[x]
			status.duration -= 1
			if status.duration <= 0:
				clear_list.push_front(x)
	# Remove any expired debuffs from storage
	for x in clear_list:
		clear_status(player_debuffs[x])
	clear_list.clear()

func update_enemy_status() -> void:
	var status: Status
	var clear_list: Array = []
	# Check for HP changes
	if enemy.HP_regen != 0:
		set_enemy_HP(enemy.HP_regen) # Add/reduce HP
		if enemy.HP_regen > 0:
			enemy_animator.queue("heal_flash")
		elif enemy.HP_regen < 0:
			enemy_animator.queue("damage_flash")
	# Reduce buff duration and add index to clear list if 0
	for x in enemy.buffs.size():
		if is_instance_valid(enemy.buffs[x]):
			status = enemy.buffs[x]
			status.duration -= 1
			if status.duration <= 0:
				clear_list.push_front(x)
	# Remove any expired buffs from storage
	for x in clear_list:
		clear_status(enemy.buffs[x])
	clear_list.clear()
	# Reduce debuff duration and add index to clear list if 0
	for x in enemy.debuffs.size():
		if is_instance_valid(enemy.debuffs[x]):
			status = enemy.debuffs[x]
			status.duration -= 1
			if status.duration <= 0:
				clear_list.push_front(x)
	for x in clear_list:
		clear_status(enemy.debuffs[x])
	clear_list.clear()

func display_status() -> void:
	# Display player status
	player_status_display.clear() # Clear display
	for buff in player_buffs: # Display buffs
		if is_instance_valid(buff):
			player_status_display.add_item(str(buff.duration), buff.icon, false)
			player_status_display.set_item_tooltip(-1, buff.tooltip)
	for debuff in player_debuffs: # Display debuffs
		if is_instance_valid(debuff):
			player_status_display.add_item(str(debuff.duration), debuff.icon, false)
			player_status_display.set_item_tooltip(-1, debuff.tooltip)
	# Display enemy status
	enemy_status_display.clear() # Clear display
	for buff in enemy.buffs: # Display buffs
		if is_instance_valid(buff):
			enemy_status_display.add_item(str(buff.duration), buff.icon, false)
			enemy_status_display.set_item_tooltip(-1, buff.tooltip)
	for debuff in enemy.debuffs: # Display debuffs
		if is_instance_valid(debuff):
			enemy_status_display.add_item(str(debuff.duration), debuff.icon, false)
			enemy_status_display.set_item_tooltip(-1, debuff.tooltip)

func store_status(status:Status) -> void:
	var duplicate_at: int = -1 # Used to check if a status of the same type already exists
	var target_list: Array # Stores the array where the status should be sent
	# Use the status target and is_buff to determine where the status is being stored
	if status.target == "player":
		if status.is_buff:
			target_list = player_buffs
		else:
			target_list = player_debuffs
	else:
		if status.is_buff:
			target_list = enemy.buffs
		else:
			target_list = enemy.debuffs
		
	for x in target_list.size():
		if is_instance_valid(target_list[x]):
			if target_list[x].type == status.type:
				duplicate_at = x
				break
	# Check if too many statuses have been added this battle
	if target_list.size () >= GameManager.status_limit:
		refresh_status_lists()
	# Add the new status or replace the existing one of the same type
	if duplicate_at == -1:
		target_list.append(status)
		status.storage_index = target_list.size() - 1
	else:
		clear_status(target_list[duplicate_at])
		target_list[duplicate_at] = status
		status.storage_index = duplicate_at

func clear_status(status:Status) -> void:
	if is_instance_valid(status):
		if status.target == "player": # Clear status from player
			if status.is_buff:
				match status.type:
					"HP regen":
						GameManager.player_HP_regen -= status.power
					"MP regen":
						GameManager.player_MP_regen -= status.power
					"defence up":
						GameManager.player_temp_defence -= status.power
					"speed up":
						GameManager.player_speed -= status.power
					"accuracy up":
						GameManager.player_accuracy -= status.power
					"vandar":
						GameManager.player_item_damage_ratio -= status.power
					"amarok":
						GameManager.player_weapon_lifesteal -= status.power
					"rascal":
						GameManager.favor_active = false
					_:
						printerr("ERROR: Status type not found for clearing from player buffs")
				player_buffs[status.storage_index] = null
			else:
				match status.type:
					"bleeding", "burning":
						GameManager.player_HP_regen += status.power
					"MP degen":
						GameManager.player_MP_regen += status.power
					"defence down":
						GameManager.player_temp_defence += status.power
					"speed down":
						GameManager.player_speed += status.power
					"accuracy down":
						GameManager.player_accuracy += status.power
					"disable weapon":
						weapon_button.disabled = false
					"disable magic":
						magic_button.disabled = false
					"disable items":
						item_button.disabled = false
					_:
						printerr("ERROR: Status type not found for clearing from player debuffs")
				player_debuffs[status.storage_index] = null
		else: # Clear status from enemy
			if status.is_buff:
				match status.type:
					"HP regen":
						enemy.HP_regen -= status.power
					_:
						printerr("ERROR: Status type not found for clearing from enemy buffs")
				enemy.buffs[status.storage_index] = null
			else:
				match status.type:
					"bleeding", "burning":
						enemy.HP_regen += status.power
					"lyra":
						enemy.accuracy += status.power
						enemy.speed += status.power
					_:
						printerr("ERROR: Status type not found for clearing from enemy debuffs")
				enemy.debuffs[status.storage_index] = null
		status.free()

func clear_status_all() -> void:
	# Clear player buffs
	var status: Status
	for x in player_buffs.size():
		if is_instance_valid(player_buffs[x]):
			status = player_buffs[x]
			match status.type:
				"HP regen":
					GameManager.player_HP_regen -= status.power
				"MP regen":
					GameManager.player_MP_regen -= status.power
				"defence up":
					GameManager.player_temp_defence -= status.power
				"speed up":
					GameManager.player_speed -= status.power
				"accuracy up":
					GameManager.player_accuracy -= status.power
				"vandar":
					GameManager.player_item_damage_ratio -= status.power
				"amarok":
					GameManager.player_weapon_lifesteal -= status.power
				"rascal":
					GameManager.favor_active = false
				_:
					printerr("ERROR: Player buff type not found in clear_status_all")
			status.free()
	player_buffs.clear()
	# Clear player debuffs
	for x in player_debuffs.size():
		if is_instance_valid(player_debuffs[x]):
			status = player_debuffs[x]
			match status.type:
				"bleeding", "burning":
					GameManager.player_HP_regen += status.power
				"MP degen":
					GameManager.player_MP_regen += status.power
				"defence down":
					GameManager.player_temp_defence += status.power
				"speed down":
					GameManager.player_speed += status.power
				"accuracy down":
					GameManager.player_accuracy += status.power
				"disable weapon":
					weapon_button.disabled = false
				"disable magic":
					magic_button.disabled = false
				"disable items":
					item_button.disabled = false
				_:
					printerr("ERROR: Player debuff type not found in clear_status_all")
			status.free()
	player_debuffs.clear()
	# Clear enemy buffs
	for x in enemy.buffs.size():
		if is_instance_valid(enemy.buffs[x]):
			status = enemy.buffs[x]
			match status.type:
				"HP regen":
					enemy.HP_regen -= status.power
				_:
					printerr("ERROR: Enemy buff type not found in clear_status_all")
			status.free()
	enemy.buffs.clear()
	# Clear enemy debuffs
	for x in enemy.debuffs.size():
		if is_instance_valid(enemy.debuffs[x]):
			status = enemy.debuffs[x]
			match status.type:
				"bleeding", "burning":
					enemy.HP_regen += status.power
				"lyra":
					enemy.accuracy += status.power
					enemy.speed += status.power
				_:
					printerr("ERROR: Enemy debuff type not found in clear_status_all")
			status.free()
	enemy.debuffs.clear()

func clear_loot() -> void:
	# Clear any loot in loot_reward
	for loot in loot_reward:
		if is_instance_valid(loot):
			loot.free()
	loot_reward.clear()

func refresh_status_lists() -> void:
	# Cleans up any empty/null instances in the status lists
	var clear_list: Array = []
	# Cleanup player buffs
	for x in player_buffs.size():
		if not is_instance_valid(player_buffs[x]):
			clear_list.push_front(x)
	for x in clear_list:
		player_buffs.remove_at(x)
	clear_list.clear()
	for x in player_buffs.size():
		player_buffs[x].storage_index = x
	# Cleanup player debuffs
	for x in player_debuffs.size():
		if not is_instance_valid(player_debuffs[x]):
			clear_list.push_front(x)
	for x in clear_list:
		player_debuffs.remove_at(x)
	clear_list.clear()
	for x in player_debuffs.size():
		player_debuffs[x].storage_index = x
	# Cleanup enemy buffs
	for x in enemy.buffs.size():
		if not is_instance_valid(enemy.buffs[x]):
			clear_list.push_front(x)
	for x in clear_list:
		enemy.buffs.remove_at(x)
	clear_list.clear()
	for x in enemy.buffs.size():
		enemy.buffs[x].storage_index = x
	# Cleanup enemy debuffs
	for x in enemy.debuffs.size():
		if not is_instance_valid(enemy.debuffs[x]):
			clear_list.push_front(x)
	for x in clear_list:
		enemy.debuffs.remove_at(x)
	clear_list.clear()
	for x in enemy.debuffs.size():
		enemy.debuffs[x].storage_index = x

func begin_player_turn() -> void:
	inventory.update_stat_labels()
	battle_buttons.show() # Re-enables the main battle buttons
	turn_change.emit()

func end_battle(victory_text:String = "%s is defeated!" % [enemy.name], death_anim:bool = true) -> void:
	outro_playing = true
	turn_change.emit()
	# Play death animation for enemy
	if death_anim:
		enemy_sprite.stop()
		enemy_animator.play("enemy_death")
		await enemy_animator.animation_finished
	# Set player HP to 1 if battle is won on 0 HP
	if not player_alive:
		player_alive = true
		set_player_HP(1)
		player_animator.play("heal_flash")
	# Display victory text
	display_message(victory_text)
	await(screen_text.text_finished) # Wait for text to finish animating
	display_rewards() # Populate LootDisplay and unhide it
	enemy_container.hide()
	enemy_status_display.hide()
	
func game_over() -> void:
	# Play player death animation
	player_animator.play("player_death")
	await player_animator.animation_finished
	# Display game over text
	if GameManager.level != 100:
		if GameManager.checkpoint_available:
			display_message("You took fatal damage!\n\nRetry from previous camp?")
		else:
			display_message("You took fatal damage!\n\nGame over.")
	else:
		load_sfx(sfx_fear)
		enemy_sprite.play("taunt")
		sfx_player.play()
		display_message("\"Ffffutile... My powerrr risessss!\"")
	await(screen_text.text_finished) # Wait for text to finish animating
	# Display game over screen with some results and a Restart, Quit to Menu, and Quit Game button
	game_over_menu.show()
	
func use_skill(skill:Skill) -> void:
	battle_buttons.hide() # Disable main battle buttons after making a move
	match skill.type: # Determine the type of weapon ability used
		"attack":
			if GameManager.player_accuracy >= randf():
				# Calculate damage total
				var damage: int = 0
				if GameManager.player_accuracy > randf() + 1:
					damage = round((skill.power + GameManager.player_attack_power) * GameManager.crit_ratio)
					# Change battle text
					display_message("Your %s does %d (critical) damage to %s!" % [skill.name, damage, enemy.name])
				else:
					damage = skill.power + GameManager.player_attack_power
					# Change battle text
					display_message("Your %s does %d damage to %s!" % [skill.name, damage, enemy.name])
				await(screen_text.text_finished) # Wait for text to finish animating
				await(get_tree().create_timer(GameManager.text_pause).timeout)
				# Play animations/sounds
				if not GameManager.hide_battle_anims:
					player_sprite.play("attack")
					await(get_tree().create_timer(0.2).timeout)
					load_sfx(sfx_sword)
					sfx_player.play()
					await(get_tree().create_timer(0.3).timeout)
					set_enemy_HP(-damage) # Decrease enemy HP
					enemy_animator.queue("enemy_damaged")
					if GameManager.player_weapon_lifesteal > 0:
						set_player_HP(round(damage * GameManager.player_weapon_lifesteal))
						player_animator.queue("heal_flash")
					# Wait for animations to finish
					await player_sprite.animation_finished
					player_sprite.play("idle")
				else:
					set_enemy_HP(-damage) # Decrease enemy HP
					enemy_animator.queue("enemy_damaged")
					if GameManager.player_weapon_lifesteal > 0:
						set_player_HP(round(damage * GameManager.player_weapon_lifesteal))
						player_animator.queue("heal_flash")
			else:
				# Change battle text
				display_message("Your %s misses %s!" % [skill.name, enemy.name])
				await(screen_text.text_finished) # Wait for text to finish animating
				await(get_tree().create_timer(GameManager.text_pause).timeout)
				# Play animations
				if not GameManager.hide_battle_anims:
					player_sprite.play("attack")
					await(get_tree().create_timer(0.2).timeout)
					load_sfx(sfx_miss)
					sfx_player.play()
					await player_sprite.animation_finished
					player_sprite.play("idle")
		"defence up":
			# Change battle text
			display_message("You hold your weapon up.\nDefence increased by %d this turn!" % [skill.power])
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			if not GameManager.hide_battle_anims:
				animation_player.queue("player_shield")
				load_sfx(sfx_block)
				sfx_player.play()
			GameManager.player_temp_defence += skill.power # Increase defence
			# Create status
			store_status(GameManager.create_status(skill.name, skill.power, skill.type, skill.duration, "player"))
		"HP regen":
			# Change battle text
			display_message("You hold your weapon up, harnessing its power.\nHealing %d HP each turn!" % [skill.power])
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			if not GameManager.hide_battle_anims:
				animation_player.queue("player_heart")
				load_sfx(sfx_buff)
				sfx_player.play()
			GameManager.player_HP_regen += skill.power # Increase player HP regen
			# Create status
			store_status(GameManager.create_status(skill.name, skill.power, skill.type, skill.duration, "player"))
		"bleeding":
			if GameManager.player_accuracy >= randf():
				# Calculate damage total
				var damage: int = 0
				if GameManager.player_accuracy > randf() + 1:
					damage = round((skill.power + (GameManager.player_attack_power * GameManager.player_status_scaling)) * GameManager.crit_ratio)
					# Change battle text
					display_message("You viciously %s the enemy!\n%s now bleeds for %d (critical) damage each turn!" % [skill.name, enemy.name, damage])
				else:
					damage = round(skill.power + (GameManager.player_attack_power * GameManager.player_status_scaling))
					# Change battle text
					display_message("You viciously %s the enemy!\n%s now bleeds for %d damage each turn!" % [skill.name, enemy.name, damage])
				await(screen_text.text_finished) # Wait for text to finish animating
				await(get_tree().create_timer(GameManager.text_pause).timeout)
				# Play animations/sounds
				if not GameManager.hide_battle_anims:
					player_sprite.play("attack")
					await(get_tree().create_timer(0.2).timeout)
					load_sfx(sfx_sword)
					sfx_player.play()
					await(get_tree().create_timer(0.3).timeout)
					animation_player.queue("enemy_bleed")
					load_sfx(sfx_debuff)
					sfx_player.play()
					enemy.HP_regen -= damage # Decrease enemy HP regen
					# Create status
					store_status(GameManager.create_status(skill.name, damage, skill.type, skill.duration, enemy.name))
					# Reset animation
					await player_sprite.animation_finished
					player_sprite.play("idle")
				else:
					enemy.HP_regen -= damage # Decrease enemy HP regen
					# Create status
					store_status(GameManager.create_status(skill.name, damage, skill.type, skill.duration, enemy.name))
			else:
				# Change battle text
				display_message("Your %s misses %s!" % [skill.name, enemy.name])
				await(screen_text.text_finished) # Wait for text to finish animating
				await(get_tree().create_timer(GameManager.text_pause).timeout)
				# Play animations
				if not GameManager.hide_battle_anims:
					player_sprite.play("attack")
					await(get_tree().create_timer(0.2).timeout)
					load_sfx(sfx_miss)
					sfx_player.play()
					await player_sprite.animation_finished
					player_sprite.play("idle")
		"MP regen":
			# Change battle text
			display_message("Your weapon shines brightly, unleasing its power!\nRecovering %d MP each turn!" % [skill.power])
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			if not GameManager.hide_battle_anims:
				animation_player.queue("player_juice")
				load_sfx(sfx_buff)
				sfx_player.play()
			GameManager.player_MP_regen += skill.power # Increase MP regen
			# Create status
			store_status(GameManager.create_status(skill.name, skill.power, skill.type, skill.duration, "player"))
		_:
			printerr("ERROR: Weapon skill type not found")
	# Check player's speed to see if they can take another turn
	if check_player_speed() and enemy.is_alive:
		display_status()
		display_message("Your speed allows you to move again!")
		await(screen_text.text_finished) # Wait for text to finish animating
		await(get_tree().create_timer(GameManager.text_pause).timeout)
		begin_player_turn()
	else:
		begin_enemy_turn() # End player turn and begin enemy turn

func use_magic(spell:Magic) -> void:
	battle_buttons.hide() # Disable main battle buttons after making a move
	if spell.cost > 0:
		set_player_MP(-spell.cost) # Decrease player MP
	match spell.type: # Determine the type of weapon ability used
		"attack":
			# Calculate damage total
			var damage: int = spell.power + GameManager.player_spellpower
			# Change battle text
			display_message("Your %s blasts %s for %d damage!" % [spell.name, enemy.name, damage])
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			# Play animations/sounds
			if not GameManager.hide_battle_anims:
				player_sprite.play("magic")
				await(get_tree().create_timer(0.4).timeout)
				animation_player.queue("player_fireball")
				load_sfx(sfx_fireball)
				sfx_player.play()
				await animation_player.animation_finished
				set_enemy_HP(-damage) # Decrease enemy HP
				enemy_animator.queue("enemy_damaged")
				player_sprite.play("idle")
				# Wait for animations to finish
				await enemy_animator.animation_finished
			else:
				set_enemy_HP(-damage) # Decrease enemy HP
				enemy_animator.queue("enemy_damaged")
		"burning":
			# Calculate damage total
			var damage: int = round(spell.power + (GameManager.player_spellpower * GameManager.player_status_scaling))
			# Change battle text
			display_message("Your %s sets %s alight!\nThey are now burning for %d damage each turn!" % [spell.name, enemy.name, damage])
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			# Play animation
			if not GameManager.hide_battle_anims:
				player_sprite.play("magic")
				await(get_tree().create_timer(0.4).timeout)
				animation_player.queue("player_flame")
				load_sfx(sfx_fireball)
				sfx_player.play()
				await animation_player.animation_finished
				enemy.HP_regen -= damage # Decrease enemy HP regen
				# Create status
				store_status(GameManager.create_status(spell.name, damage, spell.type, spell.duration, enemy.name))
				# Reset animation
				player_sprite.play("idle")
			else:
				enemy.HP_regen -= damage # Decrease enemy HP regen
				# Create status
				store_status(GameManager.create_status(spell.name, damage, spell.type, spell.duration, enemy.name))
		"healing":
			# Calculate the actual recovered health
			var healing: int = min(GameManager.player_max_HP - GameManager.player_HP, spell.power + GameManager.player_spellpower)
			# Change battle text
			display_message("You cast %s.\nRecovered %d health!" % [spell.name, healing])
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			if not GameManager.hide_battle_anims:
				player_sprite.play("magic")
				await(get_tree().create_timer(0.4).timeout)
				animation_player.queue("player_heart")
				#await animation_player.animation_finished
				player_sprite.play("idle")
				if healing > 0:
					set_player_HP(healing) # Increase player HP
					# Play animation for player recovering health
					player_animator.queue("player_healed")
					# Wait for animation to finish
					await player_animator.animation_finished
			else:
				if healing > 0:
					set_player_HP(healing) # Increase player HP
					# Play animation for player recovering health
					player_animator.queue("player_healed")
		"MP steal":
			# Calculate total damage
			var damage: int = round(spell.power + (GameManager.player_spellpower * GameManager.player_status_scaling))
			# Change battle text
			display_message("Your %s damages and rips %d MP from %s!" % [spell.name, damage, enemy.name])
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			if not GameManager.hide_battle_anims:
				player_sprite.play("magic")
				await(get_tree().create_timer(0.4).timeout)
				set_enemy_HP(-damage) # Decrease enemy HP
				set_player_MP(damage) # Increase player MP
				# Play animation for enemy taking damage
				animation_player.queue("enemy_ice")
				load_sfx(sfx_debuff)
				sfx_player.play()
				await animation_player.animation_finished
				enemy_animator.queue("enemy_damaged")
				player_animator.queue("player_restored")
				player_sprite.play("idle")
				# Wait for animation to finish
				await enemy_animator.animation_finished
			else:
				set_enemy_HP(-damage) # Decrease enemy HP
				set_player_MP(damage) # Increase player MP
				enemy_animator.queue("enemy_damaged")
				player_animator.queue("player_restored")
		"lifesteal":
			# Calculate total damage
			var damage: int = round(spell.power + (GameManager.player_spellpower * GameManager.player_status_scaling))
			# Change battle text
			display_message("You feel the hunger of the Lich!\nTransferring %d HP from %s to you each turn!" % [damage, enemy.name])
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			# Play sprite animation
			if not GameManager.hide_battle_anims:
				player_sprite.play("magic")
				await(get_tree().create_timer(0.4).timeout)
				GameManager.player_HP_regen += damage
				enemy.HP_regen -= damage
				# Play sound and battle animation
				animation_player.queue("enemy_lich")
				load_sfx(sfx_fear)
				sfx_player.play()
				await animation_player.animation_finished
				# Create statuses
				store_status(GameManager.create_status(spell.name, damage, "HP regen", spell.duration, "player"))
				store_status(GameManager.create_status(spell.name, damage, "bleeding", spell.duration, enemy.name))
				# Reset animation
				player_sprite.play("idle")
			else:
				GameManager.player_HP_regen += damage
				enemy.HP_regen -= damage
				store_status(GameManager.create_status(spell.name, damage, "HP regen", spell.duration, "player"))
				store_status(GameManager.create_status(spell.name, damage, "bleeding", spell.duration, enemy.name))
		"lyra":
			display_message("Lyra's mirror forces %s to reflect upon their actions!\nTheir accuracy and speed is reduced by %d%%!" % [enemy.name, spell.power * 100])
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			# Play sprite animation
			if not GameManager.hide_battle_anims:
				player_sprite.play("magic")
				await(get_tree().create_timer(0.4).timeout)
				enemy.accuracy -= spell.power
				enemy.speed -= spell.power
				# Play sound and battle animation
				animation_player.queue("enemy_mirror")
				load_sfx(sfx_debuff)
				sfx_player.play()
				await animation_player.animation_finished
				store_status(GameManager.create_status(spell.name, spell.power, spell.type, spell.duration, enemy.name))
				# Reset animation
				player_sprite.play("idle")
			else:
				enemy.accuracy -= spell.power
				enemy.speed -= spell.power
				store_status(GameManager.create_status(spell.name, spell.power, spell.type, spell.duration, enemy.name))
		"vandar":
			display_message("You channel the fury of Vandar!\nYour next attack item does %d%% more damage!" % [spell.power * 100])
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			# Play sprite animation
			if not GameManager.hide_battle_anims:
				player_sprite.play("magic")
				await(get_tree().create_timer(0.4).timeout)
				GameManager.player_item_damage_ratio += spell.power
				# Play sound and battle animation
				animation_player.queue("player_amulet")
				load_sfx(sfx_buff)
				sfx_player.play()
				await animation_player.animation_finished
				store_status(GameManager.create_status(spell.name, spell.power, spell.type, spell.duration, "player"))
				# Reset animation
				player_sprite.play("idle")
			else:
				GameManager.player_item_damage_ratio += spell.power
				store_status(GameManager.create_status(spell.name, spell.power, spell.type, spell.duration, "player"))
		"amarok":
			display_message("The thirst of Amarok must be quenched!\nYour direct weapon attacks heal you for %d%% of the damage dealt!" % [spell.power * 100])
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			# Play sprite animation
			if not GameManager.hide_battle_anims:
				player_sprite.play("magic")
				await(get_tree().create_timer(0.4).timeout)
				GameManager.player_weapon_lifesteal += spell.power
				# Play sound and battle animation
				animation_player.queue("player_jewel")
				load_sfx(sfx_buff)
				sfx_player.play()
				await animation_player.animation_finished
				store_status(GameManager.create_status(spell.name, spell.power, spell.type, spell.duration, "player"))
				# Reset animation
				player_sprite.play("idle")
			else:
				GameManager.player_weapon_lifesteal += spell.power
				store_status(GameManager.create_status(spell.name, spell.power, spell.type, spell.duration, "player"))
		"rascal":
			if enemy_sprite.name == "Phantom":
				display_message("Rascal's favor fully activates!")
				await(screen_text.text_finished) # Wait for text to finish animating
				await(get_tree().create_timer(GameManager.text_pause).timeout)
				await(get_tree().create_timer(1).timeout)
				display_message("Phylactery Buster is unleashed!")
				await(screen_text.text_finished) # Wait for text to finish animating
				await(get_tree().create_timer(GameManager.text_pause).timeout)
				# Play sprite animation
				player_sprite.play("magic")
				await(get_tree().create_timer(0.4).timeout)
				GameManager.favor_active = true
				# Play sound and battle animation
				animation_player.play("phylactery_buster")
				load_sfx(sfx_buster)
				sfx_player.play()
				await animation_player.animation_finished
				set_enemy_HP(-spell.power) # Decrease enemy HP
				enemy_animator.queue("phantom_buster")
				enemy_sprite.play("taunt")
				# Reset animation
				player_sprite.play("idle")
				await enemy_animator.animation_finished
				display_message("Rascal's favor has blessed you with a protective barrier against %s!" % [enemy.name])
				await(screen_text.text_finished) # Wait for text to finish animating
				await(get_tree().create_timer(GameManager.text_pause).timeout)
				animation_player.queue("player_favor")
				load_sfx(sfx_buff)
				sfx_player.play()
				await animation_player.animation_finished
				display_message("The relic falls dormant once more.")
				await(screen_text.text_finished) # Wait for text to finish animating
				await(get_tree().create_timer(GameManager.text_pause).timeout)
				await(get_tree().create_timer(2).timeout)
				store_status(GameManager.create_status(spell.name, spell.power, spell.type, spell.duration, "player"))
			else:
				display_message("Rascal's favor doesn't seem to do anything here...")
				await(screen_text.text_finished) # Wait for text to finish animating
				await(get_tree().create_timer(GameManager.text_pause).timeout)
		_:
			printerr("ERROR: Magic spell type not found")
	# Check player's speed to see if they can take another turn
	if check_player_speed() and enemy.is_alive:
		display_status()
		display_message("Your speed allows you to move again!")
		await(screen_text.text_finished) # Wait for text to finish animating
		await(get_tree().create_timer(GameManager.text_pause).timeout)
		begin_player_turn()
	else:
		begin_enemy_turn() # End player turn and begin enemy turn
	
func use_item(item:Item) -> void:
	battle_buttons.hide() # Disable main battle buttons after making a move
	match item.type:
		"attack":
			var damage: int = item.power * GameManager.player_item_damage_ratio
			# Change battle text
			display_message("You use %s.\n%s took %d damage!" % [item.name, enemy.name, damage])
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			# Play animations
			if not GameManager.hide_battle_anims:
				player_sprite.play("item")
				await(get_tree().create_timer(0.6).timeout)
				if item.anim: # Play animations/sounds if item has them
					animation_player.queue(item.anim)
					await(get_tree().create_timer(0.2).timeout)
					load_sfx(sfx_throw)
					sfx_player.play()
					await animation_player.animation_finished
				set_enemy_HP(-damage) # Decrease enemy HP
				enemy_animator.queue("enemy_damaged")
				player_sprite.play("idle")
				# Wait for animation to finish
				await enemy_animator.animation_finished
			else:
				set_enemy_HP(-damage) # Decrease enemy HP
				enemy_animator.queue("enemy_damaged")
		"healing":
			# Calculate the actual recovered health
			var healing: int = min(GameManager.player_max_HP - GameManager.player_HP, item.power)
			# Change battle text
			display_message("You eat %s.\nRecovered %d HP!" % [item.name, healing])
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			# Play animations
			if not GameManager.hide_battle_anims:
				if item.anim: # Play animations/sounds if item has them
					animation_player.queue(item.anim)
					await animation_player.animation_finished
			if healing > 0:
				set_player_HP(healing) # Increase player HP
				# Play animation for player recovering health
				player_animator.queue("player_healed")
		"MP gain":
			# Calculate the actual recovered MP
			var MP_gain: int = min(GameManager.player_max_MP - GameManager.player_MP, item.power)
			# Change battle text
			display_message("You drink %s.\nRecovered %d MP!" % [item.name, MP_gain])
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			if not GameManager.hide_battle_anims:
				if item.anim: # Play animations/sounds if item has them
					animation_player.queue(item.anim)
					await animation_player.animation_finished
			if MP_gain > 0:
				set_player_MP(MP_gain) # Increase player MP
				# Play animation for player recovering health
				player_animator.queue("player_restored")
		"HP regen":
			# Change battle text
			display_message("You drink %s.\nHealing %d HP each turn!" % [item.name, item.power])
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			# Play animations
			if not GameManager.hide_battle_anims:
				if item.anim: # Play animations/sounds if item has them
					animation_player.queue(item.anim)
					await(get_tree().create_timer(0.2).timeout)
					load_sfx(sfx_buff)
					sfx_player.play()
					await animation_player.animation_finished
			GameManager.player_HP_regen += item.power # Increase player HP regen
			# Create status
			store_status(GameManager.create_status(item.name, item.power, item.type, item.duration, "player"))
		"MP regen":
			# Change battle text
			display_message("You drink %s.\nRecovering %d MP each turn!" % [item.name, item.power])
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			# Play animations
			if not GameManager.hide_battle_anims:
				if item.anim: # Play animations/sounds if item has them
					animation_player.queue(item.anim)
					await(get_tree().create_timer(0.2).timeout)
					load_sfx(sfx_buff)
					sfx_player.play()
					await animation_player.animation_finished
			GameManager.player_MP_regen += item.power # Increase MP regen
			# Create status
			store_status(GameManager.create_status(item.name, item.power, item.type, item.duration, "player"))
		_:
			printerr("ERROR: Usable item type not found")
	# Remove the item if it has no uses left
	if item.uses == 0:
		GameManager.stored_items[item.storage_index].queue_free()
	# Check player's speed to see if they can take another turn
	if check_player_speed() and enemy.is_alive:
		display_status()
		display_message("Your speed allows you to move again!")
		await(screen_text.text_finished) # Wait for text to finish animating
		await(get_tree().create_timer(GameManager.text_pause).timeout)
		begin_player_turn() # Player takes another turn
	else:
		begin_enemy_turn() # End player turn and begin enemy turn

func display_message(text:String, wait:bool = false, hide:bool = false) -> void:
	if hide:
		battle_buttons.hide()
		# Change battle text
		screen_text.set_screen_text(text)
		if wait:
			# Wait for text to finish animating
			await(screen_text.text_finished)
			await(get_tree().create_timer(GameManager.text_pause).timeout)
		battle_buttons.show()
	else:
		# Change battle text
		screen_text.set_screen_text(text)
		if wait:
			# Wait for text to finish animating
			await(screen_text.text_finished)
			await(get_tree().create_timer(GameManager.text_pause).timeout)

func get_next_scene() -> String:
	# Check for any specific special levels with guaranteed camps or shops
	if GameManager.level % 20 == 0 and GameManager.level != 100:
		return "camp"
	if GameManager.level == 51:
		return "shop"
	if GameManager.level == 100:
		return "grove"
	if GameManager.level == 101:
		return "end"
	# Check if random event is next
	if GameManager.level >= GameManager.min_event_level:
		if GameManager.event_chance > randf():
			GameManager.event_chance = GameManager.base_event_chance
			# Choose an event
			var events: Array = [1,2,3]
			# Check what the most recent event was and remove it from array
			if GameManager.event_recent == "ambush":
				events.erase(1)
			elif GameManager.event_recent == "grove":
				events.erase(2)
			if GameManager.coins < GameManager.gamble_base_cost * ((GameManager.level / 10) + 1) or GameManager.event_recent == "gamble":
				events.erase(3) # Remove if gamble event isn't affordable
			match events.pick_random():
				1:
					GameManager.event_recent = "ambush"
					return "ambush"
				2:
					GameManager.event_recent = "grove"
					return "grove"
				3:
					GameManager.event_recent = "gamble"
					return "gamble"
		else:
			GameManager.event_chance += GameManager.base_event_chance
	# Check if random shop is next
	if GameManager.level >= GameManager.min_shop_level:
		if GameManager.shop_chance > randf():
			GameManager.shop_chance = GameManager.base_shop_chance
			return "shop"
		else:
			GameManager.shop_chance *= 2
	# Default to battle scene
	return "battle"

func end_scene() -> void:
	loot_display.hide()
	player_status_display.hide()
	hide_tooltip()
	inventory.load_sfx(inventory.sfx_loot)
	inventory.ui_audio.play()
	GameManager.store_rewards(loot_reward, coin_reward) # Add rewards to GameManager
	update_coin_label() # Show the coin changes on the UI
	GameManager.level_up() # Increase level for scaling
	var next_scene: String = get_next_scene()
	# Wait briefly
	await(get_tree().create_timer(0.2).timeout)
	if GameManager.level != 101:
		# Play leaving animation
		player_sprite.play("run")
		player_animator.play("leaving_battle")
	else:
		player_sprite.play("hold")
	# Play fade animation
	animation_player.play("scene_fade")
	# Check if next stage will use different music
	match next_scene:
		"camp":
			if GameManager.level < 81:
				set_music_fade("out")
		"grove":
			set_music_fade("out")
		"shop":
			if GameManager.level != 101:
				set_music_fade("out")
	await(get_tree().create_timer(2.5).timeout)
	# Pre-transition storing, updating, and cleaning
	clear_status_all() # Clear all status effects
	GameManager.refresh_storage() # Clean up any empty storage entries
	enemy.free() # Clear enemy instance
	enemy = null
	# Change scene
	get_tree().change_scene_to_file(GameManager.scenes[next_scene])

func _on_inventory_stats_changed() -> void:
	# Update player resource bars when stats have been changed
	set_resource_bar(player_health_bar, GameManager.player_HP, GameManager.player_max_HP)
	set_resource_bar(player_magic_bar, GameManager.player_MP, GameManager.player_max_MP)

func retry_from_checkpoint() -> void:
	if not loading:
		loading = true
		animation_player.play("scene_fade")
		set_music_fade("out")
		battle_buttons.hide()
		game_over_menu.hide()
		await animation_player.animation_finished
		await get_tree().create_timer(1).timeout
		clear_status_all()
		clear_loot()
		GameManager.load_checkpoint()
		get_tree().change_scene_to_file(GameManager.scenes["camp"])

func restart() -> void:
	if not loading:
		loading = true
		animation_player.play("scene_fade")
		set_music_fade("out")
		battle_buttons.hide()
		game_over_menu.hide()
		await animation_player.animation_finished
		await get_tree().create_timer(1).timeout
		clear_status_all()
		clear_loot()
		get_tree().change_scene_to_file(GameManager.scenes["main_menu"])

func _on_continue_button_mouse_entered() -> void:
	inventory.load_sfx(inventory.sfx_hover)
	inventory.ui_audio.play()

func hide_tooltip() -> void:
	UI.tooltip.hide()
	UI.tooltip.size.y = 20

func _on_enemy_status_display_gui_input(event: InputEvent) -> void:
	var index: int = enemy_status_display.get_item_at_position(event.position, true)
	if index == -1: hide_tooltip()
	else:
		UI.tooltip.size.y = 20
		UI.tooltip.text = enemy_status_display.get_item_tooltip(index)
		if !UI.tooltip.text:
			hide_tooltip()
			return
		UI.set_tooltip_position(event.position, enemy_status_display.position)
		UI.tooltip.show()

func _on_player_status_display_gui_input(event: InputEvent) -> void:
	var index: int = player_status_display.get_item_at_position(event.position, true)
	if index == -1: hide_tooltip()
	else:
		UI.tooltip.size.y = 20
		UI.tooltip.text = player_status_display.get_item_tooltip(index)
		if !UI.tooltip.text:
			hide_tooltip()
			return
		UI.set_tooltip_position(event.position, player_status_display.position)
		UI.tooltip.show()

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
