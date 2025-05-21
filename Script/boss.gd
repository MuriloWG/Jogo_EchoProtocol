extends CharacterBody2D

@export var vida_max = 50
@export var dano = 5
@export var speed = 100.0
@export var gravity = 600.0
@export var attack_range = 80.0
@export var attack_cooldown = 1.0
@export var tipo_de_inimigo := "boss" # Defini o tipo do inimigo

@onready var animation = $AnimationPlayer
@onready var attack_area = $AttackArea
@onready var attack_timer = $AttackTimer
@onready var barra_de_vida = $ProgressBar
@onready var sprite = $Sprite2D

var vida: int = vida_max
var is_dead: bool = false
var atacando: bool = false
var direction: Vector2 = Vector2.ZERO
var player: Node2D
var can_attack: bool = true
var is_dying: bool = false

func _ready():
	barra_de_vida.max_value = vida_max
	barra_de_vida.value = vida
	if is_instance_valid(attack_timer):
		attack_timer.wait_time = attack_cooldown
	else:
		printerr("Boss: attack_timer não foi inicializado corretamente!")
		queue_free()
		return

	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		printerr("Boss: Não encontrou o Player na cena!")
		queue_free()
		return


func _process(_delta):
	if is_dead or is_dying:
		return
	update_animation()

func _physics_process(delta):
	if is_dead or is_dying:
		return

	velocity.y += gravity * delta

	if not atacando and player:
		direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * speed
	else:
		velocity.x = 0

	if direction.x != 0:
		sprite.flip_h = direction.x < 0

	move_and_slide()

func update_animation():
	if is_dead:
		play_animation("death")
	elif atacando:
		play_animation("ataque")
	elif velocity.length() > 0:
		play_animation("walk")
	else:
		play_animation("idle")

func play_animation(name: String):
	if animation.current_animation != name:
		animation.play(name)

func _on_AttackTimer_timeout():
	if is_dead or is_dying or atacando:
		return
	if player and global_position.distance_to(global_position) < attack_range and can_attack:
		atacar()

func atacar():
	if not can_attack or is_dying:
		return
	atacando = true
	can_attack = false
	velocity = Vector2.ZERO
	play_animation("ataque")

	if animation.has_animation("ataque"):
		await animation.animation_finished
		finalizar_ataque()
	else:
		await get_tree().create_timer(0.6).timeout
		finalizar_ataque()

func finalizar_ataque():
	if player and global_position.distance_to(global_position) < attack_range:
		player.take_damage(dano)
	atacando = false
	if is_instance_valid(attack_timer):
		attack_timer.start()
	can_attack = true



func take_damage(amount: int):
	if is_dead or is_dying:
		return

	vida -= amount
	barra_de_vida.value = vida
	if vida <= 0:
		die()
	else:
		play_animation("hit")

func die():
	is_dying = true
	is_dead = true
	velocity = Vector2.ZERO
	play_animation("death")
	await animation.animation_finished
	dar_recompensa_e_liberar()

func _on_AttackArea_body_entered(body):
	if body.is_in_group("player") and can_attack and is_instance_valid(attack_timer) and not is_dying:
		attack_timer.start()

func _on_AttackArea_body_exited(body):
	if body.is_in_group("player") and is_instance_valid(attack_timer) and not is_dying:
		attack_timer.stop()

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
