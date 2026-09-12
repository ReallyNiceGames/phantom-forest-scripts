extends Node

@onready var cutscene_animator: AnimationPlayer = $CutsceneAnimator
@onready var ui_player: AudioStreamPlayer = $UIPlayer
@onready var player_container: VBoxContainer = $CanvasLayer/PlayerContainer
@onready var phantom: AnimatedSprite2D = $CanvasLayer/Phantom

@export var sfx_confirm: AudioStream
@export var sfx_select: AudioStream

var fade_music_in: bool = false
var fade_music_out: bool = false
var skip_available: bool = false

var player_resources: HBoxContainer
var player_label: Label
var player_animator: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_music()
	set_node_refs()
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
	player_container.toggle_mute()
	player_resources.hide()
	player_label.hide()
	player_container.position = Vector2(-400,300)
	await(get_tree().create_timer(1).timeout)
	cutscene_animator.play("scene_reveal")
	await cutscene_animator.animation_finished
	await(get_tree().create_timer(1).timeout)
	player_animator.play("entering_chase")
	await player_animator.animation_finished
	await(get_tree().create_timer(0.5).timeout)
	cutscene_animator.play("runikesh_leaving_chase")
	await(get_tree().create_timer(3).timeout)
	end_scene()
	#skip_available = true

func play_hover_sfx() -> void:
	load_sfx(sfx_select)
	ui_player.play()

func set_node_refs() -> void:
	player_resources = player_container.get_node("ResourceContainer")
	player_label = player_container.get_node("Name")
	player_animator = player_container.get_node("AnimationPlayer")

func load_sfx(sfx_to_load:AudioStream) -> void:
	if ui_player.stream != sfx_to_load:
		ui_player.stop()
		ui_player.stream = sfx_to_load

func set_music() -> void:
	GameManager.play_music("boss1")
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

func end_scene() -> void:
	#skip_available = false
	player_animator.play("leaving_chase")
	await(get_tree().create_timer(2).timeout)
	# Play fade animation
	cutscene_animator.play("scene_fade")
	await cutscene_animator.animation_finished
	await(get_tree().create_timer(0.5).timeout)
	get_tree().change_scene_to_file(GameManager.scenes["battle"])

func _on_skip_button_pressed() -> void:
	if skip_available:
		skip_available = false
		load_sfx(sfx_confirm)
		ui_player.play()
		end_scene()
