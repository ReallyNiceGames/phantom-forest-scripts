extends "res://assets/scripts/saved_data.gd"

class_name SkillData

@export var power: int # Effectiveness/potency
@export var type: String # Which kind of skill
@export var duration: int # How many turns it lasts
@export var icon: CompressedTexture2D # Icon used for display lists
@export var display_index: int # The indexed location in the ItemList display
