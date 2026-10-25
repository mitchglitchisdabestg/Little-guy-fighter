extends TextureRect

@export var speed = 0.1
var start_x

func _ready():
	start_x = position.x

func _process(_delta):
	var cam = get_viewport().get_camera_2d()
	if cam == null:
		return
	var view_width = get_viewport_rect().size.x / cam.zoom.x
	var left = cam.get_screen_center_position().x - view_width / 2
	position.x = start_x + (left - start_x) * (1 - speed)
