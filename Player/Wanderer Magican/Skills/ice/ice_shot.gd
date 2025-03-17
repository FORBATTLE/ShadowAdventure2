extends Area2D
var speed = 200
var speed_mod = 1.5
var direction = Vector2.ONE
@export var damage: int = 100 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta * speed_mod
	
	pass


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		$AnimatedSprite2D.play("Impact")
		speed = 0
	
	if body is CharacterBody2D and body.has_method("take_damage") and body.is_in_group("Enemies"):
		body.take_damage(damage)
		queue_free()
	queue_free()
	pass # Replace with function body.


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
	pass # Replace with function body.
