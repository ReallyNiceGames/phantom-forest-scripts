extends Node

class_name Weapon

var obj_name: String = "weapon" # The name of this "object"
var id: int # Reference number for weapons list
var quality: int # The overall usefulness of the weapon and its skills
var icon: CompressedTexture2D # Icon used for display lists
var tooltip: String # Information shown on hovering over UI
var buy_price: int # Value in the shop for buying
var sell_price: int = 0
var is_equipped: bool = false # If the player is currently holding this weapon
var storage_index: int # The indexed location in GameManager storage
var display_index: int # The index location in a display list
var skills: Array = [] # Stores the actions that are enabled by having the weapon

func _init(new_name: String, new_price: int, new_id: int, new_quality: int,
	new_skills: Array, new_icon: CompressedTexture2D, new_tooltip: String) -> void:
	name = new_name
	id = new_id
	buy_price = new_price
	quality = new_quality
	skills = new_skills
	icon = new_icon
	tooltip = new_tooltip

func get_data() -> WeaponData:
	var data: WeaponData = WeaponData.new()
	data.data_name = name
	data.obj_name = obj_name
	data.id = id
	data.quality = quality
	data.icon = icon
	data.tooltip = tooltip
	data.buy_price = buy_price
	data.sell_price = sell_price
	data.is_equipped = is_equipped
	data.storage_index = storage_index
	data.display_index = display_index
	for skill in skills:
		data.skills.append(skill.get_data())
	return data

func create_copy() -> Weapon:
	var copied_skills: Array = skills.map(func(x): return x.create_copy())
	var copy: Weapon = Weapon.new(name, buy_price, id, quality, copied_skills, icon, tooltip)
	copy.is_equipped = is_equipped
	return copy

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			on_predelete()

func on_predelete() -> void:
	# DELETE ALL STORED SKILLS
	for skill in skills:
		skill.free()
