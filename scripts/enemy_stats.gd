extends AnimatedSprite2D

@export var base_health: int
@export var base_attack: int
@export var base_spellpower: int
@export var base_speed: float
@export var base_accuracy: float

func get_stats() -> Array:
	return [base_health, base_attack, base_spellpower, base_speed, base_accuracy]
