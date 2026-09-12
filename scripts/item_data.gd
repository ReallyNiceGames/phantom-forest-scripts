extends "res://assets/scripts/saved_data.gd"

class_name ItemData

@export var power: int # Effectiveness/potency
@export var type: String # Which kind of item
@export var duration: int # How many turns it lasts
@export var buy_price: int # Value in the shop for buying
@export var sell_price: int # Value in the shop for selling
@export var icon: CompressedTexture2D # Icon used for display lists
@export var storage_index: int # The indexed location in GameManager storage 
@export var display_index: int # The indexed location in the ItemList display
@export var uses: int # How many times the item can be used
@export var anim: String # Name of animation to play
