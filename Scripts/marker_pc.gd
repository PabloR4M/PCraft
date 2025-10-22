extends Camera3D

# === MOVIMIENTO EN Y Y ROTACIÓN EN X ===
@export var from_position: Vector3 = Vector3(-9.7, 1, 13)
@export var to_position: Vector3 = Vector3(-9.7, 2.5, 13)
@export var from_rotation_deg: Vector3 = Vector3(25, -180, 0)
@export var to_rotation_deg: Vector3 = Vector3(-25, -180, 0)
@export var speed: float = 0.1  # Velocidad de interpolación

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

	# Interpolación lineal para posición en Y
	t += direction * speed * delta
	t = clamp(t, 0, 1)

	var new_pos = global_transform.origin
	new_pos.y = lerp(from_position.y, to_position.y, t)
	global_transform.origin = new_pos

	# Interpolación lineal para rotación en X
	var new_rot = rotation_degrees
	new_rot.x = lerp(from_rotation_deg.x, to_rotation_deg.x, t)
	rotation_degrees = new_rot

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
