extends CanvasLayer

var _final_score : float = 0.0

func setup(s: float) -> void:
	_final_score = s

func _ready() -> void:
	# Semi-transparent dark background
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.65)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# CenterContainer fills the screen and centers its child
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 24)
	center.add_child(vbox)

	var title = Label.new()
	title.text = "GAME OVER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 80)
	title.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(title)

	var score_label = Label.new()
	score_label.text = "Score: " + str(floor(_final_score))
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.add_theme_font_size_override("font_size", 44)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(score_label)

	var hint = Label.new()
	hint.text = "Press [Space] to restart"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 24)
	hint.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	vbox.add_child(hint)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		queue_free()
		get_tree().reload_current_scene()
