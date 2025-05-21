extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready():
	animation.play("MOEDA_GIRANDO")  # Inicia a animação da moeda

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.coletaMoeda()
		coletado()

func coletado():
	queue_free()
