extends Camera3D

@export var rotation_speed: float = 2.0 # grados por segundo
@export var max_angle: float = 14.0 # grados máximos
var direction: int = 1 # 1 = hacia adelante, -1 = hacia atrás
var current_angle: float = 0.0

func _process(delta: float) -> void:
	# Actualiza el ángulo según la dirección
	current_angle += direction * rotation_speed * delta

	# Si llega a los límites, invierte la dirección
	if current_angle >= max_angle:
		current_angle = max_angle
		direction = -1
	elif current_angle <= 0:
		current_angle = 0
		direction = 1

	# Aplica la rotación a la cámara (eje X, Y o Z según lo que necesites)
	rotation_degrees.y = current_angle
