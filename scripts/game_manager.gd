extends Node

var score = 0

signal point_signal(score)


func add_point():
	score += 1
	point_signal.emit(get_score())
	
func get_score() -> int:
	return score
	
func reset():
	score = 0
	get_tree().reload_current_scene() # Replace with function body.
