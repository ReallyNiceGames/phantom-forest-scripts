extends Node

class_name Enemy

var prefix: String = ""
var full_name: String
var type: String = "basic"
var max_HP: float
var HP: float
var HP_regen: int = 0
var attack_power: float
var spellpower: float
var temp_attack: int = 0
var temp_spell: int = 0
var speed: float = 1.0
var buffs: Array = []
var debuffs: Array = []
var accuracy: float = 1.0
var id: int = -1
var actions: Array[Action] = []
var action_slots: Array = [-1,-1,-1,-1,-1] # Slots for storing enemy action IDs
var recent_slot: int = -1 # Stores the most recently-used action slot to prevent it being randomly used twice in a row
var is_alive: bool = true

func _init(new_name: String, new_prefix: String, new_type: String, new_HP: float, new_attack: float, 
	new_spell: float, new_actions: Array, new_id: int) -> void:
	name = new_name
	prefix = new_prefix
	full_name = prefix + name
	type = new_type
	max_HP = new_HP
	HP = max_HP
	attack_power = new_attack
	spellpower = new_spell
	actions = new_actions
	id = new_id
	set_slots()

func set_slots() -> void:
	# Store enemy actions in slots
	var curr_action: int = 0
	for x in action_slots.size():
		if curr_action < actions.size():
			action_slots[x] = actions[curr_action]
		else:
			curr_action = 0
			action_slots[x] = actions[curr_action]
		curr_action += 1

func set_stats(stats: Array) -> void:
	if type == "boss":
		max_HP = stats[0]
		HP = max_HP
		attack_power = stats[1]
		spellpower = stats[2]
		speed = stats[3]
		accuracy = stats[4]
	else:
		max_HP = round(max_HP * stats[0])
		HP = max_HP
		attack_power = round(attack_power * stats[1])
		spellpower = round(spellpower * stats[2])
		speed = stats[3]
		accuracy = stats[4]

func get_action(index: int) -> Action:
	var action: Action = actions[index]
	action.refresh() # Reset variables
	# Find the function corresponding to the action name
	var use_action: Callable = Callable(self, action.name)
	use_action.call(action)
	return action

func get_random_action() -> Action:
	# Create a random number to decide next enemy action
	var random_chance: float = randf()
	var action: Action
	# 5 action slots - 30%, 25%, 20%, 15% and 10% chance to be used
	# Fills slots with duplicates when enemy has < 5 different actions
	if random_chance < 0.3 and recent_slot != 0:
		action = action_slots[0]
		recent_slot = 0
	elif random_chance < 0.55 and recent_slot != 1:
		action = action_slots[1]
		recent_slot = 1
	elif random_chance < 0.75 and recent_slot != 2:
		action = action_slots[2]
		recent_slot = 2
	elif random_chance < 0.90 and recent_slot != 3:
		action = action_slots[3]
		recent_slot = 3
	elif recent_slot != 4:
		action = action_slots[4]
		recent_slot = 4
	else:
		action = action_slots[0]
		recent_slot = 0
	action.refresh() # Reset variables
	# Find the function corresponding to the action name
	var use_action: Callable = Callable(self, action.name)
	use_action.call(action)
	return action

func attack(action: Action) -> void:
	if accuracy >= randf():
		# Calculate the damage the attack will do to the player
		if accuracy > randf() + 1:
			action.player_HP_damage = max(0, round((GameManager.crit_ratio * attack_power * action.power_ratio) - 
				(GameManager.player_defence + GameManager.player_temp_defence)))
			# Create text to display on screen
			action.text = "%s attacks and does %d (critical) damage!" % [name, action.player_HP_damage]
		else: 
			action.player_HP_damage = max(0, round((attack_power * action.power_ratio) - 
				(GameManager.player_defence + GameManager.player_temp_defence)))
			# Create text to display on screen
			action.text = "%s attacks and does %d damage!" % [name, action.player_HP_damage]
		# Add an animation to play
		action.self_sprite = "attack"
		action.self_sprite_sfx = "swipe"
		if action.player_HP_damage: # Add animation only if attack does damage
			action.player_anim = "player_damaged"
			action.player_sprite = "hurt"
	else:
		# Create text to display on screen
		action.text = "%s attacks and misses!" % [name]
		action.self_sprite = "attack"
		action.self_sprite_sfx = "miss"

