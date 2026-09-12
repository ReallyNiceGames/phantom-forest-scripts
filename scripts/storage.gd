extends Control

@onready var buy_display: ItemList = $BuyDisplay
@onready var sell_display: ItemList = $SellDisplay
@onready var misc_display: ItemList = $MiscDisplay
@onready var equipment_menu: Panel = $EquipmentMenu
@onready var ui_audio: AudioStreamPlayer = $UIAudio

@export var sfx_confirm: AudioStream
@export var sfx_buy_sell: AudioStream

signal leaving_shop
signal bought_item
signal sold_item
signal stats_changed
signal restart_pressed
#signal send_message(text: String, hide: bool, wait: bool)

var active_menu: String = "none"
var stock: Array = [] # Holds the buyable stock
var too_expensive: Array = [] # Holds the indexes of unaffordable stock in the buy display

func _ready() -> void:
	stock = GameManager.generate_stock() # Creates stock for the player to buy
	display_buyable() # Add buyable items to buy display
	display_sellable() # Add sellable items to sell display
	display_misc() # Display misc options

func load_sfx(sfx_to_load:AudioStream) -> void:
	if ui_audio.stream != sfx_to_load:
		ui_audio.stop()
		ui_audio.stream = sfx_to_load

func display_sellable() -> void:
	# Clear any previous sellables
	sell_display.clear()
	# Creates a basic title
	sell_display.add_item("--------------- SELL ---------------", null, false)
	sell_display.set_item_tooltip_enabled(-1, false)
	var display_name: String # Name shown in display
	# Display weapons
	#for weapon in GameManager.stored_weapons:
		#if is_instance_valid(weapon):
			#if weapon.sell_price: # Only display weapons with a sell price
				#if weapon.is_equipped:
					#display_name = "%s (E) - Sell: %dG" % [weapon.name, weapon.sell_price]
				#else:
					#display_name = "%s - Sell: %dG" % [weapon.name, weapon.sell_price]
				#sell_display.add_item(display_name, weapon.icon, true)
				#weapon.display_index = sell_display.get_item_count() - 1 # Attach the display index to the item
				#sell_display.set_item_tooltip(-1, weapon.tooltip) # Add tooltip
				#sell_display.set_item_metadata(-1, weapon) # Add ref to the item list metadata
				#sell_display.set_item_custom_fg_color(-1, GameManager.get_quality_colour(weapon.quality))
			#else:
				#weapon.display_index = -1 # Disable display indexes for weapons with no value
	# Display magic
	for magic in GameManager.stored_magic:
		if is_instance_valid(magic):
			if magic.sell_price: # Only display spells with a sell price
				display_name = "%s - Sell: %dG" % [magic.name, magic.sell_price]
				sell_display.add_item(display_name, magic.icon, true)
				magic.display_index = sell_display.get_item_count() - 1 # Attach the display index to the item
				sell_display.set_item_tooltip(-1, magic.tooltip) # Add tooltip
				sell_display.set_item_metadata(-1, magic) # Add ref to the item list metadata
				sell_display.set_item_custom_fg_color(-1, GameManager.get_quality_colour(magic.quality))
			else:
				magic.display_index = -1 # Disable display indexes for spells with no value
	# Display armour
	for armour in GameManager.stored_armour:
		if is_instance_valid(armour):
			if armour.sell_price: # Only display armour with a sell price
				if armour.is_equipped:
					display_name = "%s (E) - Sell: %dG" % [armour.name, armour.sell_price]
				else:
					display_name = "%s - Sell: %dG" % [armour.name, armour.sell_price]
				sell_display.add_item(display_name, armour.icon, true)
				armour.display_index = sell_display.get_item_count() - 1 # Attach the display index to the item
				sell_display.set_item_tooltip(-1, armour.tooltip) # Add tooltip
				sell_display.set_item_metadata(-1, armour) # Add ref to the item list metadata
				sell_display.set_item_custom_fg_color(-1, GameManager.get_quality_colour(armour.quality)) 
			else:
				armour.display_index = -1 # Disable display indexes for armour with no value
	# Display items
	for item in GameManager.stored_items:
		if is_instance_valid(item):
			if item.sell_price: # Only display items with a sell price
				display_name = "%s - Sell: %dG" % [item.name, item.sell_price]
				sell_display.add_item(display_name, item.icon, true)
				item.display_index = sell_display.get_item_count() - 1 # Attach the display index to the item
				sell_display.set_item_tooltip(-1, item.tooltip) # Add tooltip
				sell_display.set_item_metadata(-1, item) # Add ref to the item list metadata
				sell_display.set_item_custom_fg_color(-1, GameManager.get_quality_colour(item.quality)) 
			else:
				item.display_index = -1 # Disable display indexes for items with no value

