extends Resource

class_name Checkpoint

# Globals
@export var best_stage: int
@export var player_max_HP: int
@export var player_HP: int
@export var player_HP_regen: int
@export var player_max_MP: int
@export var player_MP: int
@export var player_MP_regen: int
@export var player_defence: int
@export var player_attack_power: int
@export var player_spellpower: int
@export var player_accuracy: float
@export var player_speed: float
@export var lyra_obtained: bool
@export var vandar_obtained: bool
@export var amarok_obtained: bool
@export var relics_collected: bool
@export var rascal_obtained: bool
@export var enemy_HP_multiplier: float
@export var enemy_attack_multiplier: float
@export var enemy_spell_multiplier: float
@export var enemy_HP_scaling: float
@export var enemy_attack_scaling: float
@export var enemy_spell_scaling: float
@export var enemy_id: int
@export var level: int
@export var coins: int
@export var shop_chance: float
@export var event_chance: float
@export var event_recent: String
@export var ambush_seen: bool
@export var gamble_seen: bool
@export var grove_seen: bool
# Nodes
@export var stored_weapons: Array[WeaponData] = []
@export var stored_items: Array[ItemData] = []
@export var stored_magic: Array[MagicData] = []
@export var stored_armour: Array[ArmourData] = []
@export var stored_relics: Array[RelicData] = []
