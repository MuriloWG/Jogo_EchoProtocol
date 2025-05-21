extends StaticBody2D

@export var vida_max = 2
@onready var animation = $AnimationPlayer
@onready var area_2d = $Area2D
@onready var timer = $Timer

var vida: int = vida_max
var open: bool = false

func _ready():
	# Garantir que o timer não esteja pausado e tenha o tempo configurado
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))

func _on_area_2d_body_entered(body):
	if body.is_in_group("player") and not open:
		take_damage(1)

func take_damage(amount: int):
	vida -= amount
	if vida <= 0:
		open_bau()

func open_bau():
	open = true
	animation.play("abrirBau")
	call_deferred("drop_itens")
	timer.start()

func drop_itens():
	var dinheiro_scene = preload("res://Schenes/Decoration/dinheiro.tscn")
	var dinheiro = dinheiro_scene.instantiate()
	# Spawnar aleatoriamente próximo do baú, +/- 20 pixels em X e Y
	dinheiro.position = position + Vector2(randf_range(-20, 20), randf_range(-30, -10))
	get_parent().add_child(dinheiro)

func _on_timer_timeout():
	queue_free()
