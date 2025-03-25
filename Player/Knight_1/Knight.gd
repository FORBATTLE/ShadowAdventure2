extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0


@onready var AP: AnimationPlayer = $AnimationPlayer
@export var max_health: int = 10
var current_health: int
var health_bar: TextureProgressBar
var facing_direction = 1  # 1 = Right, -1 = Left
var is_moving = false
@export var attack_damage: int = 100  # Damage dealt to the player
@export var attack_cooldown: float = 1.5  # Cooldown time between attacks
var is_slashing: bool = false
var attack_timer: Timer = Timer.new()
var can_slash = true
func _ready():
	update_health_bar()
	current_health = max_health
@onready var hit_box: Area2D = $HitBox
@export var slashing = false

	
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
	if move_input != 0:
		$AnimatedSprite2D.flip_h = (facing_direction == -1)  # Flip sprite based on direction
		is_moving = true
	else:
		is_moving = false
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	
	
	if not is_on_floor():
		$AnimationPlayer.play("Jump")
	elif is_moving and not is_slashing:
		$AnimationPlayer.play("Run")
	elif not is_moving and not is_slashing:
		$AnimationPlayer.play("Idle")
	if Input.is_action_just_pressed("ui_accept") and can_slash:
		slash()
		play_slash_animation()
	

	move_and_slide()

func slash():
	can_slash = false  # Prevent further slashes until cooldown ends
	$attack_timer.start()  # Start cooldown timer
	AP.play("Attack")  # Play the attack animation


func play_slash_animation():
	is_slashing = true
	AP.play("Attack")

	# Set a timer to reset shooting state after 0.5 seconds
	await get_tree().create_timer(1).timeout  # Wait for half the attack animation time
	is_slashing = false


# Timer callback to handle attack cooldown
func _on_attack_timer_timeout():
	can_slash = true  # Allow slashing again after cooldown

# Function to handle collision detection and apply damage to enemies
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("take_damage") and body.is_in_group("Enemies"):
		body.take_damage(attack_damage)
		print("Damage dealt to enemy")

func take_damage(amount: int): 
	# Reduce health by the damage amount
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)  # Ensure it doesn’t go below 0
	if current_health <= 0:
		die()
	else:
		set_physics_process(false)  
		set_process(false)
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Damaged")
		await $AnimationPlayer.animation_finished
		set_physics_process(true)  
		set_process(true)
func die():
	set_physics_process(false)
	set_process(false)
	AP.play("Death")
	await $AnimationPlayer.animation_finished
	# Handle player death (e.g., play animation, reset level)
	print("Player has died!")
	# Optionally, restart the scene or disable player controls
	get_tree().reload_current_scene()
func update_health_bar():
	if health_bar:
		health_bar.value = current_health
