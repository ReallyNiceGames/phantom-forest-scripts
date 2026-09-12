extends "res://assets/scripts/saved_data.gd"

class_name ArmourData

@export var stats: Array
@export var slot: String # Which armour slot this piece fits in
@export var quality: int # The overall usefulness of the armour piece
@export var buy_price: int # Value in the shop for buying
@export var sell_price: int # Value in the shop for selling
@export var icon: CompressedTexture2D # Icon used for display lists
@export var storage_index: int # The indexed location in GameManager storage 
@export var display_index: int # The indexed location in the ItemList display
@export var is_equipped: bool = false
