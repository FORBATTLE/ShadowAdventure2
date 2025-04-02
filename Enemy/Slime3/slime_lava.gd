extends CharacterBody2D

@export var speed: float = 100.0  # Movement speed
var direction: int = 1  # 1 for right, -1 for left
@export var health: int = 3
var is_dying: bool = false
var is_playing_damage_animation: bool = false  # To track if damage animation is active
var current_animation: String = "Run"  # Tracks the current animation
@export var attack_damage: int = 35  # Damage dealt to the player
@export var attack_cooldown: float = 3  # Cooldown time between attacks
var is_attacking: bool = false
var attack_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(attack_timer)
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)
	pass # Replace with function body.

func _on_animation_finished(name: String) -> void:
	if name == "Attack":
		is_attacking = false

func _process(delta: float) -> void:
	if is_attacking:
		return
	if is_dying:
		return
	# Calculate velocity based on the direction
	velocity.x = direction * speed
	# Move using the new Godot 4 method
	var collision_info = move_and_collide(velocity * delta)
	
	# Optional: Detect collision and change direction if colliding with a wall
	if collision_info:
		change_direction()
	#if !$RayCast2D.is_colliding():
		#change_direction()
	if is_playing_damage_animation:
		return
	
	
	if direction != 0:
		play_animation("Run")
	else:
		play_animation("Idle")

func change_direction() -> void:
	direction *= -1  # Reverse direction
	$AnimatedSprite2D.flip_h = direction == -1  # Flip sprite for left/right direction

func take_damage(amount: int) -> void:
	health -= amount
	if health > 0:
		if $AnimationPlayer.has_animation("Hurt"):
			is_playing_damage_animation = true
			current_animation = "Run"
			$AnimationPlayer.stop()  # Stop any current animation
			$AnimationPlayer.play("Hurt")
			print("Taking damage!")
	else:
		die()
	
func die() -> void:
	if is_dying:
		return  # Prevent multiple death triggers

	is_dying = true
	$AnimationPlayer.play("Death")

	# Queue free after death animation finishes
	$AnimationPlayer.animation_finished.connect(self._on_death_animation_finished)
	
func _on_death_animation_finished(name: String) -> void:
	if name == "Death":
		queue_free()
	
func _on_damage_animation_finished(name: String) -> void:
	if name == "Hurt":
		is_playing_damage_animation = false
		play_animation(current_animation)  # Resume the previous animation
	
func play_animation(animation_name: String) -> void:
	if !$AnimationPlayer.is_playing() or $AnimationPlayer.current_animation != animation_name:
		$AnimationPlayer.play(animation_name)
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_in_group("Player") and not is_attacking:
		start_attack(body)
	pass

func start_attack(target: Node) -> void:
	is_attacking = true
	$AnimationPlayer.play("Attack")
	attack_timer.start()  # Start cooldown timer
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)
func _on_attack_timer_timeout() -> void:
	is_attacking = false
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	play_animation("Run")
	pass # Replace with function body.


func _on_attack_range_body_entered(body: Node2D) -> void:
	print("Detected body:", body.name)
	if body.name == "Archer" or body.name == "Knight" or body.name == "Jordan" and not is_attacking:
		print("Attacking player!")
		start_attack(body)
	pass # Replace with function body.
