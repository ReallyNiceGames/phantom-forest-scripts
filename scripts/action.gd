extends Node

# An "action" is what an enemy can do during their turn
class_name Action

var type: String = ""
var power_ratio: float = 1.0
var duration: int = 0
var id: int
var text: String = "" # The current text to put on screen
var self_sprite: String = "" # Sprite animation to play on enemy
var self_sprite_sfx: String = "" # SFX paired with sprite anim
var self_anim: String = "" # AnimationPlayer animation to play on enemy
var self_anim_sfx: String = "" # SFX paired with anim player
var player_sprite: String = "" # Sprite animation to play on player
var player_sprite_sfx: String = "" # SFX paired with sprite anim
var player_anim: String = "" # AnimationPlayer animation to play on player
var player_anim_sfx: String = "" # SFX paired with anim player
var battle_anim: String = "" # AnimationPlayer animation for the battle
var battle_anim_sfx: String = "" # General sound effect
var statuses_to_apply: Array = []
var player_HP_damage: int = 0
var player_MP_damage: int = 0
var player_HP_degen: int = 0
var player_def_down: int = 0
var player_speed_down: float = 0.0
var player_accuracy_down: float = 0.0
var player_disable_items: bool = false
var player_disable_weapon: bool = false
var player_disable_magic: bool = false
var self_HP_heal: int = 0
var self_HP_regen: int = 0

func _init(new_name: String, new_type: String, new_power: float, 
	new_duration: int, new_id: int) -> void:
	if new_name:
		name = new_name
	else:
		name = new_type
	type = new_type
	power_ratio = new_power
	duration = new_duration
	id = new_id
	
func refresh() -> void:
	# Refreshes variables for next use of this action
	text = "" # The current text to put on screen
	self_sprite = ""
	self_sprite_sfx = ""
	self_anim = ""
	self_anim_sfx = ""
	player_sprite = ""
	player_sprite_sfx = ""
	player_anim = ""
	player_anim_sfx = ""
	battle_anim = ""
	battle_anim_sfx = ""
	statuses_to_apply.clear()
	player_HP_damage = 0
	player_MP_damage = 0
	player_HP_degen = 0
	player_def_down = 0
	player_speed_down = 0.0
	player_accuracy_down = 0.0
	player_disable_items = false
	player_disable_weapon = false
	player_disable_magic = false
	self_HP_heal = 0
	self_HP_regen = 0
