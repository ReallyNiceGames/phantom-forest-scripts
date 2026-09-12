extends "res://assets/scripts/saved_data.gd"

class_name WeaponData

@export var quality: int # The overall usefulness of the weapon and its skills
@export var icon: CompressedTexture2D # Icon used for display lists
@export var buy_price: int # Value in the shop for buying
@export var sell_price: int # Value in the shop for selling
@export var is_equipped: bool = false # If the player is currently holding this weapon
@export var display_index: int # The index location in a display list
@export var storage_index: int
@export var skills: Array[SkillData] = [] # Stores the actions that are enabled by having the weapon
