extends VBoxContainer

@onready var player: AnimatedSprite2D = $Player
@onready var player_audio: AudioStreamPlayer = $PlayerAudio

@export var sfx_step: AudioStream

const footstep_frames: Array = [1,7]

var muted: bool = false

func load_sfx(sfx_to_load:AudioStream) -> void:
	if player_audio.stream != sfx_to_load:
		player_audio.stop()
		player_audio.stream = sfx_to_load

func _on_player_frame_changed() -> void:
	if player.animation == "run" and not muted:
		load_sfx(sfx_step)
		if player.frame in footstep_frames:
			player_audio.play()

func toggle_mute() -> void:
	muted = !muted
