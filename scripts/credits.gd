extends RichTextLabel

signal credits_finished

const scroll_speed: float = 50.0

var scroll_start: float
var scroll_end: float
var window_size: Vector2
var playing: bool = false

var v_scroll: VScrollBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	window_size = DisplayServer.window_get_size()
	scroll_start = position.y
	scroll_end = -size.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playing:
		position.y -= scroll_speed * delta
		if position.y <= scroll_end:
			reset()

func play() -> void:
	playing = true
	show()
	
func pause() -> void:
	playing = false
	
func reset() -> void:
	hide()
	playing = false
	position.y = scroll_start
	credits_finished.emit()
