extends Node

@onready var shopkeeper_container: VBoxContainer = $CanvasLayer/ShopkeeperContainer
@onready var player_container: VBoxContainer = $CanvasLayer/PlayerContainer
@onready var screen_text: Label = $CanvasLayer/ScreenText
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shop_buttons: PanelContainer = $CanvasLayer/ShopButtons
@onready var coin_label: Label = $CanvasLayer/CoinLabel

const shopkeeper_dialogue = {
	0: {"type": "intro", "line": "\"Howdy. Buy somethin' will ya!\""},
	1: {"type": "intro", "line": "\"That better be the jinglin' of coins I hear!\""},
	2: {"type": "intro", "line": "\"New stock in today. Ribbit.\""},
	3: {"type": "outro", "line": "\"More stuff coming soon. Probably.\""},
	4: {"type": "outro", "line": "\"Mhm, mhm. Wassat? Leaving so soon?\""},
	5: {"type": "outro", "line": "\"Bring more gold next time!\""},
	6: {"type": "buy", "line": "\"Cha-ching!\""},
	7: {"type": "buy", "line": "\"You won't regret it.\""},
	8: {"type": "buy", "line": "\"Use that to bring me more gold!\""},
	9: {"type": "sell", "line": "\"I don't part with those coins lightly.\""},
	10: {"type": "sell", "line": "\"Hey! I'm trying to make a living here.\""},
	11: {"type": "sell", "line": "\"Stop selling and start buying!\""},
	12: {"type": "special", "line": "\"Who goes there...?\nA traveller on a quest, you say?\nA paying one I hope!\nCome. Browse my wares.\""},
	13: {"type": "special", "line": "\"I see you met Runikesh the lich.\nYou won't be able to defeat him while his veil remains active.\"\n\n\"Take care of his phylactery first!\""},
	14: {"type": "special", "line": "\"My gut feelin' is tellin' me there's danger ahead, friend.\"\n\n\"You betta' stock up!\""},
	15: {"type": "special", "line": "\"You were victorious over Runikesh?\nRemarkable!\nI hope you'll continue to spend much of yer gold here.\""},
	16: {"type": "special", "line": "\"You seem to be very good at collecting relics there, friend.\nBut allow me to offer you something far greater than those!\""},
}
# Scene vars
var shopkeeper_talking: bool = false
var fade_music_out: bool = false
var fade_music_in: bool = false
var loading: bool = false
var playing_special_dialogue: bool = false
# Node refs
var player_sprite: AnimatedSprite2D
var player_animator: AnimationPlayer
var shopkeeper_sprite: AnimatedSprite2D
var player_health_bar: ProgressBar
var player_magic_bar: ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_node_refs()
	set_resource_bar(player_health_bar, GameManager.player_HP, GameManager.player_max_HP)
	set_resource_bar(player_magic_bar, GameManager.player_MP, GameManager.player_max_MP)
	coin_label.text = ": %d" % [GameManager.coins]
	set_music()
	play_scene_intro()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shopkeeper_talking:
		shopkeeper_talking = false
		animate_shopkeeper()
	if fade_music_in:
		GameManager.music_volume += GameManager.music_fade_rate * delta
		if GameManager.music_volume >= GameManager.music_volume_limit:
			GameManager.music_volume = GameManager.music_volume_limit
			fade_music_in = false
		set_music_volume(GameManager.music_volume)
	elif fade_music_out:
		GameManager.music_volume -= GameManager.music_fade_rate * delta
		if GameManager.music_volume <= 0:
			GameManager.music_volume = 0
			fade_music_out = false
		set_music_volume(GameManager.music_volume)

func play_scene_intro() -> void:
	shop_buttons.hide()
	animation_player.play("scene_reveal")
	player_animator.play("entering_scene")
	await player_animator.animation_finished
	player_sprite.play("idle")
	display_message(get_shopkeeper_dialogue("intro"))
	if playing_special_dialogue:
		await screen_text.text_finished
		await(get_tree().create_timer(GameManager.text_pause + 1).timeout)
		playing_special_dialogue = false
	shop_buttons.show()

func set_music() -> void:
	if GameManager.level == 101:
		GameManager.play_music("main_menu")
	else:
		GameManager.play_music("shop1")
	set_music_fade("in")

func set_music_volume(amount:float) -> void:
	if amount > GameManager.music_volume_limit:
		amount = GameManager.music_volume_limit
	GameManager.music_volume = amount
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(amount))
	#if Music.stream_paused and amount > 0:
		#Music.stream_paused = false
	#elif not Music.stream_paused and amount == 0.0:
		#Music.stream_paused = true

