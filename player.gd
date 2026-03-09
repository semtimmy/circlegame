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
	if Input.is_action_pressed("ui_accept") and is_on_floor:
		velocity = -jump_vel
		is_on_floor = false
	
	# Slam logic
	if Input.is_action_just_pressed("ui_down"):
		velocity = slam_vel

	# Apply the velocity to the position
	position.y += velocity * delta
	
	sprite.scale.y = sprite_scale * (1 + velocity / 1500)
	
	# collision size is smaller when moving up
	var col = col_size
	if velocity < 0:
		col = col_size_up
	
	$StaticBody2D/CollisionShape2D.shape.size.x = col
