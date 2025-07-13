extends CharacterBody2D

@export var attr: PlayerAttributes

var dead: bool = false
var diving: bool = false
var charging_dive: bool = false

var jumps_used: int = 0
var dives_used: int = 0
var jump_cooldown: float = 0.0
var dive_cooldown: float = 0.0
var direction: float = 0
var charge_dive_percent: float = 0.0

signal hasDied()

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimatedSprite2D/AnimationPlayer
@onready var reticle: Polygon2D = $Reticle
var default_reticle

func _ready():
	diving = false
	dead = false
	charging_dive = false
	default_reticle = reticle.polygon.duplicate()
	reticle.hide()
	
	
func _physics_process(delta: float) -> void:
	#print("diving: %s, dives_used: %d, dive_cooldown: %d, rotation: %f, is_on_floor: %s" % [diving, dives_used, dive_cooldown, animated_sprite.rotation, is_on_floor()])
	gravity_handler(delta)
	direction = 0
	if not dead:
		dive_handler(delta)
		jump_handler(delta)
		direction = direction_handler()
		movement_animation_handler()
		
	velocity_handler()
	move_and_slide()

func gravity_handler(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

func dive_handler(delta):
	if attr.RETICLE_MAX_DISTANCE*charge_dive_percent < attr.RETICLE_MIN_DISTANCE:
		reticle.hide()
	else:
		reticle.show()
	# Handle diving
	if diving:
		# Face the dived
		animated_sprite.look_at(velocity)
		motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED

	if dive_cooldown > 0.0:
		dive_cooldown -= delta * 1000 # convert to ms
		
	if is_on_floor() && dives_used > 0: # we know we've dived 
		animated_sprite.rotation = 0.0
		animated_sprite.play("dive_end")
		dives_used = 0
		diving = false
		
	if Input.is_action_just_pressed("dive") && dives_used < attr.MAX_DIVES && dive_cooldown <= 0.0:
		charging_dive = true
		
	if charging_dive:
		if charge_dive_percent < 1.0:
			charge_dive_percent += delta * attr.DIVE_CHARGE_RATE
			
		# Charge reticle
		reticle.polygon[2] = reticle.to_local(get_global_mouse_position()).normalized() * max(attr.RETICLE_MIN_DISTANCE, attr.RETICLE_MAX_DISTANCE * charge_dive_percent)
		reticle.rotation = reticle.position.angle_to_point(get_local_mouse_position())
		reticle.modulate.s = 1 * charge_dive_percent
		
	if Input.is_action_just_released("dive") && dives_used < attr.MAX_DIVES && dive_cooldown <= 0.0 && charging_dive:
		var dive_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
		animation_player.queue("dive_start")
		velocity = dive_direction * attr.DIVE_VELOCITY * (0.7 + charge_dive_percent)
		print("%s | %s" % [dive_direction, velocity])
		
		motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
		animated_sprite.look_at(velocity)
		animated_sprite.flip_h = sign(velocity.x) < 0
		
		dives_used += 1
		diving = true
		dive_cooldown = attr.MAX_DIVE_COOLDOWN
		charging_dive = false
		charge_dive_percent = 0
		reticle.rotation = 0
		reticle.polygon = default_reticle
		
		
func jump_handler(delta):
	# Handle jump.
	if jump_cooldown > 0.0:
		jump_cooldown -= delta * 1000 # convert to ms
	if is_on_floor():
		jumps_used = 0
	if Input.is_action_just_pressed("jump") and jumps_used < attr.MAX_JUMPS && jump_cooldown <= 0.0:
		diving = false
		velocity.y = attr.JUMP_VELOCITY
		jumps_used += 1
		jump_cooldown = attr.MAX_JUMP_COOLDOWN


func direction_handler():
	if !diving:
		direction = Input.get_axis("move_left", "move_right")
		if direction > 0:
			animated_sprite.flip_h = false
		if direction < 0:
			animated_sprite.flip_h = true		
	return direction

func movement_animation_handler():
	if !diving && (animated_sprite.animation != "dive_end" || !animated_sprite.is_playing()):
		if !is_on_floor():
			animated_sprite.play("jump")
		elif direction == 0:
			animated_sprite.play("idle")	
		else:
			animated_sprite.play("run")
		
func velocity_handler():
	if direction:
		velocity.x = direction * attr.SPEED
	elif dead:
		velocity.x = move_toward(velocity.x, 0, attr.SPEED/80)
	elif !diving:
		velocity.x = move_toward(velocity.x, 0, attr.SPEED)
	
func die():
	if not dead:
		print("death")
		hasDied.emit()
		dead = true
		reticle.hide()
		animated_sprite.rotation = 0.0
		animated_sprite.play("death")
