extends Node2D

var spring_vel = -800

signal score(score : float)

func _on_static_body_2d_body_entered(body: Node2D) -> void:
	body.get_parent().is_on_floor = false
	body.get_parent().velocity = spring_vel
	score.emit(50.0)
	pass # Replace with function body.
