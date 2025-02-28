extends CharacterBody2D
@export var speed: float = 100.0  # Movement speed
var direction: int = 1  # 1 for right, -1 for left
@export var health: int = 3



func _ready() -> void:
	pass # Replace with function body.



func _process(delta: float) -> void:
	# Calculate velocity based on the direction
	velocity.x = direction * speed
	# Move using the new Godot 4 method
	var collision_info = move_and_collide(velocity * delta)

	# Optional: Detect collision and change direction if colliding with a wall
	if collision_info:
		change_direction()
	#if !$RayCast2D.is_colliding():
		#change_direction()
	if direction != 0:
		$AnimationPlayer.play("O1Run")
	else:
		$AnimationPlayer.play("O1Idle")

func change_direction() -> void:
	direction *= -1  # Reverse direction
	$AnimatedSprite2D.flip_h = direction == -1  # Flip sprite for left/right direction

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()
func die() -> void:
	queue_free()  # Remove the enemy from the game
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.take_damage(1)  # Call the player’s damage function
	
	
	
	
	
	
	
	