func idle(action: Action) -> void:
	# Create text to display on screen
	var random: int = randi() % 3
	match random:
		0:
			action.text = "%s bides their time." % [name]
		1:
			action.text = "%s seems overconfident." % [name]
		2:
			action.text = "%s shuffles about." % [name]

func rend(action: Action) -> void:
	if accuracy >= randf():
		# Calculate the damage the attack will do to the player
		if accuracy > randf() + 1:
			action.player_HP_degen = round((GameManager.crit_ratio * 0.5) * attack_power * action.power_ratio)
			# Create text to display on screen
			action.text = "%s viciously slices you!\nYou now bleed for %d (critical) damage each turn." % [name, action.player_HP_degen]
		else:
			action.player_HP_degen = round(attack_power * action.power_ratio)
			# Create text to display on screen
			action.text = "%s viciously slices you!\nYou now bleed for %d damage each turn." % [name, action.player_HP_degen]
		# Create status
		action.statuses_to_apply.append(GameManager.create_status(name, action.player_HP_degen, action.type, action.duration, "player"))
		# Add animation
		action.self_sprite = "attack"
		action.self_sprite_sfx = "swipe"
		action.battle_anim = "player_bleed"
		action.battle_anim_sfx = "debuff"
	else:
		# Create text to display on screen
		action.text = "%s attempts to slice you and misses!" % [name]
		action.self_sprite = "attack"
		action.self_sprite_sfx = "miss"

func heal(action: Action) -> void:
	# Calculate the recovered health
	action.self_HP_heal = round(min(max_HP - HP, spellpower * action.power_ratio))
	# Create text to display on screen
	action.text = "%s channels healing magic.\nThey gain %d HP." % [name, action.self_HP_heal]
	# Add an animation to play
	action.battle_anim = "enemy_heart"
	action.battle_anim_sfx = "buff"
	if action.self_HP_heal: # Only play animation if HP is gained
		action.self_anim = "enemy_healed"

func regenerate(action: Action) -> void:
	# Calculate the health increments each turn
	action.self_HP_regen = round(spellpower * action.power_ratio)
	HP_regen += action.self_HP_regen
	# Create text to display on screen
	action.text = "%s begins regenerating.\nThey now gain %d HP each turn." % [name, action.self_HP_regen]
	# Create status
	action.statuses_to_apply.append(GameManager.create_status(name, action.self_HP_regen, action.type, action.duration, name))
	# Add animation
	action.battle_anim = "enemy_heart"
	action.battle_anim_sfx = "buff"

func leech(action: Action) -> void:
	# Calculate the damage the attack will do to the player
	action.player_HP_damage = round(spellpower * action.power_ratio)
	action.player_MP_damage = round(action.player_HP_damage / 2)
	action.self_HP_heal = action.player_HP_damage
	# Create text to display on screen
	action.text = "%s leeches %d HP and %d MP from you!" % [name, action.player_HP_damage, action.player_MP_damage]
	# Add an animation to play
	action.self_sprite = "magic"
	action.self_sprite_sfx = "leech"
	action.self_anim = "heal_flash"
	if action.player_HP_damage:
		action.player_anim = "player_damaged"
		action.player_sprite = "hurt"

func fireball(action: Action) -> void:
	# Calculate the damage the attack will do to the player
	action.player_HP_damage = round(spellpower * action.power_ratio)
	# Create text to display on screen
	action.text = "%s channels a fireball!\nYou take %d damage!" % [name, action.player_HP_damage]
	# Add an animation to play
	action.self_sprite = "magic"
	action.battle_anim = "enemy_fireball"
	action.battle_anim_sfx = "fireball"
	if action.player_HP_damage:
		action.player_anim = "player_damaged"
		action.player_sprite = "hurt"

func sunder(action: Action) -> void:
	if accuracy >= randf():
		action.player_HP_damage = max(0, round((attack_power * action.power_ratio) - 
			(GameManager.player_defence + GameManager.player_temp_defence)))
		action.player_def_down = round(attack_power * action.power_ratio)
		action.text = "%s sunders your defences!\nYou take %d damage.\nYour defence decreases by %d." % [name, action.player_HP_damage, action.player_def_down]
		action.statuses_to_apply.append(GameManager.create_status(name, action.player_def_down, action.type, action.duration, "player"))
		action.self_sprite = "attack"
		action.self_sprite_sfx = "swipe"
		action.battle_anim = "player_cracked"
		action.battle_anim_sfx = "debuff"
		if action.player_HP_damage:
			action.player_anim = "player_damaged"
			action.player_sprite = "hurt"
	else:
		# Create text to display on screen
		action.text = "%s tries to break your defences but misses!" % [name]
		action.self_sprite = "attack"
		action.self_sprite_sfx = "miss"

