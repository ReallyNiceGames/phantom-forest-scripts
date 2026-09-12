extends Node

class_name Status

var obj_name: String = "status" # The name of this "object"
var power: float # Effectiveness/potency
var type: String # Which kind of status
var duration: int # How many turns it lasts
var target: String # Who it's affecting
var is_buff: bool # Is it a buff or debuff
var icon: CompressedTexture2D # Representing icon displayed on interface
var tooltip: String # Information shown on hovering over UI
var storage_index: int # The indexed location in buffs/debuffs list

func _init(new_name: String, new_power: float, new_type: String, new_duration: int, new_target: String, 
	new_buff: bool, new_icon: CompressedTexture2D, new_tooltip: String) -> void:
	name = new_name
	power = new_power
	type = new_type
	duration = new_duration
	target = new_target
	is_buff = new_buff
	icon = new_icon
	tooltip = new_tooltip
