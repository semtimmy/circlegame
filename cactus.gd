class_name Cactus extends Node2D

signal score(score : float)

func _on_static_body_2d_body_entered(body: Node2D) -> void:
	body.get_parent().kill()
	pass # Replace with function body.


func _on_static_body_2d_2_body_entered(body: Node2D) -> void:
	score.emit(30.0)
	pass # Replace with function body.
