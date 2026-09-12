extends "res://assets/scripts/event.gd"

@onready var grove_warden: AnimatedSprite2D = $CanvasLayer/GroveWarden
@onready var resource_container: HBoxContainer = $UILayer/ResourceContainer
@onready var health_bar: ProgressBar = $UILayer/ResourceContainer/HealthBar
@onready var magic_bar: ProgressBar = $UILayer/ResourceContainer/MagicBar
@onready var choice_container: HBoxContainer = $UILayer/ChoiceContainer
@onready var hp_button: Button = $UILayer/ChoiceContainer/HPContainer/HPButton
@onready var mp_button: Button = $UILayer/ChoiceContainer/MPContainer/MPButton
@onready var warden_label: Label = $CanvasLayer/WardenLabel
@onready var grove_animator: AnimationPlayer = $GroveAnimator
@onready var choice_label: Label = $UILayer/ChoiceLabel

const flapping_frames: Array = [0]

var choices_selectable: bool = false

func play_scene_intro() -> void:
	animation_player.play("scene_reveal")
	player_animator.play("entering_grove")
	await player_animator.animation_finished
	if not GameManager.grove_seen:
		await(get_tree().create_timer(0.5).timeout)
		display_message("The faceless warden of the grove has expected your arrival.")
		await(screen_text.text_finished) # Wait for text to finish animating
		await(get_tree().create_timer(GameManager.text_pause).timeout)
		await(get_tree().create_timer(1).timeout)
		display_message("Though they have no ability to bear words of their own, they still wish to aid you in your journey.")
		await(screen_text.text_finished) # Wait for text to finish animating
		await(get_tree().create_timer(GameManager.text_pause).timeout)
		await(get_tree().create_timer(1).timeout)
		GameManager.grove_seen = true
	else:
		display_message("The warden of the grove wishes to aid you.")
	grove_animator.play("choices_reveal")
	await grove_animator.animation_finished
	resource_container.show()
	warden_label.show()
	choices_selectable = true

func set_background() -> void:
	pass

func set_stage_label() -> void:
	stage_label.text = "Secret Grove"

func set_music() -> void:
	GameManager.play_music("grove")
	if GameManager.music_volume != GameManager.music_volume_limit:
		set_music_fade("in")

func set_bars() -> void:
	set_resource_bar(health_bar, GameManager.player_HP, GameManager.player_max_HP)
	set_resource_bar(magic_bar, GameManager.player_MP, GameManager.player_max_MP)

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
		set_resource_bar(health_bar, GameManager.player_HP, GameManager.player_max_HP)
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
		set_resource_bar(magic_bar, GameManager.player_MP, GameManager.player_max_MP)

func get_next_scene() -> String:
	if GameManager.level != 100:
		return "battle"
	else:
		return "shop"

func end_scene() -> void:
	display_message("After having your wish granted, you leave the grove and its warden to return to its solemn peace.")
	await(screen_text.text_finished) # Wait for text to finish animating
	await(get_tree().create_timer(GameManager.text_pause).timeout)
	await(get_tree().create_timer(1).timeout)
	# Play leaving animation
	player_sprite.play("run")
	player_animator.play("leaving_grove")
	# Play fade animation
	animation_player.play("scene_fade")
	set_music_fade("out")
	await(get_tree().create_timer(3).timeout)
	# Pre-transition storing, updating, and cleaning
	GameManager.refresh_storage() # Clean up any empty storage entries
	# Change scene
	get_tree().change_scene_to_file(GameManager.scenes[get_next_scene()])

