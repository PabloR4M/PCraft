extends Camera3D

# === MOVIMIENTO EN X Y Z ===
@export var from_position: Vector3 = Vector3(-8.2, 2.5, 11.75)
@export var to_position: Vector3 = Vector3(-9.3, 2.5, 11)
@export var from_rotation_deg: Vector3 = Vector3(-25, -110, 0)
@export var to_rotation_deg: Vector3 = Vector3(-25, -110, 0)
@export var speed: float = 0.05  # Velocidad de interpolación

# === VARIABLES INTERNAS ===
var moving: bool = false
var t: float = 0.0
var direction: int = 1  # 1 = adelante, -1 = atrás

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	global_transform.origin = from_position
	rotation_degrees = from_rotation_deg
	t = 0.0

func _process(delta):
	if not moving:
		return  # solo se mueve si está activo

	# Interpolación lineal para X y Z
	t += direction * speed * delta
	t = clamp(t, 0, 1)

	var new_pos = global_transform.origin
	new_pos.x = lerp(from_position.x, to_position.x, t)
	new_pos.z = lerp(from_position.z, to_position.z, t)
	global_transform.origin = new_pos

	# Mantener rotación fija
	rotation_degrees = from_rotation_deg

	# Invertir dirección al llegar a los extremos
	if t >= 1.0:
		direction = -1
	elif t <= 0.0:
		direction = 1

# === INICIAR MOVIMIENTO ===
func start_move():
	global_transform.origin = from_position
	rotation_degrees = from_rotation_deg
	t = 0.0
	direction = 1
	moving = true

# === DETENER MOVIMIENTO ===
func stop_move():
	moving = false
