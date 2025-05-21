extends Node2D  # ou o nó principal da sua fase

var pause_scene := preload("res://Schenes/pause.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		var pause_menu = pause_scene.instantiate()
		add_child(pause_menu)
