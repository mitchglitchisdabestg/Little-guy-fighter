extends TextureRect

@export var speed = 0.1
var start_x

func _ready():
	start_x = position.x
	process_priority = 100

func _process(_delta):
	var view = get_viewport().get_canvas_transform()
	var left = -view.origin.x / view.x.x
	position.x = start_x + (left - start_x) * (1 - speed)