func display_buyable() -> void:
	# Creates a basic title
	buy_display.add_item("--------------- BUY ---------------", null, false)
	buy_display.set_item_tooltip_enabled(-1, false)
	var display_name: String # Name shown in display
	for buyable in stock:
		display_name = "%s - Buy: %dG" % [buyable.name, buyable.buy_price]
		if GameManager.coins >= buyable.buy_price:
			buy_display.add_item(display_name, buyable.icon, true)
		else:
			buy_display.add_item(display_name, buyable.icon, true)
			buy_display.set_item_disabled(-1, true)
			too_expensive.append(buy_display.item_count - 1)
		buyable.display_index = buy_display.get_item_count() - 1 # Attach the display index to the item
		buy_display.set_item_tooltip(-1, buyable.tooltip) # Add tooltip
		buy_display.set_item_metadata(-1, buyable) # Add ID to the item list metadata
		buy_display.set_item_custom_fg_color(-1, GameManager.get_quality_colour(buyable.quality)) 

func display_misc() -> void:
	# Display misc options in misc_display
	misc_display.add_item("Equipment", GameManager.icons["equipment"], true)
	misc_display.set_item_tooltip_enabled(-1, false)
	misc_display.add_item("Options", GameManager.icons["options"], true)
	misc_display.set_item_tooltip_enabled(-1, false)
	misc_display.add_item("Help", GameManager.icons["help"], true)
	misc_display.set_item_tooltip_enabled(-1, false)
	misc_display.add_item("Exit to Main Menu", GameManager.icons["restart"], true)
	misc_display.set_item_tooltip_enabled(-1, false)
	misc_display.add_item("Quit Game", GameManager.icons["disabled"], true)
	misc_display.set_item_tooltip_enabled(-1, false)

func clear_stock() -> void:
	for object in stock:
		if is_instance_valid(object):
			object.free()
	stock.clear()

func toggle_menu(new_menu):
	# Check if menu is already open, then call the relevant open/close func
	if new_menu == active_menu:
		close_menu()
	else:
		close_menu()
		open_menu(new_menu)

func close_menu() -> void:
	# Closes the current open menu
	if active_menu != "none":
		match active_menu:
			"buy":
				buy_display.deselect_all()
				buy_display.hide()
			"sell":
				sell_display.deselect_all()
				sell_display.hide()
			"misc":
				misc_display.deselect_all()
				misc_display.hide()
			"equipment_menu":
				equipment_menu.hide()
			_:
				printerr("ERROR: Menu not found in 'close_menu()'")
		active_menu = "none"
		hide_tooltip()

func open_menu(new_menu) -> void:
	# Opens the selected menu
	match new_menu:
		"buy":
			buy_display.show()
		"sell":
			sell_display.show()
		"misc":
			misc_display.show()
		"equipment_menu":
			equipment_menu.show()
		_:
			printerr("ERROR: Menu not found in 'open_menu()'")
	active_menu = new_menu

func leave_shop() -> void:
	close_menu() # Close all menus
	clear_stock() # Clear the stock instances
	leaving_shop.emit() # Inform the main script that the player wants to leave
	
