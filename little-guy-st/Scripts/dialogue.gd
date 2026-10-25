extends CanvasLayer

@export var scene_name = "intro"
@export var font: Font

var expressions = {
	"portrait_red": ["neutral", "happy", "angry", "shock", "determined"],
	"portrait_mayor": ["neutral", "worried", "happy"],
	"portrait_pip": ["dazed", "happy"],
	"portrait_smudge": ["grin", "angry"],
	"portrait_grubble": ["angry", "laugh"],
	"portrait_maw": ["roar", "angry"]
}

var characters
var lines
var line = 0
var letters = 0.0
var people = {}
var people_start = {}
var people_end = {}
var name_label
var text_label
var tag
var box
var film
var top_bar
var bottom_bar
var screen
var ui_size = 1.0
var open = 0.0
var closing = false
var tag_on_right = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var file = FileAccess.get_file_as_string("res://Assets/little_guy_pack/dialogue.json")
	var data = JSON.parse_string(file)
	characters = data["characters"]
	lines = data["scenes"][scene_name]
	make_box()
	show_line()
	await get_tree().create_timer(0.1).timeout
	get_tree().paused = true

func _process(delta):
	if closing:
		open -= delta * 4
		if open <= 0:
			get_tree().paused = false
			queue_free()
			return
	else:
		open = min(1.0, open + delta * 3.5)
	var slide = 1 - pow(1 - open, 3)

	film.color.a = 0.45 * slide
	top_bar.position.y = (slide - 1) * 32 * ui_size
	bottom_bar.position.y = screen.y - slide * 32 * ui_size

	for person in people:
		var x = people_start[person] + (people_end[person] - people_start[person]) * slide
		people[person].position = Vector2(x, (76 + (1 - slide) * 60) * ui_size)

	var show_box = slide > 0.6 and not closing
	box.visible = show_box
	tag.visible = show_box
	text_label.visible = show_box
	box.position.y = screen.y - (32 + 88 * slide) * ui_size
	tag.position.y = box.position.y - 18 * ui_size
	if tag_on_right:
		tag.position.x = box.position.x + box.size.x - 16 * ui_size - tag.size.x
	else:
		tag.position.x = box.position.x + 16 * ui_size
	text_label.position.y = box.position.y + 16 * ui_size

	if open >= 1:
		letters += delta * 40
	text_label.visible_characters = int(letters)

func _input(event):
	var click = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if event.is_action_pressed("ui_accept") or click:
		get_viewport().set_input_as_handled()
		if open >= 1 and not closing:
			next_line()

func next_line():
	if letters < lines[line][2].length():
		letters = 1000
		return
	line += 1
	if line >= lines.size():
		closing = true
	else:
		show_line()

func show_line():
	var who = lines[line][0]
	var face = lines[line][1]
	var c = characters[who]
	name_label.text = c["name"]
	name_label.add_theme_color_override("font_color", Color(c["color"]))
	text_label.text = lines[line][2]
	letters = 0
	tag_on_right = c["side"] == "right"
	for person in people:
		if person == who:
			people[person].modulate.a = 1
			people[person].move_to_front()
			set_face(people[person], c["portrait"], face)
		else:
			people[person].modulate.a = 0.5

func set_face(pic, portrait, face):
	var row = expressions[portrait].find(face)
	if row == -1:
		row = 0
	pic.texture.region = Rect2(0, row * 192, 160, 192)

func make_box():
	screen = get_viewport().get_visible_rect().size
	ui_size = screen.y / 360

	film = ColorRect.new()
	film.color = Color(0.18, 0.15, 0.19, 0)
	film.size = screen
	add_child(film)

	var people_holder = Control.new()
	add_child(people_holder)

	var left = 0
	var right = 0
	for l in lines:
		var who = l[0]
		if people.has(who):
			continue
		var c = characters[who]
		var pic = TextureRect.new()
		pic.texture = AtlasTexture.new()
		pic.texture.atlas = load("res://Assets/little_guy_pack/" + c["portrait"] + ".png")
		pic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.size = Vector2(160, 192) * ui_size
		if c["side"] == "left":
			people_start[who] = -200 * ui_size
			people_end[who] = (24 + left * 100) * ui_size
			left += 1
		else:
			people_start[who] = screen.x + 40 * ui_size
			people_end[who] = screen.x - (184 + right * 100) * ui_size
			right += 1
			if c["voice"] == "guy":
				pic.flip_h = true
		pic.position.x = people_start[who]
		set_face(pic, c["portrait"], l[1])
		people_holder.add_child(pic)
		people[who] = pic

	top_bar = ColorRect.new()
	top_bar.color = Color("2d2730")
	top_bar.size = Vector2(screen.x, 32 * ui_size)
	top_bar.position.y = -32 * ui_size
	add_child(top_bar)

	bottom_bar = ColorRect.new()
	bottom_bar.color = Color("2d2730")
	bottom_bar.size = Vector2(screen.x, 32 * ui_size)
	bottom_bar.position.y = screen.y
	add_child(bottom_bar)

	box = Panel.new()
	box.position = Vector2(28 * ui_size, screen.y - 120 * ui_size)
	box.size = Vector2(screen.x - 56 * ui_size, 80 * ui_size)
	var box_style = StyleBoxFlat.new()
	box_style.bg_color = Color("fcfbfc")
	box_style.border_color = Color("514d4a")
	box_style.set_border_width_all(3 * ui_size)
	box_style.set_corner_radius_all(10 * ui_size)
	box.add_theme_stylebox_override("panel", box_style)
	box.visible = false
	add_child(box)

	tag = PanelContainer.new()
	var tag_style = StyleBoxFlat.new()
	tag_style.bg_color = Color("2d2730")
	tag_style.set_corner_radius_all(6 * ui_size)
	tag_style.content_margin_left = 14 * ui_size
	tag_style.content_margin_right = 14 * ui_size
	tag.add_theme_stylebox_override("panel", tag_style)
	tag.visible = false
	add_child(tag)

	name_label = Label.new()
	name_label.add_theme_font_override("font", font)
	name_label.add_theme_font_size_override("font_size", 20 * ui_size)
	tag.add_child(name_label)

	text_label = Label.new()
	text_label.add_theme_font_override("font", font)
	text_label.add_theme_font_size_override("font_size", 18 * ui_size)
	text_label.add_theme_color_override("font_color", Color("514d4a"))
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.position.x = box.position.x + 20 * ui_size
	text_label.size = box.size - Vector2(40, 24) * ui_size
	text_label.visible = false
	add_child(text_label)
