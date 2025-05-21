extends Area2D


@export var dano: int = 3


@onready var animation = $AnimationPlayer


func _ready():
	animation.play("batida")
	

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(dano)
	