func pulverise(action: Action) -> void:
	if accuracy >= randf():
		# Calculate the damage the attack will do to the player
		if accuracy > randf() + 1:
			action.player_HP_damage = max(0, round((GameManager.crit_ratio * attack_power * action.power_ratio) - 
				(GameManager.player_defence + GameManager.player_temp_defence)))
			# Create text to display on screen
			action.text = "%s charges an attack and pulverises you for %d (critical) damage!" % [name, action.player_HP_damage]
		else:
			action.player_HP_damage = max(0, round((attack_power * action.power_ratio) - 
				(GameManager.player_defence + GameManager.player_temp_defence)))
			# Create text to display on screen
			action.text = "%s charges an attack and pulverises you for %d damage!" % [name, action.player_HP_damage]
		# Add an animation to play
		action.self_sprite = "attack"
		action.self_sprite_sfx = "impact"
		if action.player_HP_damage: # Add animation only if attack does damage
			action.player_anim = "player_damaged"
			action.player_sprite = "hurt"
	else:
		# Create text to display on screen
		action.text = "%s charges an attack and misses!" % [name]
		action.self_sprite = "attack"
		action.self_sprite_sfx = "miss"

func curse(action: Action) -> void:
	# Tells action to disable item button on player
	action.player_disable_items = true
	# Create text to display on screen
	action.text = "%s conjures a vile curse upon you.\nItems cannot be used!" % [name]
	action.self_sprite = "magic"
	action.battle_anim = "player_skull"
	action.player_anim = "player_cursed"
	action.statuses_to_apply.append(GameManager.create_status(name, 0, action.type, action.duration, "player"))

func siphon(action: Action) -> void:
	action.player_HP_degen = round(spellpower * action.power_ratio)
	action.self_HP_regen = action.player_HP_degen
	HP_regen += action.self_HP_regen
	action.text = "%s binds your life force with theirs!\nBleeding %d HP every turn." % [name, action.player_HP_degen]
	action.self_sprite = "magic"
	action.self_sprite_sfx = "siphon"
	action.battle_anim = "player_bleed"
	action.battle_anim_sfx = "debuff"
	action.statuses_to_apply.append(GameManager.create_status(name, action.player_HP_degen, "bleeding", action.duration, "player"))
	action.statuses_to_apply.append(GameManager.create_status(name, action.self_HP_regen, "HP regen", action.duration, name))

func screech(action: Action) -> void:
	action.player_speed_down = action.power_ratio
	action.text = "%s unleashes a chilling screech!\nYou have a +%d%% chance to skip your turn." % [name, action.player_speed_down * 100]
	action.statuses_to_apply.append(GameManager.create_status(name, action.player_speed_down, action.type, action.duration, "player"))
	action.battle_anim = "player_slow"
	action.battle_anim_sfx = "screech"

func fog(action: Action) -> void:
	action.player_accuracy_down = action.power_ratio
	action.text = "%s chants ominously, fog begins to roll in.\nYou have a +%d%% chance to miss weapon attacks." % [name, action.player_accuracy_down * 100]
	action.statuses_to_apply.append(GameManager.create_status(name, action.player_accuracy_down, action.type, action.duration, "player"))
	action.battle_anim = "player_miss"
	action.battle_anim_sfx = "fog"

func hellfire(action: Action) -> void:
	# Calculate the damage the attack will do to the player
	action.player_HP_damage = round(spellpower * action.power_ratio)
	# Create text to display on screen
	action.text = "%s channels a hellish fireball!\nYou take %d damage!" % [name, action.player_HP_damage]
	# Add an animation to play
	action.self_sprite = "magic"
	action.battle_anim = "enemy_fireball"
	action.battle_anim_sfx = "fireball"
	if action.player_HP_damage:
		action.player_anim = "player_damaged"
		action.player_sprite = "hurt"

func ignite(action: Action) -> void:
	# Calculate the damage the attack will do to the player
	action.player_HP_degen = round(spellpower * action.power_ratio)
	# Create text to display on screen
	action.text = "%s spews flame and sets you alight!\nYou are now burning for %d damage each turn." % [name, action.player_HP_degen]
	# Create status
	action.statuses_to_apply.append(GameManager.create_status(name, action.player_HP_degen, action.type, action.duration, "player"))
	# Add animation
	action.self_sprite = "magic"
	action.battle_anim = "enemy_flame"
	action.battle_anim_sfx = "fireball"