func _on_hp_button_pressed() -> void:
	if choices_selectable:
		choice_container.hide()
		choice_label.hide()
		warden_label.hide()
		load_ui_sfx(sfx_confirm)
		ui_player.play()
		if GameManager.player_HP == GameManager.player_max_HP:
			display_message("The warden seems confused by your request, but nevertheless conjures something they think will still aid you.")
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			grove_warden.play("cast")
			await(get_tree().create_timer(1.5).timeout)
			if GameManager.level < 50:
				grove_animator.play("warden_cake")
				player_sprite.play("hold")
				await grove_animator.animation_finished
				player_sprite.play("idle")
				load_ui_sfx(sfx_loot)
				ui_player.play()
				display_message("You received a Cake!")
				GameManager.store_item(GameManager.create_item(7))
			else:
				grove_animator.play("warden_gourmet")
				player_sprite.play("hold")
				await grove_animator.animation_finished
				player_sprite.play("idle")
				load_ui_sfx(sfx_loot)
				ui_player.play()
				display_message("You received a Gourmet Cake!")
				GameManager.store_item(GameManager.create_item(10))
		else:
			display_message("The warden knows of your wounds.\nTheir powers fix that which is broken!")
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			grove_warden.play("cast")
			await(get_tree().create_timer(1.5).timeout)
			grove_animator.play("warden_heart")
			await grove_animator.animation_finished
			grove_warden.play("idle")
			set_player_HP(GameManager.player_max_HP)
			player_animator.play("player_healed")
			await player_animator.animation_finished
			display_message("Your HP has been fully restored!")
		await(screen_text.text_finished) # Wait for text to finish animating
		await(get_tree().create_timer(GameManager.text_pause).timeout)
		await(get_tree().create_timer(1).timeout)
		end_scene()

func _on_hp_button_mouse_entered() -> void:
	if choices_selectable:
		if not hp_button.expand_icon:
			load_ui_sfx(sfx_hover)
			ui_player.play()
		mp_button.expand_icon = false
		hp_button.expand_icon = true

func _on_mp_button_pressed() -> void:
	if choices_selectable:
		choice_container.hide()
		choice_label.hide()
		warden_label.hide()
		load_ui_sfx(sfx_confirm)
		ui_player.play()
		if GameManager.player_MP == GameManager.player_max_MP:
			display_message("The warden seems confused by your request, but nevertheless conjures something they think will still aid you.")
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			grove_warden.play("cast")
			await(get_tree().create_timer(1.5).timeout)
			grove_animator.play("warden_juice")
			player_sprite.play("hold")
			await grove_animator.animation_finished
			player_sprite.play("idle")
			load_ui_sfx(sfx_loot)
			ui_player.play()
			display_message("You received Power Juice!")
			GameManager.store_item(GameManager.create_item(5))
		else:
			display_message("The warden knows of your exhaustion.\nTheir powers renew that which is finite!")
			await(screen_text.text_finished) # Wait for text to finish animating
			await(get_tree().create_timer(GameManager.text_pause).timeout)
			grove_warden.play("cast")
			await(get_tree().create_timer(1.5).timeout)
			grove_animator.play("warden_mana")
			await grove_animator.animation_finished
			grove_warden.play("idle")
			set_player_MP(GameManager.player_max_MP)
			player_animator.play("player_restored")
			await player_animator.animation_finished
			display_message("Your MP has been fully restored!")
		await(screen_text.text_finished) # Wait for text to finish animating
		await(get_tree().create_timer(GameManager.text_pause).timeout)
		await(get_tree().create_timer(1).timeout)
		end_scene()

func _on_mp_button_mouse_entered() -> void:
	if choices_selectable:
		if not mp_button.expand_icon:
			load_ui_sfx(sfx_hover)
			ui_player.play()
		hp_button.expand_icon = false
		mp_button.expand_icon = true

func _on_grove_warden_frame_changed() -> void:
	if grove_warden.animation == "idle":
		load_ambi_sfx(sfx_miss)
		if grove_warden.frame in flapping_frames:
			ambi_player.play()
	elif grove_warden.animation == "cast":
		load_ambi_sfx(sfx_fog)
		if grove_warden.frame == 0:
			ambi_player.play()
