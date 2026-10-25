extends Sprite2D

@export var fps = 10.0
@export var frame_count = 8
var time = 0.0

func _process(delta):
	time += delta
	frame = int(time * fps) % frame_count
