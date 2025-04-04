extends Area2D

@export var speed: float = 400.0
@export var damage: int = 10

func _ready():
	connect("body_entered", _on_body_entered)

func _process(delta):
	position.x += speed * delta  # Adjust direction as needed

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()  # Destroy the projectile on impact	  


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	# Destroy if it leaves the screen
