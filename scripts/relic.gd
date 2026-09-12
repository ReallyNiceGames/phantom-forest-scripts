extends Node

class_name Relic

var stats = {
	"defence": 0,
	"accuracy": 0.0,
	"speed": 0.0,
}

var obj_name: String = "relic"
var is_equipped: bool = false # Used for comparison with equippable objects
var buy_price: int
var sell_price: int = 0
var quality: int
var id: int
var icon: CompressedTexture2D
var tooltip: String
var spell: Magic
var storage_index: int # The indexed location in GameManager storage
var display_index: int # The indexed location in the ItemList display

func _init(new_name: String, new_stats: Array, new_price: int, new_quality: int, new_id: int,
	new_icon: CompressedTexture2D, new_tooltip: String, new_spell: Magic) -> void:
	name = new_name
	var x: int = 0
	var y: int = new_stats.size()
	for stat in stats: # Assign stats through array
		stats[stat] = new_stats[x]
		x += 1
		if x >= y:
			break
	buy_price = new_price
	quality = new_quality
	id = new_id
	icon = new_icon
	tooltip = new_tooltip
	spell = new_spell

func get_data() -> RelicData:
	var data: RelicData = RelicData.new()
	data.data_name = name
	data.stats = get_stats()
	data.obj_name = obj_name
	data.is_equipped = is_equipped
	data.buy_price = buy_price
	data.sell_price = sell_price
	data.quality = quality
	data.id = id
	data.icon = icon
	data.tooltip = tooltip
	data.spell = spell.get_data()
	data.storage_index = storage_index
	data.display_index = display_index
	return data

func get_stats() -> Array:
	return [stats["defence"], stats["accuracy"], stats["speed"]]

func create_copy() -> Relic:
	var copied_spell: Magic = spell.create_copy()
	var copy: Relic = Relic.new(name, get_stats(), buy_price, quality, id, icon, tooltip, copied_spell)
	copy.is_equipped = is_equipped
	return copy

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			on_predelete()

func on_predelete() -> void:
	# DELETE THE STORED SPELL
	spell.free()
