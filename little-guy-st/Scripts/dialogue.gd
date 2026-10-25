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
var name_label
var text_label
var ui_size = 1.0

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
	letters += delta * 40
	text_label.visible_characters = int(letters)

func _input(event):
	var click = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if event.is_action_pressed("ui_accept") or click:
		get_viewport().set_input_as_handled()
		next_line()

func next_line():
	if line >= lines.size():
		return
	if letters < lines[line][2].length():
		letters = 1000
		return
	line += 1
	if line >= lines.size():
		visible = false
		await get_tree().create_timer(0.15).timeout
		get_tree().paused = false
		queue_free()
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
	for person in people:
		if person == who:
			people[person].modulate.a = 1
			people[person].move_to_front()
			set_face(people[person], c["portrait"], face)
		else:
			people[person].modulate.a = 0.45

func set_face(pic, portrait, face):
	var row = expressions[portrait].find(face)
	if row == -1:
		row = 0
	pic.texture.region = Rect2(0, row * 192, 160, 192)

func make_box():
	var screen = get_viewport().get_visible_rect().size
	ui_size = screen.y / 360

	var film = ColorRect.new()
	film.color = Color(0.18, 0.15, 0.19, 0.45)
	film.size = screen
	add_child(film)

	var people_holder = Control.new()
	add_child(people_holder)

	var box = Panel.new()
	box.position = Vector2(12 * ui_size, screen.y - 66 * ui_size)
	box.size = Vector2(300 * ui_size, 54 * ui_size)
	var box_style = StyleBoxFlat.new()
	box_style.bg_color = Color("fcfbfc")
	box_style.border_color = Color("514d4a")
	box_style.set_border_width_all(2 * ui_size)
	box_style.set_corner_radius_all(7 * ui_size)
	box.add_theme_stylebox_override("panel", box_style)
	add_child(box)

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
		pic.size = Vector2(88, 106) * ui_size
		var y = box.position.y + 12 * ui_size - 106 * ui_size
		if c["side"] == "left":
			pic.position = Vector2((14 + left * 55) * ui_size, y)
			left += 1
		else:
			pic.position = Vector2(box.position.x + box.size.x - (90 + right * 55) * ui_size, y)
			right += 1
			if c["voice"] == "guy":
				pic.flip_h = true
		set_face(pic, c["portrait"], l[1])
		people_holder.add_child(pic)
		people[who] = pic

	var tag = PanelContainer.new()
	var tag_style = StyleBoxFlat.new()
	tag_style.bg_color = Color("2d2730")
	tag_style.set_corner_radius_all(4 * ui_size)
	tag_style.content_margin_left = 9 * ui_size
	tag_style.content_margin_right = 9 * ui_size
	tag.add_theme_stylebox_override("panel", tag_style)
	tag.position = box.position + Vector2(10, -12) * ui_size
	add_child(tag)

	name_label = Label.new()
	name_label.add_theme_font_override("font", font)
	name_label.add_theme_font_size_override("font_size", 14 * ui_size)
	tag.add_child(name_label)

	text_label = Label.new()
	text_label.add_theme_font_override("font", font)
	text_label.add_theme_font_size_override("font_size", 12 * ui_size)
	text_label.add_theme_color_override("font_color", Color("514d4a"))
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.position = box.position + Vector2(12, 10) * ui_size
	text_label.size = box.size - Vector2(24, 14) * ui_size
	add_child(text_label)