func set_music_fade(fade:String, on:bool = true) -> void:
	if on:
		if fade == "out":
			fade_music_out = true
		elif fade == "in":
			fade_music_in = true
	else:
		if fade == "out":
			fade_music_out = false
		elif fade == "in":
			fade_music_in = false

func set_node_refs() -> void:
	player_sprite = player_container.get_node("Player")
	player_animator = player_container.get_node("AnimationPlayer")
	player_health_bar = player_container.get_node("ResourceContainer/HealthBar")
	player_magic_bar = player_container.get_node("ResourceContainer/MagicBar")
	shopkeeper_sprite = shopkeeper_container.get_node("Shopkeeper")

func set_resource_bar(bar: ProgressBar, new_value: int, max_value: int) -> void:
	# Assign new values to the progress bar
	bar.max_value = max_value
	bar.value = new_value
	# Update the bar's label based on the type of bar
	match bar.name:
		"HealthBar":
			bar.get_node("Label").text = "HP: %d/%d" % [new_value, max_value]
		"MagicBar":
			bar.get_node("Label").text = "MP: %d/%d" % [new_value, max_value]
		_:
			printerr("ERROR: Resource bar not found")

func get_shopkeeper_dialogue(type: String) -> String:
	# Returns a random dialogue string from the type chosen
	var chosen_dialogue: int = -1 # Stores a random number to determine leaving dialogue
	match type:
		"intro":
			if GameManager.relics_collected and not GameManager.rascal_obtained:
				chosen_dialogue = 16
				playing_special_dialogue = true
			else:
				match GameManager.level:
					101:
						chosen_dialogue = 15
						playing_special_dialogue = true
					100:
						chosen_dialogue = 14
						playing_special_dialogue = true
					51:
						chosen_dialogue = 13
						playing_special_dialogue = true
					5:
						chosen_dialogue = 12
						playing_special_dialogue = true
					_:
						chosen_dialogue = randi_range(0,2)
		"outro":
			chosen_dialogue = randi_range(3,5)
		"buy":
			chosen_dialogue = randi_range(6,8)
		"sell":
			chosen_dialogue = randi_range(9,11)
		_:
			printerr("ERROR: shopkeeper dialogue type not found")
	shopkeeper_talking = true # Enable shopkeeper talking animation to begin
	return shopkeeper_dialogue[chosen_dialogue]["line"]

func animate_shopkeeper() -> void:
	shopkeeper_sprite.play("talking")
	await(screen_text.text_finished)
	await(get_tree().create_timer(0.5).timeout)
	shopkeeper_sprite.play("idle")

func display_message(text: String, wait: bool = false, hide: bool = false) -> void:
	if hide:
		shop_buttons.hide()
		# Change battle text
		screen_text.set_screen_text(text)
		if wait:
			# Wait for text to finish animating
			await(screen_text.text_finished)
			await(get_tree().create_timer(GameManager.text_pause).timeout)
		shop_buttons.show()
	else:
		# Change battle text
		screen_text.set_screen_text(text)
		if wait:
			# Wait for text to finish animating
			await(screen_text.text_finished)
			await(get_tree().create_timer(GameManager.text_pause).timeout)

func get_next_scene() -> String:
	if GameManager.level == 100:
		return "chase"
	if GameManager.level == 101:
		return "camp"
	return "battle"

func _on_storage_leaving_shop() -> void:
	# Display outro dialogue
	display_message(get_shopkeeper_dialogue("outro"))
	# Play leaving animation
	player_sprite.play("run")
	player_animator.play("leaving_shop")
	await player_animator.animation_finished
	# Fade scene
	animation_player.play("scene_fade")
	set_music_fade("out")
	await animation_player.animation_finished
	# Pre-transition cleanup
	GameManager.refresh_storage() # Clean up any empty storage entries
	GameManager.refresh_equipped() # Clean up any empty equipment references
	# Change scene to battle
	get_tree().change_scene_to_file(GameManager.scenes[get_next_scene()])

func _on_storage_bought_item() -> void:
	coin_label.text = ": %d" % [GameManager.coins]
	display_message(get_shopkeeper_dialogue("buy"))

func _on_storage_sold_item() -> void:
	coin_label.text = ": %d" % [GameManager.coins]
	display_message(get_shopkeeper_dialogue("sell"))

func _on_storage_stats_changed() -> void:
	# Update player resource bars when stats have been changed
	set_resource_bar(player_health_bar, GameManager.player_HP, GameManager.player_max_HP)
	set_resource_bar(player_magic_bar, GameManager.player_MP, GameManager.player_max_MP)
	
func restart() -> void:
	if not loading:
		loading = true
		animation_player.play("scene_fade")
		set_music_fade("out")
		shop_buttons.hide()
		await animation_player.animation_finished
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file(GameManager.scenes["main_menu"])
