extends Node

class_name Armour

var stats = {
	"HP": 0,
	"HP_regen": 0,
	"MP": 0,
	"MP_regen": 0,
	"defence": 0,
	"attack": 0,
	"spellpower": 0,
}

var obj_name: String = "armour"
var slot: String # Which armour slot this piece fits in
var id: int # Reference number for armour_pieces list
var quality: int # The overall usefulness of the armour piece
var buy_price: int # Value in the shop for buying
var sell_price: int # Value in the shop for selling
var icon: CompressedTexture2D # Icon used for display lists
var tooltip: String # Information shown on hovering over UI
var storage_index: int # The indexed location in GameManager storage 
var display_index: int # The indexed location in the ItemList display
var is_equipped: bool = false

func _init(new_name: String, new_stats: Array, new_slot: String, new_id: int, new_quality: int, 
	new_price: int, new_icon: CompressedTexture2D, new_tooltip: String) -> void:
	name = new_name
	var x: int = 0
	var y: int = new_stats.size()
	for stat in stats: # Assign stats through array
		stats[stat] = new_stats[x]
		x += 1
		if x >= y:
			break
	slot = new_slot
	id = new_id
	quality = new_quality
	buy_price = new_price
	sell_price = round(buy_price * GameManager.sell_ratio)
	icon = new_icon
	tooltip = new_tooltip

func get_data() -> ArmourData:
	var data: ArmourData = ArmourData.new()
	data.data_name = name
	data.stats = get_stats()
	data.obj_name = obj_name
	data.slot = slot
	data.id = id
	data.quality = quality
	data.buy_price = buy_price
	data.sell_price = sell_price
	data.icon = icon
	data.tooltip = tooltip
	data.storage_index = storage_index
	data.display_index = display_index
	data.is_equipped = is_equipped
	return data

func get_stats() -> Array:
	return [
		stats["HP"], stats["HP_regen"], stats["MP"], stats["MP_regen"], stats["defence"], stats["attack"], stats["spellpower"]
	]

func create_copy() -> Armour:
	var copy: Armour = Armour.new(name, get_stats(), slot, id, quality, buy_price, icon, tooltip)
	copy.is_equipped = is_equipped
	return copy
