extends CharacterBody2D
class_name Player

@onready var sprite: Sprite2D = $Texture
@onready var animation: AnimationPlayer = $Animation
@onready var attack1: Area2D = $Attack1
@onready var attack2: Area2D = $Attack2
@onready var attack3: Area2D = $Attack3
@onready var timer = $Timer
@onready var barra_de_vida = $ProgressBar
@onready var hud = $"../Hud/Moeda"
@onready var gun_anim: AnimationPlayer = $GUNVISUALS/AnimationPlayer
@onready var barra_de_energia = $BarraDeEnergia
@onready var energia_timer = $energiaTimer


@export var vida_max = 30
@export var dano_ataque1 = 1
@export var dano_ataque2 = 2
@export var dano_ataque3 = 3
@export var energia_maxima = 100
@export var consumo_energia = 20
@export var tempo_recuperacao = 1.0
@export var taxa_recuperacao = 60

@export var move_speed: int = 150
@export var jump_speed: int = -300
@export var gravity_speed: int = 1000
@export var attack_cooldown: float = 0.8

var jumps: int = 0
var can_attack3: bool = true
var atacando: bool = false
var vida: int = vida_max
var is_dead: bool = false
var levando_hit: bool = false
var hurt_duration: float = 0.0
var contador_de_dinheiro: int = 0
const MAX_HURT_DURATION: float = 0.12
var has_gun: bool = false
var ammo: int = 0
var energia: int = energia_maxima
var recuperacao_energia: bool = false

const ATTACK_OFFSET_X = 25
const BULLET_SCENE = preload("res://Schenes/Player/bullet.tscn")

func _ready():
	atacando = false
	barra_de_vida.max_value = vida_max
	barra_de_vida.value = vida
	$GUNVISUALS.visible = false
	atualizar_hud_dinheiro() 
	barra_de_energia.max_value = energia_maxima
	barra_de_energia.value = energia
	energia_timer.wait_time = tempo_recuperacao

func _physics_process(delta):
	if global_position.y > 1850 and not is_dead:
		die()
	if is_dead:
		return
	
	recuperar_energia(delta)
	if levando_hit:
		velocity = Vector2.ZERO
		hurt_duration -= delta
		if hurt_duration <= 0:
			levando_hit = false
	else:
		if not is_on_floor():
			velocity.y += gravity_speed * delta

		# Movimento para direita
		if Input.is_action_pressed("ui_right"):
			velocity.x = move_speed
			sprite.flip_h = false
			sprite.offset.x = 0
			attacking1(false)
			attacking2(false)
			attacking3(false)
			if not atacando:
				if has_gun:
					animation.play("gun_run")
				else:
					animation.play("run")

		# Movimento para esquerda
		elif Input.is_action_pressed("ui_left"):
			velocity.x = -move_speed
			sprite.flip_h = true
			sprite.offset.x = -20
			attacking1(true)
			attacking2(true)
			attacking3(true)
			if not atacando:
				if has_gun:
					animation.play("gun_run")
				else:
					animation.play("run")

		# Sem movimento
		else:
			velocity.x = 0
			if is_on_floor() and not atacando:
				if has_gun:
					animation.play("gun_idle")
				else:
					animation.play("Idle")

		# Pulo / Duplo Pulo
		if Input.is_action_just_pressed("ui_up"):
			if is_on_floor() or jumps < 1:
				velocity.y = jump_speed
				jumps += 1
				if jumps == 1:
					if has_gun:
						animation.play("gun_jump")
					else:
						animation.play("jump")
				else:
					animation.play("DoubleJump")

		if is_on_floor():
			jumps = 0

		# Ataque corpo-a-corpo 1
		if Input.is_action_just_pressed("attack1") and not atacando:
			if has_gun:
				animation.play("gun_attack")
			else:
				animation.play("Attack1")
			atacando = true
			await get_tree().create_timer(0.6).timeout
			atacando = false

		# Ataque corpo-a-corpo 2
		elif Input.is_action_just_pressed("attack2") and not atacando:
			atacando = true
			while Input.is_action_just_pressed("attack2"):
				animation.play("Attack2")
				await get_tree().create_timer(0.8).timeout
				atacando = false

		# Ataque corpo-a-corpo 3
		elif Input.is_action_just_pressed("attack3") and can_attack3 and not atacando and energia >= consumo_energia:
			animation.play("Attack3")
			atacando = true
			energia -= consumo_energia
			barra_de_energia.value = energia
			recuperacao_energia = false
			energia_timer.start()
			can_attack3 = false
			await get_tree().create_timer(attack_cooldown).timeout
			can_attack3 = true
			atacando = false

		# Disparo com arma
		if has_gun and Input.is_action_just_pressed("shoot") and ammo > 0:
			disparar_projetil()
			ammo -= 1

			if ammo <= 0:
				has_gun = false
				animation.play("Idle")
				$GUNVISUALS.visible = false

	move_and_slide()


