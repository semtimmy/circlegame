extends Node2D

var gravity = 1800
var jump_vel = 800
var slam_vel = 1000
var velocity = 0
var is_on_floor = true

var col_size = 60.0
var col_size_up = 20.0

@onready var floorY = get_parent().get_node("Floor").position.y
@onready var sprite = $StaticBody2D/Sprite2D

@onready var sprite_scale = sprite.scale.y

signal on_floor
signal killed

var _touch_held := false
var _touch_just_pressed := false

func _consume_touch() -> bool:
	return _touch_held

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_held = true
			_touch_just_pressed = true
		else:
			_touch_held = false

func kill():
	get_parent().remove_child(self)
	killed.emit()

func _process(delta: float) -> void:
	# Apply gravity if we are above the floor
	if position.y < floorY:
		velocity += gravity * delta
		is_on_floor = false
	
	# Only "land" if we are at/below floorY AND moving downwards (velocity > 0)
	elif velocity >= 0: 
		position.y = floorY
		velocity = 0
		is_on_floor = true
		on_floor.emit()

	# Jump logic
	var tap = Input.is_action_pressed("ui_accept") or _consume_touch()
	var tap_just = Input.is_action_just_pressed("ui_accept") or _touch_just_pressed

	if tap and is_on_floor:
		velocity = -jump_vel
		is_on_floor = false

	# Slam logic
	if tap_just and not is_on_floor:
		velocity = slam_vel

	if Input.is_action_just_pressed("ui_down") and not is_on_floor:
		velocity = slam_vel

	_touch_just_pressed = false

	# Apply the velocity to the position
	position.y += velocity * delta
	
	sprite.scale.y = sprite_scale * (1 + velocity / 1500)
	
	# collision size is smaller when moving up
	var col = col_size
	if velocity < 0:
		col = col_size_up
	
	$StaticBody2D/CollisionShape2D.shape.size.x = col
