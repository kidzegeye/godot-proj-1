extends CharacterBody2D

const SPEED: int = 60

var direction: int = 1

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ray_cast_right.is_colliding() && ray_cast_right.get_collider().name != "Player":
		direction = -1
		animated_sprite.flip_h = true
	elif ray_cast_left.is_colliding() && ray_cast_left.get_collider().name != "Player":
		direction = 1
		animated_sprite.flip_h = false
	position.x += direction * SPEED * delta
	gravity_handler(delta)
	move_and_slide()


func gravity_handler(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
