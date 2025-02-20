extends CharacterBody2D


var SPEED = 300.0
const JUMP_VELOCITY = -400.0
###
@onready var AP: AnimationPlayer = $AnimationPlayer
var facing_direction = 1  # 1 = Right, -1 = Left
var is_moving = false
var is_shooting = false
###
@export var max_health: int = 100
var current_health: int
var health_bar: TextureProgressBar

##
@export var arrow = preload("res://Player/Samurai_Archer/arrow.tscn")
var can_shoot = true
var shoot_timer 
##
func _ready():
	# Create and configure the timer
	shoot_timer = Timer.new()
	shoot_timer.wait_time = 0.5  # 0.5-second delay
	shoot_timer.one_shot = true
	shoot_timer.timeout.connect(_reset_shoot)
	add_child(shoot_timer)
	current_health = max_health
	health_bar = get_node("UI/TextureProgressBar")  # Adjust the path as needed
	update_health_bar()
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	
	var move_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if move_input != 0:
		facing_direction = 1 if move_input > 0 else -1
		is_moving = true
	else:
		is_moving = false
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		AP.play("Jump")
	


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	$"Regular Archer".flip_h = (facing_direction == -1)
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	
	
	if not is_on_floor():
		$AnimationPlayer.play("Jump")
	
	elif is_moving and not is_shooting:
		$AnimationPlayer.play("Run")
	elif not is_moving and not is_shooting:
		$AnimationPlayer.play("Idle")
	if Input.is_action_just_pressed("ui_accept") and can_shoot:
		fire_projectile()
		play_shoot_animation()
	
	
	move_and_slide()

	#if Input.is_action_just_pressed("ui_accept"):
		#var new_arrow = arrow.instantiate()
		#var arrow_vec = $bow.global_position - $ArcPlayer.global_position
		#arrow_vec = arrow_vec.normalized()
		#new_arrow.direction = arrow_vec
		#new_arrow.global_position = $bow.global_position
		#get_tree().get_root().add_child(new_arrow)
func fire_projectile():
	can_shoot = false  # Prevent shooting until cooldown ends
	shoot_timer.start()  # Start cooldown timer
	var new_arrow = arrow.instantiate()
	var spawn_offset = Vector2(-25, 0) if facing_direction == 1 else Vector2(-150, 0)#Left dir
	new_arrow.position = $bow.global_position + spawn_offset  # Spawn at a specified node (GunPoint)
	new_arrow.set_direction(facing_direction)  # Call the function to set direction
	get_parent().add_child(new_arrow)
	AP.play("Attack")
func _reset_shoot():
	can_shoot = true  # Allow shooting again
func play_shoot_animation():
	is_shooting = true
	$AnimationPlayer.play("Attack")  # Play "shoot_right" and flip sprite if needed

	# Set a timer to reset shooting state after 0.5 seconds
	await get_tree().create_timer(0.5).timeout
	is_shooting = false
func take_damage(amount: int):
	# Reduce health by the damage amount
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)  # Ensure it doesn’t go below 0
	if current_health <= 0:
		die()
func die():
	# Handle player death (e.g., play animation, reset level)
	print("Player has died!")
	# Optionally, restart the scene or disable player controls
	get_tree().reload_current_scene()
func update_health_bar():
	if health_bar:
		health_bar.value = current_health