func _on_buy_display_item_selected(index: int) -> void:
	buy_display.set_item_disabled(index, true) # Disables purchased item on UI
	buy_display.deselect(index) # Deselects the bought item
	load_sfx(sfx_buy_sell)
	ui_audio.play()
	var purchase = buy_display.get_item_metadata(index) # Gets the purchased item
	buy_display.set_item_text(index, "%s - Sold out" % [purchase.name]) # Changes text on purchased item
	GameManager.set_coins(-purchase.buy_price) # Takes purchase cost from coin total
	buy_display.set_item_metadata(index, null) # Removes ref in buy display
	stock[purchase.storage_index] = null # Removes ref in stock list
	for x in buy_display.item_count: # Check for stock that is now unaffordable
		if is_instance_valid(buy_display.get_item_metadata(x)):
			if buy_display.get_item_metadata(x).buy_price > GameManager.coins:
				buy_display.set_item_disabled(x, true) # Disable if too expensive
				too_expensive.append(x)
	# Store purchase
	var storage: Callable = Callable(GameManager, "store_" + purchase.obj_name)
	storage.call(purchase)
	# Refresh equipment menu
	equipment_menu.display_equipment() 
	# Add purchase to sell display
	if purchase.sell_price:
		var display_name: String = "%s - Sell: %dG" % [purchase.name, purchase.sell_price]
		sell_display.add_item(display_name, purchase.icon, true)
		purchase.display_index = sell_display.get_item_count() - 1 # Attach the display index to the item
		sell_display.set_item_tooltip(-1, purchase.tooltip) # Add tooltip
		sell_display.set_item_metadata(-1, purchase) # Add ref to the item list metadata
		sell_display.set_item_custom_fg_color(-1, GameManager.get_quality_colour(purchase.quality))
	bought_item.emit()

func _on_sell_display_item_selected(index: int) -> void:
	sell_display.set_item_disabled(index, true) # Disables sold item in UI
	sell_display.deselect(index) # Deselects the sold item
	load_sfx(sfx_buy_sell)
	ui_audio.play()
	var sold = sell_display.get_item_metadata(index) # Gets the sold item
	# Changes text on sold item
	sell_display.set_item_text(index, "%s - Sold (%dG)" % [sold.name, sold.sell_price])
	GameManager.set_coins(sold.sell_price) # Adds sell value to coin total
	if sold.is_equipped: # Unequip sold item if currently equipped
		match sold.obj_name:
			"weapon":
				GameManager.unequip_weapon()
			"relic":
				GameManager.unequip_relic()
			"armour":
				GameManager.unequip_armour(sold.slot)
			_:
				printerr("ERROR: Could not find obj_type of sold item")
		equipment_menu.update_stat_labels()
	sold.free() # Delete the sold item
	for x in too_expensive.size(): # Check to see if any stock is now affordable
		if is_instance_valid(buy_display.get_item_metadata(too_expensive[x])):
			if buy_display.get_item_metadata(too_expensive[x]).buy_price <= GameManager.coins:
				buy_display.set_item_disabled(too_expensive[x], false) # Enable if now affordable
				too_expensive[x] = -1
	# Remove any now-affordable buyables from the too_expensive list
	for x in range(too_expensive.size() - 1, -1, -1):
		if too_expensive[x] == -1:
			too_expensive.remove_at(x)
	equipment_menu.display_equipment()
	sold_item.emit()

func _on_misc_display_item_selected(index: int) -> void:
	load_sfx(sfx_confirm)
	ui_audio.play()
	match misc_display.get_item_text(index):
		"Equipment":
			toggle_menu("equipment_menu")
		"Options":
			close_menu()
			UI.toggle_options_menu()
		"Help":
			close_menu()
			UI.toggle_help_menu()
		"Exit to Main Menu":
			reset()
		"Quit Game":
			get_tree().quit()
	misc_display.deselect_all()

func reset() -> void:
	close_menu()
	clear_stock()
	restart_pressed.emit()

