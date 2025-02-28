extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0

@onready var AS: AnimatedSprite2D = $AnimatedSprite2D
@onready var AP: AnimationPlayer = $AnimationPlayer
@export var max_health: int = 100
var current_health: int
var health_bar: TextureProgressBar
var facing_direction = 1  # 1 = Right, -1 = Left
var is_moving = false
@export var attack_damage: int = 10  # Damage dealt to the player
@export var attack_cooldown: float = 1.5  # Cooldown time between attacks
var is_slashing: bool = false
var attack_timer: Timer = Timer.new()
func _ready():
	update_health_bar()
	current_health = max_health
@onready var hit_box: Area2D = $HitBox

	
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
	
	if Input.is_action_just_pressed("ui_accept"):
		start_attack($".")


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if move_input != 0:
		facing_direction = 1 if move_input > 0 else -1
		is_moving = true
	else:
		is_moving = false
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	
	
	if not is_on_floor():
		$AnimationPlayer.play("Jump")
	
	elif is_moving:
		$AnimationPlayer.play("Run")
	elif not is_moving :
		$AnimationPlayer.play("Idle")
	move_and_slide()



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

func start_attack(target: Node) -> void:
	is_slashing = true
	AP.play("Attack")
	attack_timer.start()  # Start cooldown timer
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)
