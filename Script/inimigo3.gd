extends CharacterBody2D

const VIDA_MAX = 10
const DANO = 1
const BULLET_SCENE = preload("res://Schenes/Decoration/balaBoss.tscn")

@onready var animation: AnimationPlayer = $Animation
@onready var sprite: Sprite2D = $Textura
@onready var attack_timer: Timer = $AttackTimer
@onready var attack_area = $AttackArea
@onready var barra_de_vida = $ProgressBar

var vida: int = VIDA_MAX
var is_dead: bool = false
var player_in_range: bool = false

func _ready():
	barra_de_vida.max_value = VIDA_MAX
	barra_de_vida.value = vida
	animation.play("idle")
	attack_timer.wait_time = 2.0
	attack_timer.one_shot = false
	attack_timer.start()

func _on_attack_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_attack_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _on_attack_timer_timeout():
	if player_in_range and not is_dead:
		definir_direcao_disparo()
		animation.play("attack")
		disparar_bala()

func definir_direcao_disparo():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.global_position.x < global_position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

func disparar_bala():
	var bullet = BULLET_SCENE.instantiate()
	bullet.global_position = global_position + Vector2(25, 0)
	bullet.direction = Vector2.RIGHT if not sprite.flip_h else Vector2.LEFT
	get_tree().current_scene.add_child(bullet)

func take_damage(amount: int):
	if is_dead:
		return
	vida -= amount
	barra_de_vida.value = vida
	if vida <= 0:
		die()
	else:
		animation.play("hurt")

func die():
	is_dead = true
	attack_timer.stop()
	animation.play("death")
	await animation.animation_finished
	queue_free()
