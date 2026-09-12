extends Node

class_name Item

const is_equipped: bool = false # Used for comparison with equippable objects
const quality: int = 1 # Used for comparison with quality items

var obj_name: String = "item" # The name of this "object"
var power: int # Effectiveness/potency
var type: String # Which kind of item
var duration: int # How many turns it lasts
var id: int # Reference number for usable_items list
var buy_price: int # Value in the shop for buying
var sell_price: int # Value in the shop for selling
var icon: CompressedTexture2D # Icon used for display lists
var tooltip: String # Information shown on hovering over UI
var storage_index: int # The indexed location in GameManager storage 
var display_index: int # The indexed location in the ItemList display
var uses: int # How many times the item can be used
var anim: String # Name of animation to play

func _init(new_name: String, new_power: int, new_type: String, new_duration: int, new_uses: int, 
	new_price: int, new_id: int, new_icon: CompressedTexture2D, new_tooltip: String, new_anim: String) -> void:
	name = new_name
	power = new_power
	type = new_type
	duration = new_duration
	uses = new_uses
	id = new_id
	buy_price = new_price
	sell_price = round(buy_price * GameManager.sell_ratio)
	icon = new_icon
	tooltip = new_tooltip
	anim = new_anim

func get_data() -> ItemData:
	var data: ItemData = ItemData.new()
	data.data_name = name
	data.obj_name = obj_name
	data.power = power
	data.type = type
	data.duration = duration
	data.id = id
	data.buy_price = buy_price
	data.sell_price = sell_price
	data.icon = icon
	data.tooltip = tooltip
	data.storage_index = storage_index
	data.display_index = display_index
	data.uses = uses
	data.anim = anim
	return data

func create_copy() -> Item:
	return Item.new(name, power, type, duration, uses, buy_price, id, icon, tooltip, anim)
