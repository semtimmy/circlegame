extends Node

@export var speed : float = 1

@onready var spawner = $World/Spawner
@onready var player = $World/Player
@onready var bg_material : ShaderMaterial = $ColorRect.material

var score : float = 0
var potscore : float = 0

# Color palette for cycling primary/secondary
var color_palette : Array[Color] = [
	Color(0.1, 0.0, 0.3),   # deep purple
	Color(0.0, 0.2, 0.5),   # dark blue
	Color(0.0, 0.4, 0.3),   # teal
	Color(0.4, 0.0, 0.2),   # crimson
	Color(0.3, 0.1, 0.0),   # burnt orange
	Color(0.1, 0.0, 0.5),   # indigo
]
var distance_score_mult : float = 25
var intensity : float = speed / 1000
var time_intensity : float = 1000

var time_elapsed : float = 0
var swirl_offset : float = 0.0
var shader_enabled : bool = true

func _ready() -> void:
	spawner.score.connect(add_score)
	player.on_floor.connect(cash_score)
	player.killed.connect(end_game)

func add_score(_score : float):
	potscore += _score

func cash_score():
	score += potscore
	spawner.rotations = 0
	potscore = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	potscore += spawner.rotations * distance_score_mult * delta
	#print(spawner.rotations * distance_score_mult * delta)
	spawner.rot_speed = 1.0 + potscore * intensity + (time_elapsed / 100)
	print(spawner.rot_speed)
	
	time_elapsed += delta

	# --- Background shader control ---
	if not shader_enabled:
		return
	# Accumulate swirl offset so speed changes are smooth
	var base_swirl_speed := 0.5
	var max_swirl_speed := 25.0
	var speed_t := clampf(potscore / 4000.0, 0.0, 1.0)
	var current_swirl_speed := lerpf(base_swirl_speed, max_swirl_speed, speed_t)
	swirl_offset += current_swirl_speed * delta
	bg_material.set_shader_parameter("swirl_offset", swirl_offset)

	# Cycle primary/secondary colors based on swirl offset
	var cycle_speed := 0.1
	var color_pos := fmod(swirl_offset * cycle_speed, float(color_palette.size()))
	var idx_a := int(floor(color_pos)) % color_palette.size()
	var idx_b := (idx_a + 1) % color_palette.size()
	var blend : float = color_pos - floor(color_pos)
	bg_material.set_shader_parameter("color_primary", color_palette[idx_a].lerp(color_palette[idx_b], blend))

	var idx_c := (idx_a + 2) % color_palette.size()
	var idx_d := (idx_c + 1) % color_palette.size()
	bg_material.set_shader_parameter("color_secondary", color_palette[idx_c].lerp(color_palette[idx_d], blend))

	# Accent vibrancy increases with potscore
	var accent_base := Color(0.3, 0.3, 0.3, 1.0)
	var accent_vibrant := Color(1.0, 1.0, 1.0, 1.0)
	var vibrance_t := clampf((exp(potscore / 2500.0) - 1.0) / (exp(1.0) - 1.0), 0.0, 1.0)
	bg_material.set_shader_parameter("color_accent", accent_base.lerp(accent_vibrant, vibrance_t))

func _on_fx_toggle(toggled_on: bool) -> void:
	shader_enabled = toggled_on
	$ColorRect.visible = toggled_on

func end_game():
	process_mode = Node.PROCESS_MODE_DISABLED
	spawner.rot_speed = 0

	var game_over = load("res://game_over.gd").new()
	game_over.setup(score)
	get_tree().root.add_child(game_over)
