extends CanvasLayer

@onready var score_counter: Label = $ScoreCounter
@onready var death: Label = $Death
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	GameManager.point_signal.connect(_on_game_manager_point_signal)
	death.hide()
	color_rect.color = Color(255,0,0,0)

	
func _on_game_manager_point_signal(score) -> void:
	score_counter.text = "Coins: %s" % score
	
func _on_player_has_died() -> void:
	death.show()
	color_rect.color = Color(255,0,0,0.33)
