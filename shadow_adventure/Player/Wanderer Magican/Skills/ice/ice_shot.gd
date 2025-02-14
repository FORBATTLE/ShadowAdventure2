extends Area2D
var speed = 300
var speed_mod = 1.0
var direction = Vector2.AXIS_X

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta * speed_mod
	
	pass
