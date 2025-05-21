extends ParallaxBackground

@export var scroll_speed: float = 100.0  # Velocidade base da rolagem

func _process(delta):
	# Move o background como se a câmera fosse para a direita
	scroll_offset.x += scroll_speed * delta
