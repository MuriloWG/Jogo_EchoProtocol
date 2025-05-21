extends Node2D


@onready var label = $Label
@onready var animation = $AnimationPlayer


var player_in_area: bool = false

func _ready():
	label.set("theme_override_font_sizes/font_size", 12)
	label.position = Vector2(-20, -60)  # Define a posição relativa ao Node2D

	
func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		label.visible = true
		label.text = "Quem sou eu??\n Porque estou matando pessoas??"
		

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		label.visible = false
		
