extends CharacterBody2D

const SPEED = 10.0
const VIDA_MAX = 10
const DANO = 1

@onready var animation: AnimationPlayer = $Animation
@onready var ray = $Ray
@onready var sprite: Sprite2D = $Textura
@onready var attack_timer: Timer = $AttackTimer
@onready var attack_area = $AttackAreaEnemy1
@onready var barra_de_vida = $ProgressBar


@export var direction := 5
@export var attack_interval := 1.5
@export var tipo_de_inimigo := "comum" # Pode ser "comum", "inimigo2" ou "boss"

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var atacando: bool = false
var player_in_range: bool = false
var vida: int = VIDA_MAX
var is_dead: bool = false
var levando_hit: bool = false

var attack_area_base_x = 5

func _ready():
	barra_de_vida.max_value = VIDA_MAX
	barra_de_vida.value = vida
	animation.play("walk")
	attack_timer.wait_time = attack_interval
	attack_timer.one_shot = false
	attack_timer.stop()
	
	

	attack_area.position.x = attack_area_base_x
	flip()

func _physics_process(delta):
	if is_dead or levando_hit:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if ray.is_colliding():
		direction *= -1
		ray.scale.x *= -1
		flip()

	if atacando:
		velocity.x = 0
	else:
		velocity.x = direction * SPEED
		if animation.current_animation != "walk":
			animation.play("walk")

	move_and_slide()

func flip():
	sprite.flip_h = direction < 0
	sprite.offset.x = -20 if direction < 0 else 0

	if direction < 0:
		attack_area.position.x = -attack_area_base_x - 8
	else:
		attack_area.position.x = attack_area_base_x - 2

func _on_attack_area_enemy_1_body_entered(body):
	if body.is_in_group("player") and not is_dead:
		player_in_range = true

		if not atacando and not levando_hit:
			atacando = true
			animation.play("attack")
			var player = get_tree().get_first_node_in_group("player")
			if is_instance_valid(player):
				player.take_damage(DANO)

		attack_timer.wait_time = attack_interval
		attack_timer.start()

func _on_attack_area_enemy_1_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		attack_timer.stop()
		atacando = false
		if not is_dead:
			animation.play("walk")

func _on_animation_animation_finished(anim_name):
	if anim_name == "death":
		dar_recompensa_e_liberar()
		return

	if is_dead:
		return

	if anim_name == "attack":
		atacando = false
		if player_in_range:
			animation.play("walk")
		else:
			animation.play("idle")

	elif anim_name == "hurt":
		levando_hit = false
		if player_in_range and attack_timer.time_left > 0:
			attack_timer.start()
		else:
			atacando = false
			animation.play("walk")

func take_damage(amount: int):
	if is_dead:
		return

	vida -= amount
	barra_de_vida.value = vida
	if vida <= 0:
		die()
	else:
		levando_hit = true
		animation.play("hurt")
		if attack_timer.time_left > 0:
			attack_timer.stop()

func die():
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	attack_timer.stop()
	animation.play("death")

func _on_attack_timer_timeout():
	if player_in_range and not is_dead and not levando_hit:
		atacando = true
		animation.play("attack")
		var player = get_tree().get_first_node_in_group("player")
		if is_instance_valid(player):
			player.take_damage(DANO)

# Função para alterar o intervalo do ataque dinamicamente
func set_attack_interval(novo_tempo: float) -> void:
	attack_interval = novo_tempo
	attack_timer.wait_time = attack_interval
	if not attack_timer.is_stopped():
		attack_timer.stop()
		attack_timer.start()

func dar_recompensa_e_liberar():
	var player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		if tipo_de_inimigo == "comum":
			player.aumentar_dinheiro(2)
		elif tipo_de_inimigo == "inimigo2":
			player.aumentar_dinheiro(4)
		elif tipo_de_inimigo == "boss":
			player.aumentar_dinheiro(10)
	queue_free()
