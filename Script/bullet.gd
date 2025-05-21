extends Area2D

@export var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("inimigo"):
		body.take_damage(1)  # ou o valor que quiser
	queue_free()
