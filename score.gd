extends Control

@onready var root = $".."
@onready var score = $Score
@onready var potscore = $PotentialScore
@onready var highscore_label = $Highscore

var potscore_base_pos : Vector2
var potscore_base_size : float
var max_potscore : float = 1000.0

@export var start_color : Color
@export var end_color : Color

func _ready() -> void:
	potscore.label_settings.font_size = 45
	potscore_base_pos = potscore.position
	potscore_base_size = potscore.label_settings.font_size

func _process(delta: float) -> void:
	score.text = str(floor(root.score))
	potscore.text = str(floor(root.potscore))
	if HighscoreManager.highscore > 0:
		highscore_label.text = "HI: " + str(floor(HighscoreManager.highscore))
		highscore_label.visible = true
	else:
		highscore_label.visible = false

	var t = clampf(root.potscore / max_potscore, 0.0, 1.0)

	# Color: white -> red
	potscore.label_settings.font_color = lerp(start_color, end_color, t)

	# Scale: 1x -> 1.5x
	potscore.label_settings.font_size = potscore_base_size * (1.0 + t * 1.5)

	# Shake
	var shake_strength = t * 4.0
	potscore.position = potscore_base_pos + Vector2(
		randf_range(-shake_strength, shake_strength),
		randf_range(-shake_strength, shake_strength)
	)
