extends Node2D




func _on_escolherfase_pressed():
	get_tree().change_scene_to_file("")


func _on_iniciar_pressed():
	get_tree().change_scene_to_file("res://Schenes/Management/game_level.tscn")


func _on_sair_pressed():
	get_tree().quit()
