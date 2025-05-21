extends Node2D


@onready var label = $Label
@onready var animation = $AnimationPlayer


var player_in_area: bool = false

func _ready():
	animation.play("idle")
	label.set("theme_override_font_sizes/font_size", 8)


func _process(delta):
	if player_in_area and Input.is_action_just_pressed("interação"):
		label.text = "Pressione a tecla 'C' para coletar dinheiro do báu\n CUIDADO COM ALGUMAS ARMADILHAS"
	
	
func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		label.visible = true
		label.text = "Pressione 'E' para interagir"
		

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		label.visible = false
		