func _on_buy_display_gui_input(event: InputEvent) -> void:
	var index: int = buy_display.get_item_at_position(event.position, true)
	if index == -1: hide_tooltip()
	else:
		var buyable = buy_display.get_item_metadata(index)
		UI.tooltip.size.y = 20
		UI.tooltip.text = buy_display.get_item_tooltip(index)
		if !UI.tooltip.text or not is_instance_valid(buyable):
			hide_tooltip()
			return
		UI.set_tooltip_position(event.position, buy_display.position)
		UI.tooltip.show()
		if buyable.obj_name == "armour":
			match buyable.slot:
				"head":
					if is_instance_valid(GameManager.player_head):
						UI.comparison.text = "(EQUIPPED)\n" + GameManager.player_head.tooltip
						UI.comparison.show()
				"chest":
					if is_instance_valid(GameManager.player_chest):
						UI.comparison.text = "(EQUIPPED)\n" + GameManager.player_chest.tooltip
						UI.comparison.show()
				"arms":
					if is_instance_valid(GameManager.player_arms):
						UI.comparison.text = "(EQUIPPED)\n" + GameManager.player_arms.tooltip
						UI.comparison.show()
				"legs":
					if is_instance_valid(GameManager.player_legs):
						UI.comparison.text = "(EQUIPPED)\n" + GameManager.player_legs.tooltip
						UI.comparison.show()
			return
		elif buyable.obj_name == "weapon":
			if is_instance_valid(GameManager.player_weapon):
				UI.comparison.text = "(EQUIPPED)\n" + GameManager.player_weapon.tooltip
				UI.comparison.show()
			return
		elif buyable.obj_name == "relic":
			if is_instance_valid(GameManager.player_relic):
				UI.comparison.text = "(EQUIPPED)\n" + GameManager.player_relic.tooltip
				UI.comparison.show()
			return
		UI.hide_comparison()

func _on_sell_display_gui_input(event: InputEvent) -> void:
	var index: int = sell_display.get_item_at_position(event.position, true)
	if index == -1: hide_tooltip()
	else:
		var sellable = sell_display.get_item_metadata(index)
		UI.tooltip.size.y = 20
		UI.tooltip.text = sell_display.get_item_tooltip(index)
		if !UI.tooltip.text or not is_instance_valid(sellable):
			hide_tooltip()
			return
		UI.set_tooltip_position(event.position, sell_display.position)
		UI.tooltip.show()
		if sellable.obj_name == "armour":
			if not sellable.is_equipped:
				match sellable.slot:
					"head":
						if is_instance_valid(GameManager.player_head):
							UI.comparison.text = "(EQUIPPED)\n" + GameManager.player_head.tooltip
							UI.comparison.show()
					"chest":
						if is_instance_valid(GameManager.player_chest):
							UI.comparison.text = "(EQUIPPED)\n" + GameManager.player_chest.tooltip
							UI.comparison.show()
					"arms":
						if is_instance_valid(GameManager.player_arms):
							UI.comparison.text = "(EQUIPPED)\n" + GameManager.player_arms.tooltip
							UI.comparison.show()
					"legs":
						if is_instance_valid(GameManager.player_legs):
							UI.comparison.text = "(EQUIPPED)\n" + GameManager.player_legs.tooltip
							UI.comparison.show()
				return
			elif sellable.obj_name == "weapon":
				if is_instance_valid(GameManager.player_weapon):
					UI.comparison.text = "(EQUIPPED)\n" + GameManager.player_weapon.tooltip
					UI.comparison.show()
				return
			elif sellable.obj_name == "relic":
				if is_instance_valid(GameManager.player_relic):
					UI.comparison.text = "(EQUIPPED)\n" + GameManager.player_relic.tooltip
					UI.comparison.show()
				return
		UI.hide_comparison()

func hide_tooltip() -> void:
	UI.hide_tooltip()
	UI.hide_comparison()

func _on_equipment_menu_stats_changed() -> void:
	stats_changed.emit()
