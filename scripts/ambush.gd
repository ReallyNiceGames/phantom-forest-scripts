extends "res://assets/scripts/event.gd"

@onready var ambush_container: VBoxContainer = $CanvasLayer/AmbushContainer
@onready var player_status_display: ItemList = $CanvasLayer/PlayerStatusDisplay
@onready var enemy_status_display: ItemList = $CanvasLayer/EnemyStatusDisplay
@onready var inventory: Control = $UILayer/Inventory
@onready var loot_display: ItemList = $UILayer/LootDisplay
@onready var game_over_menu: PanelContainer = $UILayer/GameOverMenu
@onready var ambush_animator: AnimationPlayer = $AmbushAnimator
@onready var battle_buttons: PanelContainer = $CanvasLayer/BattleButtons
@onready var ambush_choices: VBoxContainer = $UILayer/AmbushChoices
@onready var pay_button: Button = $UILayer/AmbushChoices/PayButton
@onready var run_button: Button = $UILayer/AmbushChoices/RunButton
# Signals
signal turn_change
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
}
# Scene vars
var enemy_next_action: int = -1
var loot_reward: Array = []
var coin_reward: int = 0
var player_turn_skip: bool = false
var player_turn_speed: float = 1.0
var player_buffs: Array = []
var player_debuffs: Array = []
var intro_playing: bool = true
var outro_playing: bool = false
var coin_cost: int = 0
var health_cost: int = 0
var scaling: int
var loading: bool = false
# Node refs
var enemy_sprite: AnimatedSprite2D
var enemy_animator: AnimationPlayer
var enemy_health_bar: ProgressBar
var enemy_label: Label
var enemy: Enemy
var weapon_button: Button
var magic_button: Button
var item_button: Button

func play_scene_intro() -> void:
	battle_buttons.hide()
	set_costs()
	animation_player.play("scene_reveal")
	player_animator.play("entering_scene")
	await(get_tree().create_timer(1.2).timeout)
	player_sprite.play("idle")
	if not GameManager.ambush_seen:
		display_message("\"Halt!\"\n\n\"Pay the toll if you want to pass,\nor we can do this the hard way...\"")
		await(screen_text.text_finished) # Wait for text to finish animating
		await(get_tree().create_timer(GameManager.text_pause).timeout)
		GameManager.ambush_seen = true
	else:
		display_message("\"Halt!\"\n\n\"...You again? Tsk.\"")
	# Show options: Pay, Run, or Fight
	ambush_choices.show()

func set_enemy() -> void:
	# Create new enemy from ID and store ID
	scaling = (GameManager.level / 10) + 1
	enemy = GameManager.create_enemy(17)
	enemy_sprite = ambush_container.get_node("Sprites/Highwayman")
	var stats: Array = enemy_sprite.get_stats()
	for x in range(3):
		stats[x] *= scaling
	enemy.set_stats(stats)

func set_rewards() -> void:
	loot_reward = GameManager.generate_loot(3, 5)
	coin_reward = GameManager.generate_coins(3)

func set_node_refs() -> void:
	player_sprite = player_container.get_node("Player")
	player_label = player_container.get_node("Name")
	player_health_bar = player_container.get_node("ResourceContainer/HealthBar")
	player_magic_bar = player_container.get_node("ResourceContainer/MagicBar")
	player_animator = player_container.get_node("AnimationPlayer")
	enemy_health_bar = ambush_container.get_node("ResourceContainer/HealthBar")
	enemy_animator = ambush_container.get_node("AnimationPlayer")
	enemy_label = ambush_container.get_node("Name")
	weapon_button = battle_buttons.get_node("VBoxContainer/HBoxContainer/WeaponButton")
	magic_button = battle_buttons.get_node("VBoxContainer/HBoxContainer/MagicButton")
	item_button = battle_buttons.get_node("VBoxContainer/HBoxContainer2/ItemButton")

func set_stage_label() -> void:
	stage_label.text = "Ambush"

func set_bars() -> void:
	set_resource_bar(player_health_bar, GameManager.player_HP, GameManager.player_max_HP)
	set_resource_bar(player_magic_bar, GameManager.player_MP, GameManager.player_max_MP)
	set_resource_bar(enemy_health_bar, enemy.HP, enemy.max_HP)

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

