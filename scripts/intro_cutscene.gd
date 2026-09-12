extends Node

@onready var intro_animator: AnimationPlayer = $IntroAnimator
@onready var player_container: VBoxContainer = $CanvasLayer/PlayerContainer
@onready var ui_player: AudioStreamPlayer = $UIPlayer
@onready var dialogue: Label = $CanvasLayer/Dialogue
@onready var skip_button: Button = $CanvasLayer/SkipButton
@onready var background: TextureRect = $CanvasLayer/Background

@export var sfx_confirm: AudioStream
@export var sfx_select: AudioStream

const dialogue_pause: int = 5
const dialogue_lines = {
	0: "Our journey begins at the edge of the infamous forest.",
	1: "An uneasy calm settles you into the fog hiding what lies ahead.",
	2: "The phantom described by locals is said to roam here, and may even be the reason behind the recent disappearances.",
	3: "Armed with a simple sword, basic knowledge of low-level wizardry, and your trusty bag of rations...",
	4: "...you venture forth into the impenetrable fog.",
}

var player_resources: HBoxContainer
var player_label: Label
var player_animator: AnimationPlayer

var fade_music_in: bool = false
var fade_music_out: bool = false
var dialogue_positions: Array = [Vector2(60,50),Vector2(700,100),Vector2(60,150),Vector2(700,200),Vector2(60,300)]
var skip_available: bool = false

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
	player_container.position = Vector2(426,300)
	intro_animator.play("scene_reveal")
	await intro_animator.animation_finished
	skip_available = true
	play_dialogue()

func play_dialogue() -> void:
	var position_iterator: int = 0
	for x in range(dialogue_lines.size()):
		dialogue.position = dialogue_positions[position_iterator]
		dialogue.text = dialogue_lines[x]
		intro_animator.queue("dialogue_reveal")
		position_iterator += 1
		if position_iterator == dialogue_positions.size():
			position_iterator = 0
		await intro_animator.animation_finished
		await(get_tree().create_timer(dialogue_pause).timeout)
		intro_animator.queue("dialogue_fade")
		await intro_animator.animation_finished
		await(get_tree().create_timer(1).timeout)
		if dialogue.horizontal_alignment == HORIZONTAL_ALIGNMENT_LEFT:
			dialogue.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		else:
			dialogue.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	end_scene()

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
	GameManager.play_music("main_menu")
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
	skip_available = false
	skip_button.hide()
	player_animator.play("leaving_intro")
	await(get_tree().create_timer(1).timeout)
	# Play fade animation
	if intro_animator.is_playing():
		await intro_animator.animation_finished
	set_music_fade("out")
	intro_animator.play("scene_fade")
	await intro_animator.animation_finished
	await(get_tree().create_timer(1).timeout)
	get_tree().change_scene_to_file(GameManager.scenes["battle"])

func _on_skip_button_pressed() -> void:
	if skip_available:
		load_sfx(sfx_confirm)
		ui_player.play()
		end_scene()
