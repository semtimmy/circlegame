extends Node

@export var speed : float = 1

@onready var spawner = $World/Spawner
@onready var player = $World/Player

var score : float = 0
var potscore : float = 0
var distance_score_mult : float = 25
var intensity : float = speed / 1000
var time_intensity : float = 1000

var time_elapsed : float = 0

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
	pass

func end_game():
	process_mode = Node.PROCESS_MODE_DISABLED
	spawner.rot_speed = 0

	var game_over = load("res://game_over.gd").new()
	game_over.setup(score)
	get_tree().root.add_child(game_over)