func set_costs() -> void:
	coin_cost = GameManager.ambush_base_coin_cost * scaling
	health_cost = GameManager.ambush_base_health_cost * scaling
	pay_button.text = "-%dG" % [coin_cost]
	run_button.text = "-%dHP" % [health_cost]
	if GameManager.coins < coin_cost:
		pay_button.disabled = true
	if GameManager.player_HP < health_cost:
		run_button.disabled = true

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
			await enemy_sprite.animation_finished
			enemy_sprite.play("idle")
		if action.battle_anim and not GameManager.hide_battle_anims: # Use battle animation player
			ambush_animator.queue("battle_anims/" + action.battle_anim)
			if action.battle_anim_sfx: # Pair a sound with the anim
				load_sfx(sfx[action.battle_anim_sfx])
				sfx_player.play()
			await ambush_animator.animation_finished
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
			#await(get_tree().create_timer(0.8).timeout) # Wait for animation to finish
			await player_sprite.animation_finished
			if player_alive:
				player_sprite.play("idle")
	if turn_speed == 0.0:
		display_message("%s is too slow to get going." % enemy.name)
		await(screen_text.text_finished) # Wait for text to finish animating
		await(get_tree().create_timer(GameManager.text_pause).timeout)
	turn_change.emit() # Signal for the turn to change

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
	ambush_animator.play("battle_anims/loot_popup")
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
			end_battle() # End the battle
	else:
		if GameManager.player_HP_regen > 0: # if player positive has HP regen, apply one final tick
			set_player_HP(GameManager.player_HP_regen)
			player_animator.queue("heal_flash")
		if GameManager.player_MP_regen > 0: # if player has positive MP regen, apply one final tick
			set_player_MP(GameManager.player_MP_regen)
			#player_animator.queue("mana_flash")
		end_battle() # End the battle

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

func game_over() -> void:
	# Play player death animation
	player_animator.play("player_death")
	await player_animator.animation_finished
	# Display game over text
	if GameManager.checkpoint_available:
		display_message("You took fatal damage!\n\nRetry from previous camp?")
	else:
		display_message("You took fatal damage!\n\nGame over.")
	await(screen_text.text_finished) # Wait for text to finish animating
	# Display game over screen with some results and a Restart, Quit to Menu, and Quit Game button
	game_over_menu.show()
	
func end_battle() -> void:
	outro_playing = true
	turn_change.emit()
	# Play death animation for enemy
	enemy_label.hide()
	enemy_health_bar.hide()
	enemy_status_display.hide()
	enemy_sprite.play("surrender")
	await enemy_sprite.animation_finished
	# Set player HP to 1 if battle is won on 0 HP
	if not player_alive:
		player_alive = true
		set_player_HP(1)
		player_animator.play("heal_flash")
	# Display victory text
	display_message("\"Mercy!\"\n\n\"I surrender!\"")
	await(screen_text.text_finished) # Wait for text to finish animating
	await(get_tree().create_timer(GameManager.text_pause).timeout)
	enemy_sprite.play("idle")
	enemy_animator.play("highwayman_flee")
	await enemy_animator.animation_finished
	display_message("%s makes a swift retreat,\nleaving precious loot behind!" % [enemy.name])
	await(screen_text.text_finished) # Wait for text to finish animating
	display_rewards() # Populate LootDisplay and unhide it

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
				ambush_animator.queue("battle_anims/player_shield")
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
				ambush_animator.queue("battle_anims/player_heart")
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
					ambush_animator.queue("battle_anims/enemy_bleed")
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
				ambush_animator.queue("battle_anims/player_juice")
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
				ambush_animator.queue("battle_anims/player_fireball")
				load_sfx(sfx_fireball)
				sfx_player.play()
				await ambush_animator.animation_finished
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
				ambush_animator.queue("battle_anims/player_flame")
				load_sfx(sfx_fireball)
				sfx_player.play()
				await ambush_animator.animation_finished
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
				ambush_animator.queue("battle_anims/player_heart")
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
			var damage: int = spell.power + round(GameManager.player_spellpower / 2)
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
				ambush_animator.queue("battle_anims/enemy_ice")
				load_sfx(sfx_debuff)
				sfx_player.play()
				await ambush_animator.animation_finished
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
				ambush_animator.queue("battle_anims/enemy_lich")
				load_sfx(sfx_fear)
				sfx_player.play()
				await ambush_animator.animation_finished
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
				ambush_animator.queue("battle_anims/enemy_mirror")
				load_sfx(sfx_debuff)
				sfx_player.play()
				await ambush_animator.animation_finished
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
				ambush_animator.queue("battle_anims/player_amulet")
				load_sfx(sfx_buff)
				sfx_player.play()
				await ambush_animator.animation_finished
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
				ambush_animator.queue("battle_anims/player_jewel")
				load_sfx(sfx_buff)
				sfx_player.play()
				await ambush_animator.animation_finished
				store_status(GameManager.create_status(spell.name, spell.power, spell.type, spell.duration, "player"))
				# Reset animation
				player_sprite.play("idle")
			else:
				GameManager.player_weapon_lifesteal += spell.power
				store_status(GameManager.create_status(spell.name, spell.power, spell.type, spell.duration, "player"))
		"rascal":
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
					ambush_animator.queue("battle_anims/" + item.anim)
					await(get_tree().create_timer(0.2).timeout)
					load_sfx(sfx_throw)
					sfx_player.play()
					await ambush_animator.animation_finished
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
					ambush_animator.queue("battle_anims/" + item.anim)
					await ambush_animator.animation_finished
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
					ambush_animator.queue("battle_anims/" + item.anim)
					await ambush_animator.animation_finished
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
					ambush_animator.queue("battle_anims/" + item.anim)
					await(get_tree().create_timer(0.2).timeout)
					load_sfx(sfx_buff)
					sfx_player.play()
					await ambush_animator.animation_finished
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
					ambush_animator.queue("battle_anims/" + item.anim)
					await(get_tree().create_timer(0.2).timeout)
					load_sfx(sfx_buff)
					sfx_player.play()
					await ambush_animator.animation_finished
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

