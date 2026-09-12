extends "res://assets/scripts/intro_cutscene.gd"

@onready var credits: RichTextLabel = $CanvasLayer/Credits

func play_scene_intro() -> void:
	player_container.toggle_mute()
	player_resources.hide()
	player_label.hide()
	player_container.position = Vector2(426,300)
	intro_animator.play("scene_reveal")
	await intro_animator.animation_finished
	skip_available = true
	credits.play()

func end_scene() -> void:
	skip_available = false
	skip_button.hide()
	player_animator.play("leaving_intro")
	await(get_tree().create_timer(1).timeout)
	# Play fade animation
	intro_animator.play("scene_fade")
	await intro_animator.animation_finished
	await(get_tree().create_timer(1).timeout)
	get_tree().change_scene_to_file(GameManager.scenes["shop"])
