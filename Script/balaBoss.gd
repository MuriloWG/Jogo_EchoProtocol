extends Area2D

@export var speed = 200.0
var direction = Vector2.RIGHT

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(2)
		queue_free()
