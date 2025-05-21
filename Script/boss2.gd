extends CharacterBody2D

const VIDA_MAX = 100
const DANO_MELEE = 2 # Renomeado para clareza
const BULLET_SCENE = preload("res://Schenes/Decoration/balaBoss.tscn") 

@onready var animation: AnimationPlayer = $Animation 
@onready var sprite: Sprite2D = $Textura 
@onready var attack_timer: Timer = $AttackTimer
@onready var barra_de_vida: ProgressBar = $ProgressBar 
@onready var player_detection_area: Area2D = $PlayerDetector 

var vida: int = VIDA_MAX
var is_dead: bool = false
var player_in_range: bool = false
var current_player_node: Node2D = null

# Movimento
var direction_patrol := 1 
const SPEED := 30.0
var patrol_distance := 100.0
var initial_x := 0.0

func _ready():
	initial_x = global_position.x
	barra_de_vida.max_value = VIDA_MAX
	barra_de_vida.value = vida
	
	
	attack_timer.wait_time = 5.0 
	attack_timer.one_shot = false 
	attack_timer.start()
	
	animation.play("walk")

	
	if player_detection_area:
		player_detection_area.body_entered.connect(_on_player_detector_body_entered)
		player_detection_area.body_exited.connect(_on_player_detector_body_exited)
	else:
		printerr("Nó PlayerDetector não encontrado ou não é uma Area2D!")

func _physics_process(delta: float):
	if is_dead:
		return

	
	if not player_in_range or (player_in_range and global_position.distance_to(current_player_node.global_position if current_player_node else global_position) > 80): # Só patrulha se jogador longe ou fora de alcance
		global_position.x += SPEED * direction_patrol * delta
		velocity = Vector2(SPEED * direction_patrol, 0) 
		move_and_slide()

		
		if abs(global_position.x - initial_x) >= patrol_distance:
			direction_patrol *= -1
			if direction_patrol < 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			
	elif player_in_range and current_player_node:
		
		if current_player_node.global_position.x < global_position.x:
			sprite.flip_h = true 
		else:
			sprite.flip_h = false 
		velocity = Vector2.ZERO 
		move_and_slide()


func _on_attack_timer_timeout():
	if is_dead or not player_in_range or not current_player_node:
		
		if not is_dead and animation.current_animation != "walk" and animation.current_animation != "death" and animation.current_animation != "hurt":
			animation.play("walk")
		return

	var distance_to_player = global_position.distance_to(current_player_node.global_position)
	

	if distance_to_player < 60: 
		attack_melee()
	else:
		var escolha_ranged = randi() % 2 
		if escolha_ranged == 0:
			attack_shoot()
		else:
			attack_special()

func attack_melee():
	if is_dead: return
	animation.play("attack") 
	
	if current_player_node and global_position.distance_to(current_player_node.global_position) < 80: 
		current_player_node.call_deferred("take_damage", DANO_MELEE)


func attack_shoot():
	if is_dead or not current_player_node: return
	animation.play("shoot") 
	
	var num_bullets = 3
	var delay_between_bullets = 0.25 

	for i in range(num_bullets):
		if is_dead: return 
		disparar_bala() 
		if i < num_bullets - 1: 
			await get_tree().create_timer(delay_between_bullets).timeout


func attack_special():
	if is_dead or not current_player_node: return
	animation.play("special") 
	
	var num_bullets_special = 5
	var delay_between_bullets_special = 0.15
	var spread_angle_deg = 45.0 

	
	var base_direction_to_player = (current_player_node.global_position - global_position).normalized()
	
	var angle_step = 0.0
	if num_bullets_special > 1:
		angle_step = deg_to_rad(spread_angle_deg) / (num_bullets_special - 1)
	
	var start_angle = base_direction_to_player.angle() - (deg_to_rad(spread_angle_deg) / 2.0)

	for i in range(num_bullets_special):
		if is_dead: return

		var current_bullet_angle = start_angle + (i * angle_step)
		var bullet_direction = Vector2.RIGHT.rotated(current_bullet_angle) 
		
		disparar_bala(bullet_direction)
		
		if i < num_bullets_special - 1:
			await get_tree().create_timer(delay_between_bullets_special).timeout



func disparar_bala(p_forced_direction: Vector2 = Vector2.ZERO):
	if is_dead: return

	var bullet_instance = BULLET_SCENE.instantiate()
	if not bullet_instance:
		printerr("Falha ao instanciar a cena da bala (balaBoss.tscn)!")
		return

	
	var spawn_offset_x = 40.0 
	if sprite.flip_h: 
		spawn_offset_x = -40.0
	
	
	bullet_instance.global_position = global_position + Vector2(spawn_offset_x, -5.0) 

	var final_bullet_direction: Vector2

	if p_forced_direction != Vector2.ZERO:
		final_bullet_direction = p_forced_direction.normalized()
	else:
		
		if player_in_range and current_player_node:
			
			final_bullet_direction = (current_player_node.global_position - bullet_instance.global_position).normalized()
		else:
			
			if sprite.flip_h:
				final_bullet_direction = Vector2.LEFT
			else:
				final_bullet_direction = Vector2.RIGHT
	
	
	if bullet_instance.has_method("set_direction"):
		bullet_instance.call("set_direction", final_bullet_direction)
	elif "direction" in bullet_instance:
		bullet_instance.set("direction", final_bullet_direction)
	
		
		
	get_tree().current_scene.add_child(bullet_instance)


func _on_player_detector_body_entered(body):
	if body.is_in_group("player"): 
		player_in_range = true
		current_player_node = body as Node2D 
		


func _on_player_detector_body_exited(body):
	if body.is_in_group("player") and body == current_player_node:
		player_in_range = false
		current_player_node = null 
	
		if not is_dead and animation.current_animation != "walk": 
			animation.play("walk")


func take_damage(amount: int):
	if is_dead:
		return 
	
	vida -= amount
	if barra_de_vida: 
		barra_de_vida.value = vida
	
	if vida <= 0:
		vida = 0 
		if barra_de_vida:
			barra_de_vida.value = vida
		die()
	else:
		if animation.has_animation("hurt"): 
			animation.play("hurt")
		


func die():
	if is_dead: return 

	is_dead = true
	
	attack_timer.stop() 
	
	velocity = Vector2.ZERO
	
	if animation.has_animation("death"):
		animation.play("death")
		await animation.animation_finished 
	
	
	queue_free() 
