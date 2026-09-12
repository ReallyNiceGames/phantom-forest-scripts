extends Node

class_name Skill

var obj_name: String = "skill" # The name of this "object"
var power: int # Effectiveness/potency
var type: String # Which kind of skill
var duration: int # How many turns it lasts
var id: int # Reference number for weapon_skills list
var icon: CompressedTexture2D # Icon used for display lists
var tooltip: String # Information shown on hovering over UI
var display_index: int # The indexed location in the ItemList display

func _init(new_name: String, new_power: int, new_type: String, new_duration: int, 
	new_id: int, new_icon: CompressedTexture2D, new_tooltip: String) -> void:
	name = new_name
	power = new_power
	type = new_type
	duration = new_duration
	id = new_id
	icon = new_icon
	tooltip = new_tooltip

func get_data() -> SkillData:
	var data: SkillData = SkillData.new()
	data.data_name = name
	data.obj_name = obj_name
	data.id = id
	data.power = power
	data.type = type
	data.duration = duration
	data.icon = icon
	data.tooltip = tooltip
	data.display_index = display_index
	return data

func create_copy() -> Skill:
	return Skill.new(name, power, type, duration, id, icon, tooltip)
