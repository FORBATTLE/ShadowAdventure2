extends Area2D
var speed = 300
var speed_mod = 1.0
var direction = Vector2.ONE

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
		pass # Replace with function body.
