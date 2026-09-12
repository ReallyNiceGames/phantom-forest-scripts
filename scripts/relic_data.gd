extends "res://assets/scripts/saved_data.gd"

class_name RelicData

@export var stats: Array
@export var is_equipped: bool = false # Used for comparison with equippable objects
@export var buy_price: int
@export var sell_price: int
@export var quality: int
@export var icon: CompressedTexture2D
@export var spell: MagicData
@export var storage_index: int # The indexed location in GameManager storage
@export var display_index: int # The indexed location in the ItemList display
