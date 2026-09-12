extends Node

@onready var menu_animator: AnimationPlayer = $MenuAnimator
@onready var ui_player: AudioStreamPlayer = $UIPlayer
@onready var score: Label = $CanvasLayer/Score
@onready var title_animator: AnimationPlayer = $TitleAnimator
@onready var credits: RichTextLabel = $CanvasLayer/Credits
@onready var buttons: HBoxContainer = $CanvasLayer/Buttons
@onready var title: Label = $CanvasLayer/Title
@onready var skip_button: Button = $CanvasLayer/SkipButton
@onready var continue_button: Button = $CanvasLayer/ContinueButton

@export var sfx_confirm: AudioStream
@export var sfx_hover: AudioStream
@export var sfx_loot: AudioStream
@export var sfx_select: AudioStream
@export var sfx_cancel: AudioStream

const restart_message: String = "Are you sure you wish to restart your journey?\nAny camps reached will overwrite your existing save data."

var fade_music_in: bool = false
var fade_music_out: bool = false
var buttons_active: bool = false
var intro_skip_available: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.checkpoint_available:
		GameManager.load_checkpoint()
		await get_tree().process_frame
	set_music()
	set_score_label()
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
	menu_animator.play("scene_reveal")
	await menu_animator.animation_finished
	intro_skip_available = true
	menu_animator.play("title_reveal")
	await menu_animator.animation_finished
	title_animator.play("title_float")
	menu_animator.play("buttons_reveal")
	await menu_animator.animation_finished
	score.show()
	if GameManager.checkpoint_available:
		continue_button.show()
	intro_skip_available = false
	buttons_active = true
	
func play_select_sfx() -> void:
	if buttons_active:
		load_sfx(sfx_select)
		ui_player.play()

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

func set_score_label() -> void:
	score.text = "Best Stage\n%d" % [GameManager.best_stage]
	if GameManager.best_stage > 199:
		score.text += " Wow!!!"
	elif GameManager.best_stage > 149:
		score.text += "!!"
	elif GameManager.best_stage > 100:
		score.text += "!"

func skip_intro_anims(event: InputEvent) -> void:
	if intro_skip_available:
		if event is InputEventMouseButton:
			if event.button_index == 1:
				menu_animator.seek(menu_animator.current_animation_length - 0.01, true, true)

func hide_menu() -> void:
	buttons.hide()
	continue_button.hide()
	title.hide()
	score.hide()

func show_menu() -> void:
	skip_button.hide()
	buttons.show()
	if GameManager.checkpoint_available:
		continue_button.show()
	title.show()
	score.show()

func _on_start_button_pressed() -> void:
	if buttons_active:
		load_sfx(sfx_confirm)
		ui_player.play()
		if GameManager.checkpoint_available:
			var choice: bool = await UI.display_confirmation(restart_message)
			if choice:
				buttons_active = false
				buttons.hide()
				continue_button.hide()
				menu_animator.play("scene_fade")
				await menu_animator.animation_finished
				await(get_tree().create_timer(0.5).timeout)
				GameManager.reset()
				GameManager.create_defaults()
				await get_tree().process_frame
				get_tree().change_scene_to_file(GameManager.scenes["intro"])
		else:
			buttons_active = false
			buttons.hide()
			continue_button.hide()
			menu_animator.play("scene_fade")
			await menu_animator.animation_finished
			await(get_tree().create_timer(0.5).timeout)
			GameManager.reset()
			GameManager.create_defaults()
			await get_tree().process_frame
			get_tree().change_scene_to_file(GameManager.scenes["intro"])

func _on_options_button_pressed() -> void:
	if buttons_active:
		load_sfx(sfx_confirm)
		ui_player.play()
		UI.toggle_options_menu()

func _on_help_button_pressed() -> void:
	if buttons_active:
		load_sfx(sfx_confirm)
		ui_player.play()
		UI.toggle_help_menu()

func _on_credits_button_pressed() -> void:
	if buttons_active:
		hide_menu()
		load_sfx(sfx_confirm)
		ui_player.play()
		credits.play()
		skip_button.show()

func _on_quit_button_pressed() -> void:
	if buttons_active:
		get_tree().quit()

func _on_skip_button_pressed() -> void:
	credits.reset()

func _on_continue_button_pressed() -> void:
	if buttons_active:
		buttons_active = false
		buttons.hide()
		continue_button.hide()
		load_sfx(sfx_confirm)
		ui_player.play()
		menu_animator.play("scene_fade")
		set_music_fade("out")
		await menu_animator.animation_finished
		await(get_tree().create_timer(1).timeout)
		get_tree().change_scene_to_file(GameManager.scenes["camp"])
