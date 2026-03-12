extends Node2D

@export var spawnables : Array[PackedScene]
@export var slots_num : int = 16

var offset_scalar : float = 0.1

var circle_radius: float = 320.0
@onready var ttimer : Timer = $SpawnTimer
@onready var pivot = $Pivot

var rotations : float = 0.0
var rot_speed : float = 1.0

var obstacles : Array = []
var slots : Dictionary = {}
var slot_types : Dictionary = {}  # slot -> spawnable index

@export var repetition_penalty : float = 0.25
var spawn_streak : Dictionary = {}  # spawnable index -> consecutive spawn count

func _pick_spawnable_index() -> int:
	var weights : Array[float] = []
	for i in range(spawnables.size()):
		var streak = spawn_streak.get(i, 0)
		weights.append(maxf(0.1, 1.0 - streak * repetition_penalty))

	var total : float = 0.0
	for w in weights:
		total += w

	var roll = randf() * total
	var cumulative : float = 0.0
	for i in range(weights.size()):
		cumulative += weights[i]
		if roll <= cumulative:
			return i
	return spawnables.size() - 1

signal score

func on_score(score_to_add : float):
	score.emit(score_to_add)

func _physics_process(delta: float) -> void:
	pivot.rotate(rot_speed * delta)
	
	rotations += rot_speed * delta
	pass

func spawn_obstacle():
	var interval : float = 2 * PI / slots_num

	# Get all slots in the top half of the circle
	var top_half_slots : Array[int] = []
	for i in range(slots_num):
		var global_angle = pivot.rotation + i * interval
		if sin(global_angle) <= 0:
			top_half_slots.append(i)

	# Filter to only unoccupied slots
	var available_slots : Array[int] = []
	for s in top_half_slots:
		if not slots.has(s):
			available_slots.append(s)

	# If no unoccupied slot, skip spawning
	if available_slots.is_empty():
		return

	for _attempt in range(10):
		var chosen_index = _pick_spawnable_index()
		var obstacle = spawnables[chosen_index].instantiate()
		var slot = available_slots.pick_random()
		var angle = slot * interval

		# same type clause
		if slot_types.get(slot + 1) == chosen_index:
			if slot_types.get(slot + 2) == chosen_index:
				continue
		if slot_types.get(slot + 1) == chosen_index:
			if slot_types.get(slot - 1) == chosen_index:
				continue
		if slot_types.get(slot - 1) == chosen_index:
			if slot_types.get(slot - 2) == chosen_index:
				continue

		# Update repetition streaks
		for i in range(spawnables.size()):
			spawn_streak[i] = spawn_streak.get(i, 0) + 1 if i == chosen_index else 0

		pivot.add_child(obstacle)

		angle += randf_range(-1.0, 1.0) * offset_scalar

		var x = circle_radius * cos(angle)
		var y = circle_radius * sin(angle)
		obstacle.position = Vector2(x, y)

		obstacle.rotation = angle + (PI / 2.0)

		obstacle.score.connect(on_score)
		obstacles.append(obstacle)
		slots[slot] = obstacle
		slot_types[slot] = chosen_index
		return


func _on_timer_timeout() -> void:
	spawn_obstacle()


func _on_remove_start_timer_timeout() -> void:
	$RemoveTimer.start()
	pass # Replace with function body.


func _on_remove_timer_timeout() -> void:
	if slots.is_empty():
		return

	var interval : float = 2 * PI / slots_num

	# Get all occupied slots in the top half
	var top_half_occupied : Array = []
	for slot in slots.keys():
		var global_angle = pivot.rotation + slot * interval
		if sin(global_angle) <= 0:
			top_half_occupied.append(slot)

	if top_half_occupied.is_empty():
		return

	var slot = top_half_occupied.pick_random()
	pivot.remove_child(slots[slot])
	slots.erase(slot)
	slot_types.erase(slot)
