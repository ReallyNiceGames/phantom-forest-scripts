extends Node

class_name Magic

const is_equipped: bool = false # Used for comparison with equippable objects
const quality: int = 2 # Used for comparison with quality items

var obj_name: String = "magic" # The name of this "object"
var power: float # Effectiveness/potency
var type: String # Which kind of magic
var duration: int # How many turns it lasts
var cost: int # Determines how much MP the spell costs
var id: int # Reference number for magic_spells list
var icon: CompressedTexture2D # Icon used for display lists
var tooltip: String # Information shown on hovering over UI
var buy_price: int # Value in the shop for buying
var sell_price: int # Value in the shop for selling
var storage_index: int # The indexed location in GameManager storage
var display_index: int # The indexed location in the ItemList display


func _init(new_name: String, new_power: float, new_type: String, new_duration: int, new_cost: int, 
	new_price: int, new_id: int, new_icon: CompressedTexture2D, new_tooltip: String) -> void:
	name = new_name
	power = new_power
	type = new_type
	duration = new_duration
	cost = new_cost
	id = new_id
	buy_price = new_price
	sell_price = round(buy_price * GameManager.sell_ratio)
	icon = new_icon
	tooltip = new_tooltip

func get_data() -> MagicData:
	var data: MagicData = MagicData.new()
	data.data_name = name
	data.obj_name = obj_name
	data.power = power
	data.type = type
	data.duration = duration
	data.cost = cost
	data.id = id
	data.icon = icon
	data.tooltip = tooltip
	data.buy_price = buy_price
	data.sell_price = sell_price
	data.storage_index = storage_index
	data.display_index = display_index
	return data

func create_copy() -> Magic:
	return Magic.new(name, power, type, duration, cost, buy_price, id, icon, tooltip)
