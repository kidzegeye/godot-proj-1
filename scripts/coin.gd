extends Area2D

@onready var pickup: AnimationPlayer = $Pickup

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Coin get")
		GameManager.add_point()
		pickup.play("Pickup")
