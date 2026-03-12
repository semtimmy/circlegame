extends Node

var highscore : float = 0.0

func check_and_update(final_score: float) -> bool:
	if final_score > highscore:
		highscore = final_score
		return true
	return false
