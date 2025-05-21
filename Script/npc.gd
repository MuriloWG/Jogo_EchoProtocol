extends Node2D


@export var item_cost = 40
@export var item_name = "Arma"
@onready var player = null
@onready var animation = $Animation

func _ready():
	$Label.visible = false
	$TextureButton.visible = false
	animation.play("idle")
	
	


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player = body
		$Label.text = "pressione 'e' para comprar uma arma\n e vida por 40 de dinheiro"
		$Label.visible = true


func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player = null
		$TextureButton.visible = false
		$Label.visible = false
		
		
func _process(delta):
	if player and Input.is_action_just_pressed("interação"):
		$TextureButton.visible = true

func _on_texture_button_pressed():
	if player and player.contador_de_dinheiro >= item_cost:
		player.contador_de_dinheiro -= item_cost
		player.get_gun()
		$TextureButton.visible = false
		$Label.text = "Comprado!"
	else:
		$TextureButton.visible = false
		$Label.text = "Dinheiro insuficiente"
		
