extends Node

@onready var background: TextureRect = $CanvasLayer/Background
@onready var player_container: VBoxContainer = $CanvasLayer/PlayerContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var stage_label: Label = $UILayer/Stage
@onready var coin_label: Label = $UILayer/CoinLabel
@onready var screen_text: Label = $UILayer/ScreenText
@onready var ui_player: AudioStreamPlayer = $UIPlayer
@onready var ambi_player: AudioStreamPlayer = $AmbiencePlayer
# Exports
@export var sfx_sword: AudioStream
@export var sfx_miss: AudioStream
@export var sfx_fireball: AudioStream
@export var sfx_explosion: AudioStream
@export var sfx_block: AudioStream
@export var sfx_buff: AudioStream
@export var sfx_debuff: AudioStream
@export var sfx_fear: AudioStream
@export var sfx_throw: AudioStream
@export var sfx_heal: AudioStream
@export var sfx_swipe: AudioStream
@export var sfx_impact: AudioStream
@export var sfx_screech: AudioStream
@export var sfx_fog: AudioStream
@export var sfx_siphon: AudioStream
@export var sfx_leech: AudioStream
@export var sfx_confirm: AudioStream
@export var sfx_select: AudioStream
@export var sfx_hover: AudioStream
@export var sfx_loot: AudioStream

var fade_music_out: bool = false
var fade_music_in: bool = false
var player_alive: bool = true

var player_sprite: AnimatedSprite2D
var player_label: Label
var player_animator: AnimationPlayer
var player_health_bar: ProgressBar
var player_magic_bar: ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_enemy()
	set_background()
	set_stage_label()
	update_coin_label()
	set_node_refs()
	set_bars()
	set_rewards()
	set_music()
	set_ambience()
	play_scene_intro()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	animation_player.play("scene_reveal")
	player_animator.play("entering_scene")
	await player_animator.animation_finished
	player_sprite.play("idle")

func set_enemy() -> void:
	pass

func set_rewards() -> void:
	pass

func set_background() -> void:
	if GameManager.level < 20:
		background.texture = GameManager.backgrounds["background1"]
	elif GameManager.level < 40:
		background.texture = GameManager.backgrounds["background2"]
	elif GameManager.level < 60:
		background.texture = GameManager.backgrounds["background3"]
	elif GameManager.level < 80:
		background.texture = GameManager.backgrounds["background4"]
	elif GameManager.level < 100:
		background.texture = GameManager.backgrounds["background5"]
	elif GameManager.level == 100:
		background.texture = GameManager.backgrounds["background6"]
	else:
		background.texture = GameManager.backgrounds["background7"]

func set_stage_label() -> void:
	stage_label.text = "Event"

func set_music() -> void:
	if GameManager.level < 20:
		GameManager.play_music("stage1")
	elif GameManager.level < 40:
		GameManager.play_music("stage20")
	elif GameManager.level < 60:
		GameManager.play_music("stage40")
	elif GameManager.level < 80:
		GameManager.play_music("stage60")
	elif GameManager.level < 100:
		GameManager.play_music("stage80")
	elif GameManager.level == 100:
		GameManager.play_music("boss1")
	else:
		GameManager.play_music("stage101")
	if GameManager.music_volume != GameManager.music_volume_limit:
		set_music_fade("in")

func set_music_volume(amount:float) -> void:
	if amount > GameManager.music_volume_limit:
		amount = GameManager.music_volume_limit
	GameManager.music_volume = amount
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(amount))

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

func set_ambience() -> void:
	pass

func set_bars() -> void:
	set_resource_bar(player_health_bar, GameManager.player_HP, GameManager.player_max_HP)
	set_resource_bar(player_magic_bar, GameManager.player_MP, GameManager.player_max_MP)

func set_resource_bar(bar:ProgressBar, new_value:int, max_value:int) -> void:
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

func set_player_HP(health_change:int) -> void:
	if player_alive:
		# Update the GameManager player health value
		GameManager.player_HP = max(0, GameManager.player_HP + health_change)
		# Prevent the HP change from exceeding the limit
		if GameManager.player_HP > GameManager.player_max_HP:
			GameManager.player_HP = GameManager.player_max_HP
		# Display the change on the player health bar
		set_resource_bar(player_health_bar, GameManager.player_HP, GameManager.player_max_HP)
		# Check if player HP is 0
		if GameManager.player_HP <= 0:
			player_alive = false

func set_player_MP(magic_change:int) -> void:
	if player_alive:
		# Update the GameManager player magic value
		GameManager.player_MP = max(0, GameManager.player_MP + magic_change)
		# Prevent the MP change from exceeding the limit
		if GameManager.player_MP > GameManager.player_max_MP:
			GameManager.player_MP = GameManager.player_max_MP
		# Display the change on the player magic bar
		set_resource_bar(player_magic_bar, GameManager.player_MP, GameManager.player_max_MP)

func set_node_refs() -> void:
	player_sprite = player_container.get_node("Player")
	player_label = player_container.get_node("Name")
	player_health_bar = player_container.get_node("ResourceContainer/HealthBar")
	player_magic_bar = player_container.get_node("ResourceContainer/MagicBar")
	player_animator = player_container.get_node("AnimationPlayer")

func update_coin_label() -> void:
	coin_label.text = ": %d" % [GameManager.coins]

func load_sfx(sfx_to_load:AudioStream) -> void:
	if sfx_player.stream != sfx_to_load:
		sfx_player.stop()
		sfx_player.stream = sfx_to_load

func load_ui_sfx(sfx_to_load:AudioStream) -> void:
	if ui_player.stream != sfx_to_load:
		ui_player.stop()
		ui_player.stream = sfx_to_load

func load_ambi_sfx(sfx_to_load:AudioStream) -> void:
	if ambi_player.stream != sfx_to_load:
		ambi_player.stop()
		ambi_player.stream = sfx_to_load

func hide_tooltip() -> void:
	UI.tooltip.hide()
	UI.tooltip.size.y = 20

func display_message(text:String, wait:bool = false, hide:bool = false) -> void:
	if hide:
		#battle_buttons.hide()
		# Change battle text
		screen_text.set_screen_text(text)
		if wait:
			# Wait for text to finish animating
			await(screen_text.text_finished)
			await(get_tree().create_timer(GameManager.text_pause).timeout)
		#battle_buttons.show()
	else:
		# Change battle text
		screen_text.set_screen_text(text)
		if wait:
			# Wait for text to finish animating
			await(screen_text.text_finished)
			await(get_tree().create_timer(GameManager.text_pause).timeout)

func get_next_scene() -> String:
	return "battle"

func end_scene() -> void:
	update_coin_label() # Show the coin changes on the UI
	var next_scene: String = get_next_scene()
	# Wait briefly
	await(get_tree().create_timer(0.2).timeout)
	# Play leaving animation
	player_sprite.play("run")
	player_animator.play("leaving_battle")
	# Play fade animation
	animation_player.play("scene_fade")
	await(get_tree().create_timer(2.5).timeout)
	# Pre-transition storing, updating, and cleaning
	GameManager.refresh_storage() # Clean up any empty storage entries
	# Change scene
	get_tree().change_scene_to_file(GameManager.scenes[next_scene])
