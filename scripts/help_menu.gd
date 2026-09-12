extends PanelContainer

@onready var weapon_icon: TextureRect = $Content/Tabs/Combat/Concepts/Images/Content/WeaponIcon
@onready var magic_icon: TextureRect = $Content/Tabs/Combat/Concepts/Images/Content/MagicIcon
@onready var item_icon: TextureRect = $Content/Tabs/Combat/Concepts/Images/Content/ItemIcon
@onready var misc_icon: TextureRect = $Content/Tabs/Combat/Concepts/Images/Content/MiscIcon
@onready var combat_title: Label = $Content/Tabs/Combat/Description/DescriptionTitle
@onready var combat_desc: Label = $Content/Tabs/Combat/Description/DescriptionContent
@onready var sword_icon: TextureRect = $Content/Tabs/Equipment/Concepts/Images/Content/SwordIcon
@onready var armour_icon: TextureRect = $Content/Tabs/Equipment/Concepts/Images/Content/ArmourIcon
@onready var relic_icon: TextureRect = $Content/Tabs/Equipment/Concepts/Images/Content/RelicIcon
@onready var equipment_title: Label = $Content/Tabs/Equipment/Description/DescriptionTitle
@onready var equipment_desc: Label = $Content/Tabs/Equipment/Description/DescriptionContent
@onready var buying_icon: TextureRect = $Content/Tabs/Shops/Concepts/Images/Content/BuyingIcon
@onready var selling_icon: TextureRect = $Content/Tabs/Shops/Concepts/Images/Content/SellingIcon
@onready var shops_title: Label = $Content/Tabs/Shops/Description/DescriptionTitle
@onready var shops_desc: Label = $Content/Tabs/Shops/Description/DescriptionContent
@onready var camp_icon: TextureRect = $Content/Tabs/Events/Concepts/Images/Content/TopContent/CampIcon
@onready var ambush_icon: TextureRect = $Content/Tabs/Events/Concepts/Images/Content/TopContent/AmbushIcon
@onready var gamble_icon: TextureRect = $Content/Tabs/Events/Concepts/Images/Content/BottomContent/GambleIcon
@onready var grove_icon: TextureRect = $Content/Tabs/Events/Concepts/Images/Content/BottomContent/GroveIcon
@onready var events_title: Label = $Content/Tabs/Events/Description/DescriptionTitle
@onready var events_desc: Label = $Content/Tabs/Events/Description/DescriptionContent

signal concept_hovered
signal tab_changed
signal close_pressed

enum TAB {
	COMBAT = 0,
	EQUIPMENT = 1,
	SHOPS = 2,
	EVENTS = 3,
}

const fade: Color = Color(1,1,1,0.7)
const unfade: Color = Color(1,1,1,1)
const pause_length: float = 0.05

var default_combat_title: String
var default_combat_desc: String
var default_equipment_title: String
var default_equipment_desc: String
var default_shops_title: String
var default_shops_desc: String
var default_events_title: String
var default_events_desc: String

var active_tab: int
var active_concept: TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_combat_title = combat_title.text
	default_combat_desc = combat_desc.text
	default_equipment_title = equipment_title.text
	default_equipment_desc = equipment_desc.text
	default_shops_title = shops_title.text
	default_shops_desc = shops_desc.text
	default_events_title = events_title.text
	default_events_desc = events_desc.text

func display_concept(new_concept: TextureRect, title: String) -> void:
	if new_concept != active_concept:
		if active_concept:
			active_concept.modulate = unfade
		active_concept = new_concept
		new_concept.modulate = fade
		match active_tab:
			TAB.COMBAT:
				combat_title.text = title
				combat_desc.text = new_concept.tooltip_text
			TAB.EQUIPMENT:
				equipment_title.text = title
				equipment_desc.text = new_concept.tooltip_text
			TAB.SHOPS:
				shops_title.text = title
				shops_desc.text = new_concept.tooltip_text
			TAB.EVENTS:
				events_title.text = title
				events_desc.text = new_concept.tooltip_text
		concept_hovered.emit()

func display_default() -> void:
	if active_concept:
		active_concept.modulate = unfade
	active_concept = null
	match active_tab:
		TAB.COMBAT:
			combat_title.text = default_combat_title
			combat_desc.text = default_combat_desc
		TAB.EQUIPMENT:
			equipment_title.text = default_equipment_title
			equipment_desc.text = default_equipment_desc
		TAB.SHOPS:
			shops_title.text = default_shops_title
			shops_desc.text = default_shops_desc
		TAB.EVENTS:
			events_title.text = default_events_title
			events_desc.text = default_events_desc

func _on_tabs_tab_changed(tab: int) -> void:
	active_tab = tab
	display_default()
	tab_changed.emit()

func _on_weapon_icon_mouse_entered() -> void:
	display_concept(weapon_icon, "Weapon Button")

func _on_magic_icon_mouse_entered() -> void:
	display_concept(magic_icon, "Magic Button")

func _on_item_icon_mouse_entered() -> void:
	display_concept(item_icon, "Item Button")

func _on_misc_icon_mouse_entered() -> void:
	display_concept(misc_icon, "Misc Button")

func _on_sword_icon_mouse_entered() -> void:
	display_concept(sword_icon, "Weapons")

func _on_armour_icon_mouse_entered() -> void:
	display_concept(armour_icon, "Armour")

func _on_relic_icon_mouse_entered() -> void:
	display_concept(relic_icon, "Relics")

func _on_buying_icon_mouse_entered() -> void:
	display_concept(buying_icon, "Buying")

func _on_selling_icon_mouse_entered() -> void:
	display_concept(selling_icon, "Selling")

func _on_camp_icon_mouse_entered() -> void:
	display_concept(camp_icon, "Camp")

func _on_ambush_icon_mouse_entered() -> void:
	display_concept(ambush_icon, "Ambush")

func _on_gamble_icon_mouse_entered() -> void:
	display_concept(gamble_icon, "Gamble")

func _on_grove_icon_mouse_entered() -> void:
	display_concept(grove_icon, "Grove")

func _on_close_button_pressed() -> void:
	close_pressed.emit()

func _on_close_button_mouse_entered() -> void:
	concept_hovered.emit()