func mend_flesh(action: Action) -> void:
	# Calculate the recovered health
	action.self_HP_heal = round(min(max_HP - HP, spellpower * action.power_ratio))
	# Create text to display on screen
	action.text = "%s restores their body with ease!\nThey gain %d HP." % [name, action.self_HP_heal]
	# Add an animation to play
	action.battle_anim = "enemy_heart"
	action.battle_anim_sfx = "buff"
	if action.self_HP_heal: # Only play animation if HP is gained
		action.self_anim = "enemy_healed"

func obliterate(action: Action) -> void:
	if accuracy >= randf():
		# Calculate the damage the attack will do to the player
		if accuracy > randf() + 1:
			action.player_HP_damage = max(0, round((GameManager.crit_ratio * attack_power * action.power_ratio) - 
				(GameManager.player_defence + GameManager.player_temp_defence)))
			# Create text to display on screen
			action.text = "%s unleashes a barrage of attacks!\nYou take %d (critical) damage!" % [name, action.player_HP_damage]
		else: 
			action.player_HP_damage = max(0, round((attack_power * action.power_ratio) - 
				(GameManager.player_defence + GameManager.player_temp_defence)))
			# Create text to display on screen
			action.text = "%s unleashes a barrage of attacks!\nYou take %d damage!" % [name, action.player_HP_damage]
		# Add an animation to play
		action.self_sprite = "attack"
		action.self_sprite_sfx = "impact"
		if action.player_HP_damage: # Add animation only if attack does damage
			action.player_anim = "player_damaged"
			action.player_sprite = "hurt"
	else:
		# Create text to display on screen
		action.text = "%s unleashes a barrage of attacks...\nMissing all of them!" % [name]
		action.self_sprite = "attack"
		action.self_sprite_sfx = "miss"

func expose(action: Action) -> void:
	if accuracy >= randf():
		action.player_HP_damage = max(0, round((attack_power * action.power_ratio) - 
			(GameManager.player_defence + GameManager.player_temp_defence)))
		action.player_def_down = round(attack_power * action.power_ratio)
		action.text = "%s tears through you!\nYou take %d damage and your defence decreases by %d." % [name, action.player_HP_damage, action.player_def_down]
		action.statuses_to_apply.append(GameManager.create_status(name, action.player_def_down, action.type, action.duration, "player"))
		action.self_sprite = "attack"
		action.self_sprite_sfx = "swipe"
		action.battle_anim = "player_cracked"
		action.battle_anim_sfx = "debuff"
		if action.player_HP_damage:
			action.player_anim = "player_damaged"
			action.player_sprite = "hurt"
	else:
		# Create text to display on screen
		action.text = "%s attempts to tear through your defences but misses!" % [name]
		action.self_sprite = "attack"
		action.self_sprite_sfx = "miss"

func azurefire_weapon(action: Action) -> void:
	if not GameManager.favor_active:
		# Calculate the damage the attack will do to the player
		action.player_HP_damage = round(spellpower * action.power_ratio)
		# Tells action to disable item button on player
		action.player_disable_weapon = true
		# Create text to display on screen
		action.text = "The air thickens into a haze.\n%s unleashes the azurefire dealing %d damage to you!\nThe azurefire suppresses your weapon!" % [name, action.player_HP_damage]
		action.self_sprite = "special"
		action.self_sprite_sfx = "runikesh_flame"
		action.battle_anim = "player_skull"
		action.player_anim = "player_cursed"
		action.player_sprite = "hurt"
		action.statuses_to_apply.append(GameManager.create_status(name, 0, action.type, action.duration, "player"))
	else:
		# Create text to display on screen
		action.text = "The air thickens into a haze. %s unleashes the azurefire... But Rascal's barrier stands firm against it!" % [name]
		action.self_sprite = "special"
		action.self_sprite_sfx = "runikesh_flame"