func end_scene() -> void:
	loot_display.hide()
	player_status_display.hide()
	hide_tooltip()
	load_ui_sfx(sfx_loot)
	ui_player.play()
	GameManager.store_rewards(loot_reward, coin_reward) # Add rewards to GameManager
	update_coin_label() # Show the coin changes on the UI
	var next_scene: String = get_next_scene()
	# Wait briefly
	await(get_tree().create_timer(0.2).timeout)
	# Play leaving animation
	player_sprite.play("run")
	player_animator.play("leaving_battle")
	# Play fade animation
	animation_player.play("scene_fade")
	await(get_tree().create_timer(2.5).timeout)
	# Pre-transition storing, updating, and cleaning
	clear_status_all() # Clear all status effects
	GameManager.refresh_storage() # Clean up any empty storage entries
	# Change scene
	get_tree().change_scene_to_file(GameManager.scenes[next_scene])

func _on_fight_button_pressed() -> void:
	ambush_choices.hide()
	load_sfx(sfx_confirm)
	sfx_player.play()
	display_message("\"Fine! Have it your way.\"\n\n\"Your suicide.\nMy profit.\"")
	await(screen_text.text_finished) # Wait for text to finish animating
	await(get_tree().create_timer(GameManager.text_pause).timeout)
	battle_buttons.show()

func _on_pay_button_pressed() -> void:
	ambush_choices.hide()
	load_sfx(sfx_confirm)
	sfx_player.play()
	GameManager.coins -= coin_cost
	update_coin_label() # Show the coin changes on the UI
	display_message("\"That's right, cough it up.\"\n\n\"Now scram!\"")
	await(screen_text.text_finished) # Wait for text to finish animating
	await(get_tree().create_timer(GameManager.text_pause).timeout)
	var next_scene: String = get_next_scene()
	# Wait briefly
	await(get_tree().create_timer(0.2).timeout)
	# Play leaving animation
	player_sprite.play("run")
	player_animator.play("leaving_battle")
	# Play fade animation
	animation_player.play("scene_fade")
	await(get_tree().create_timer(2.5).timeout)
	# Pre-transition storing, updating, and cleaning
	GameManager.refresh_storage() # Clean up any empty storage entries
	# Change scene
	get_tree().change_scene_to_file(GameManager.scenes[next_scene])

func _on_run_button_pressed() -> void:
	ambush_choices.hide()
	load_sfx(sfx_confirm)
	sfx_player.play()
	player_sprite.flip_h = true
	display_message("\"Hah!\"\n\n\"You're not getting away that easily.\"")
	enemy_sprite.play("magic")
	await enemy_sprite.animation_finished
	ambush_animator.play("battle_anims/enemy_fireball")
	load_sfx(sfx_fireball)
	sfx_player.play()
	enemy_sprite.play("idle")
	await ambush_animator.animation_finished
	set_player_HP(-health_cost)
	player_animator.play("player_damaged")
	player_sprite.play("hurt")
	await player_sprite.animation_finished
	# Play leaving animation
	player_sprite.play("run")
	player_animator.play("leaving_shop")
	# Play fade animation
	animation_player.play("scene_fade")
	await(get_tree().create_timer(2.5).timeout)
	# Pre-transition storing, updating, and cleaning
	GameManager.refresh_storage() # Clean up any empty storage entries
	# Change scene
	var next_scene: String = get_next_scene()
	get_tree().change_scene_to_file(GameManager.scenes[next_scene])

func play_hover_sfx() -> void:
	load_ui_sfx(sfx_hover)
	ui_player.play()

func _on_pay_button_mouse_entered() -> void:
	if not pay_button.disabled:
		load_ui_sfx(sfx_hover)
		ui_player.play()

func _on_run_button_mouse_entered() -> void:
	if not run_button.disabled:
		load_ui_sfx(sfx_hover)
		ui_player.play()
