extends CanvasLayer

func _ready():
	get_tree().paused = true  # Pausa o jogo quando a cena é carregada
	
	

func _on_voltar_button_pressed():
	get_tree().paused = false
	queue_free()
	
func _on_voltar_2_pressed():
	get_tree().paused = false
	queue_free()


func _on_reiniciar_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_sair_button_pressed():
	get_tree().quit()



