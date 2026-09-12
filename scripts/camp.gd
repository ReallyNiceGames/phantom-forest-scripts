# Inherit from 'event.gd'.

extends "res://assets/scripts/event.gd"

@onready var camp_animator: AnimationPlayer = $CampAnimator
@onready var darkness: DirectionalLight2D = $CanvasLayer/Darkness
@onready var upgrades_container: VBoxContainer = $UILayer/UpgradesContainer
@onready var hp_up: Button = $UILayer/UpgradesContainer/Upgrades/HPUp
@onready var atk_up: Button = $UILayer/UpgradesContainer/Upgrades/AtkUp
@onready var spell_up: Button = $UILayer/UpgradesContainer/Upgrades/SpellUp
@onready var upgrades: HBoxContainer = $UILayer/UpgradesContainer/Upgrades
@onready var checkpoint_label: Label = $UILayer/CheckpointLabel

@export var sfx_fire_crackle: AudioStream

func set_stage_label() -> void:
	stage_label.text = "Camp"

func set_ambience() -> void:
	load_ambi_sfx(sfx_fire_crackle)
	ambi_player.play()

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
		background.texture = GameManager.backgrounds["camp_lava"]

func play_scene_intro() -> void:
	if GameManager.checkpoint_loaded:
		GameManager.checkpoint_loaded = false
		checkpoint_label.hide()
		player_label.hide()
		player_health_bar.hide()
		player_magic_bar.hide()
		player_container.position = Vector2(300,350)
		player_sprite.play("camping")
		animation_player.play("scene_reveal")
		await(get_tree().create_timer(3.0).timeout)
		end_scene()
	else:
		animation_player.play("scene_reveal")
		player_animator.play("entering_camp")
		await(get_tree().create_timer(1.7).timeout)
		checkpoint_label.show()
		player_sprite.play("idle")
		await(get_tree().create_timer(1).timeout)
		player_sprite.play("camping")
		await(get_tree().create_timer(1).timeout)
		camp_animator.play("checkpoint_fade")
		await(get_tree().create_timer(1.5).timeout)
		camp_animator.play("upgrades_reveal")
		await(get_tree().create_timer(5.0).timeout)

func play_hover_sfx() -> void:
	load_ui_sfx(sfx_hover)
	ui_player.play()

func save() -> void:
	GameManager.save_checkpoint()
	GameManager.save_game()
	checkpoint_label.text = "Game saved!"
	checkpoint_label.modulate = Color(1,1,1,1)
	checkpoint_label.show()
	await get_tree().create_timer(2).timeout
	camp_animator.play("checkpoint_fade")
	end_scene()

func end_scene() -> void:
	var next_scene: String = get_next_scene()
	# Wait briefly
	await(get_tree().create_timer(0.2).timeout)
	# Play leaving animation
	for x in range(6):
		darkness.energy -= 0.5
		await(get_tree().create_timer(0.25).timeout)
	player_sprite.play("jump")
	#await(get_tree().create_timer(0.1).timeout)
	player_animator.play("leaving_camp")
	await(get_tree().create_timer(0.8).timeout)
	player_sprite.play("run")
	# Play fade animation
	animation_player.play("scene_fade")
	await(get_tree().create_timer(2.5).timeout)
	# Pre-transition storing, updating, and cleaning
	GameManager.refresh_storage() # Clean up any empty storage entries
	# Change scene
	get_tree().change_scene_to_file(GameManager.scenes[next_scene])

func _on_hp_up_pressed() -> void:
	upgrades_container.hide()
	load_sfx(sfx_loot)
	sfx_player.play()
	GameManager.player_max_HP += 25
	GameManager.player_HP = GameManager.player_max_HP
	save()

func _on_atk_up_pressed() -> void:
	upgrades_container.hide()
	load_sfx(sfx_loot)
	sfx_player.play()
	GameManager.player_attack_power += 5
	save()

func _on_spell_up_pressed() -> void:
	upgrades_container.hide()
	load_sfx(sfx_loot)
	sfx_player.play()
	GameManager.player_spellpower += 5
	save()

func _on_hp_up_gui_input(event: InputEvent) -> void:
	UI.tooltip.size.y = 20
	UI.tooltip.text = hp_up.tooltip_text + "\n\nYour HP: [color=green]%d[/color]/[color=green]%d[/color]" % [GameManager.player_HP, GameManager.player_max_HP]
	if !UI.tooltip.text:
		hide_tooltip()
		return
	UI.set_tooltip_position(event.position, upgrades_container.position + upgrades.position + hp_up.position)
	UI.tooltip.show()

func _on_atk_up_gui_input(event: InputEvent) -> void:
	UI.tooltip.size.y = 20
	UI.tooltip.text = atk_up.tooltip_text + "\n\nYour Attack: [color=green]%d[/color]" % [GameManager.player_attack_power]
	if !UI.tooltip.text:
		hide_tooltip()
		return
	UI.set_tooltip_position(event.position, upgrades_container.position + upgrades.position + atk_up.position)
	UI.tooltip.show()

func _on_spell_up_gui_input(event: InputEvent) -> void:
	UI.tooltip.size.y = 20
	UI.tooltip.text = spell_up.tooltip_text + "\n\nYour Spell: [color=green]%d[/color]" % [GameManager.player_spellpower]
	if !UI.tooltip.text:
		hide_tooltip()
		return
	UI.set_tooltip_position(event.position, upgrades_container.position + upgrades.position + spell_up.position)
	UI.tooltip.show()
