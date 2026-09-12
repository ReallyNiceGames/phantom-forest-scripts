extends "res://assets/scripts/saved_data.gd"

class_name MagicData

@export var power: float # Effectiveness/potency
@export var type: String # Which kind of magic
@export var duration: int # How many turns it lasts
@export var cost: int # Determines how much MP the spell costs
@export var icon: CompressedTexture2D # Icon used for display lists
@export var buy_price: int # Value in the shop for buying
@export var sell_price: int # Value in the shop for selling
@export var storage_index: int # The indexed location in GameManager storage
@export var display_index: int # The indexed location in the ItemList display