func azurefire_magic(action: Action) -> void:
	if not GameManager.favor_active:
		# Calculate the damage the attack will do to the player
		action.player_HP_damage = round(spellpower * action.power_ratio)
		# Tells action to disable item button on player
		action.player_disable_magic = true
		# Create text to display on screen
		action.text = "The air thickens into a haze.\n%s unleashes the azurefire dealing %d damage to you!\nThe azurefire suppresses your magic!" % [name, action.player_HP_damage]
		action.self_sprite = "special"
		action.self_sprite_sfx = "runikesh_flame"
		action.battle_anim = "player_skull"
		action.player_anim = "player_cursed"
		action.player_sprite = "hurt"
		action.statuses_to_apply.append(GameManager.create_status(name, 0, action.type, action.duration, "player")) 
	else:
		# Create text to display on screen
		action.text = "The air thickens into a haze. %s unleashes the azurefire... But Rascal's barrier stands firm against it!" % [name]
		action.self_sprite = "special"
		action.self_sprite_sfx = "runikesh_flame"

func runikesh_burn(action: Action) -> void:
	# Calculate the damage the attack will do to the player
	action.player_HP_degen = round(spellpower * action.power_ratio)
	# Create text to display on screen
	action.text = "%s takes a deep breath...\nIntense flames spew forth!\nYou are now burning for %d damage each turn." % [name, action.player_HP_degen]
	# Create status
	action.statuses_to_apply.append(GameManager.create_status(name, action.player_HP_degen, action.type, action.duration, "player"))
	# Add animation
	action.self_sprite = "magic"
	action.self_sprite_sfx = "runikesh_flame"

func runikesh_siphon(action: Action) -> void:
	action.player_HP_degen = round(spellpower * action.power_ratio)
	action.self_HP_regen = action.player_HP_degen
	HP_regen += action.self_HP_regen
	action.text = "The Lich hungers and you begin to wither.\nBleeding %d HP every turn." % [action.player_HP_degen]
	action.self_sprite = "attack"
	action.self_sprite_sfx = "fear"
	action.battle_anim = "player_bleed"
	action.battle_anim_sfx = "debuff"
	action.statuses_to_apply.append(GameManager.create_status(name, action.player_HP_degen, "bleeding", action.duration, "player"))
	action.statuses_to_apply.append(GameManager.create_status(name, action.self_HP_regen, "HP regen", action.duration, name))

func runikesh_smash(action: Action) -> void:
	if accuracy >= randf():
		# Calculate the damage the attack will do to the player
		if accuracy > randf() + 1:
			action.player_HP_damage = max(0, round((GameManager.crit_ratio * attack_power * action.power_ratio) - 
				(GameManager.player_defence + GameManager.player_temp_defence)))
			# Create text to display on screen
			action.text = "%s lunges mercilessly at you!\nYou take %d (critical) damage!" % [name, action.player_HP_damage]
		else: 
			action.player_HP_damage = max(0, round((attack_power * action.power_ratio) - 
				(GameManager.player_defence + GameManager.player_temp_defence)))
			# Create text to display on screen
			action.text = "%s lunges mercilessly at you!\nYou take %d damage!" % [name, action.player_HP_damage]
		# Add an animation to play
		action.self_sprite = "attack"
		action.self_sprite_sfx = "impact"
		if action.player_HP_damage: # Add animation only if attack does damage
			action.player_anim = "player_damaged"
			action.player_sprite = "hurt"
	else:
		# Create text to display on screen
		action.text = "%s lunges mercilessly at you...\nBut misses!" % [name]
		action.self_sprite = "attack"
		action.self_sprite_sfx = "miss"
	
func azurefire_lesser(action: Action) -> void:
	if not GameManager.favor_active:
		# Calculate the damage the attack will do to the player
		action.player_HP_damage = round(spellpower * action.power_ratio)
		# Tells action to disable item button on player
		action.player_disable_weapon = true
		# Create text to display on screen
		action.text = "The Phantom conjures a strange fire?\nIt chokes you for %d damage!\nYour weapon has stopped working!" % [action.player_HP_damage]
		action.self_sprite = "special"
		action.self_sprite_sfx = "runikesh_flame"
		action.battle_anim = "player_skull"
		action.player_anim = "player_cursed"
		action.player_sprite = "hurt"
		action.statuses_to_apply.append(GameManager.create_status(name, 0, action.type, action.duration, "player"))
	else:
		# Create text to display on screen
		action.text = "The Phantom conjures a strange fire?\nIt attempts to choke you but Rascal's barrier stands firm against it!" % [name]
		action.self_sprite = "special"
		action.self_sprite_sfx = "runikesh_flame"

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			on_predelete()

func on_predelete() -> void:
	# DELETE ALL STORED ACTIONS
	for action in actions:
		action.free()