func attacking1(facing_left: bool):
	attack1.position.x = -ATTACK_OFFSET_X if facing_left else ATTACK_OFFSET_X - 25

func attacking2(facing_left: bool):
	attack2.position.x = -ATTACK_OFFSET_X if facing_left else ATTACK_OFFSET_X - 25

func attacking3(facing_left: bool):
	attack3.position.x = -ATTACK_OFFSET_X - 18 if facing_left else ATTACK_OFFSET_X - 25

func _on_timer_timeout():
	get_tree().reload_current_scene()

func _on_animation_animation_finished(anim_name):
	if anim_name == "attack1":
		atacando = false
	if anim_name == "death":
		timer.start()
	if anim_name == "hurt":
		print("Animação hurt terminou.")

func take_damage(amount: int):
	if is_dead:
		return
	vida -= amount
	barra_de_vida.value = vida
	if vida <= 0:
		die()
	else:
		levando_hit = true
		hurt_duration = MAX_HURT_DURATION
		animation.play("hurt")

func die():
	is_dead = true
	velocity = Vector2.ZERO
	animation.play("death")

func _on_attack_1_body_entered(body):
	if body.is_in_group("inimigo") and atacando:
		body.take_damage(dano_ataque1)

func _on_attack_2_body_entered(body):
	if body.is_in_group("inimigo") and atacando:
		body.take_damage(dano_ataque2)

func _on_attack_3_body_entered(body):
	if body.is_in_group("inimigo") and atacando:
		body.take_damage(dano_ataque3)

func coletaMoeda():
	contador_de_dinheiro += 9
	atualizar_hud_dinheiro()

func get_gun():
	vida += 8
	has_gun = true
	ammo = 30
	$GUNVISUALS.visible = true

func disparar_projetil():
	var bullet = BULLET_SCENE.instantiate()
	
	# Aparecer um pouco à frente do player
	var offset = Vector2(30, -2) if not sprite.flip_h else Vector2(-30, -10)
	bullet.global_position = global_position + offset
	
	# Direção baseada no flip do sprite
	bullet.direction = Vector2.LEFT if sprite.flip_h else Vector2.RIGHT
	get_tree().current_scene.add_child(bullet)

func aumentar_dinheiro(valor: int):
	contador_de_dinheiro += valor
	atualizar_hud_dinheiro()

func atualizar_hud_dinheiro():
	if is_instance_valid(hud):
		hud.text = "Dinheiro: %d" % contador_de_dinheiro
	else:
		printerr("HUD de dinheiro não é válido!")


func _on_energia_timer_timeout():
	recuperacao_energia = true
	
func recuperar_energia(delta: float):
	if recuperacao_energia and energia < energia_maxima:
		energia += taxa_recuperacao * delta
		
		barra_de_energia.value = energia
		
		if energia >= energia_maxima:
			energia = energia_maxima
			recuperacao_energia = false
	
	
