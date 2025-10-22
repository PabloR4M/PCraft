extends CanvasLayer

# === NODOS DE UI ===
@onready var pause_menu = get_node("../PauseMenu")
@onready var ui = get_node("../UI")
@onready var canvas_layer = get_node("../CanvasLayer")
@onready var tuto = get_node("../Tutorial")

# === CÁMARAS DEL TUTORIAL ===
@onready var cam_components = get_node("../MarkerComponents")
@onready var cam_pc = get_node("../MarkerPC")
@onready var cam_info = get_node("../MarkerInfo")

# === ELEMENTOS DEL TUTORIAL ===
@onready var scientist_image = $ScientistSprite
@onready var text_label = $DialogLabel

# === VARIABLES ===
var step := 0
var tutorial_steps = []
var auto_step_time := 6.0 # segundos entre pasos automáticos
var timer : Timer

func _ready():
	# Ocultar UIs y pausar el juego
	pause_menu.visible = false
	ui.visible = false
	canvas_layer.visible = false
	tuto.visible = true
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)

	# Desactivar todas las cámaras al inicio
	cam_components.current = false
	cam_pc.current = false
	cam_info.current = false

	# Temporizador
	timer = Timer.new()
	timer.wait_time = auto_step_time
	timer.one_shot = true
	timer.autostart = false
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(timer)
	timer.connect("timeout", Callable(self, "_next_step"))

	# Pasos
	tutorial_steps = [
	{
		"text": "¡Hola! Soy el Dr. Byte. Te enseñaré cómo ensamblar tu primera computadora.",
		"image": preload("res://Image/tutorial/scientist/Scientist-saludo.png"),
		"camera": null
	},
	{
		"text": "Primero aquí están los componentes que necesitarás. ¡Obsérvalos con atención!",
		"image": preload("res://Image/tutorial/scientist/Scientist-señalando.png"),
		"camera": cam_components
	},
	{
		"text": "Para tomar uno presiona 'E' mientras tu cursor se expande.",
		"image": preload("res://Image/tutorial/scientist/Scientist-compnent.png"),
		"camera": null
	},
	{
		"text": "Algunos componentes no se pueden montar antes que otros, monta los componentes de Izquierda a Derecha",
		"image": preload("res://Image/tutorial/scientist/Scientist-compnent.png"),
		"camera": null
	},
	{
		"text": "Y aquí está la computadora que ensamblarás.",
		"image": preload("res://Image/tutorial/scientist/Scientist-tablet.png"),
		"camera": cam_pc
	},
	{
		"text": "Para poner una pieza presiona 'E' mientras tu cursor se expande.",
		"image": preload("res://Image/tutorial/scientist/Scientist-compnent.png"),
		"camera": null
	},
	{
		"text": "Por último, aquí verás la información de cada componente.",
		"image": preload("res://Image/tutorial/scientist/Scientist-señalando.png"),
		"camera": cam_info
	},
	{
		"text": "¡Eso es todo! Mucha suerte y diviértete armando tu primera PC.",
		"image": preload("res://Image/tutorial/scientist/Scientist-saludo.png"),
		"camera": null
	}
]


	step = 0
	_show_step()


func _show_step():
	timer.stop()
	var current = tutorial_steps[step]
	text_label.text = current["text"]
	scientist_image.texture = current["image"]

	# Cambiar cámara si hay una asignada
	if current["camera"]:
		# Desactivar todas primero
		cam_components.current = false
		cam_pc.current = false
		cam_info.current = false

		# Activar la cámara del paso actual
		var c = current["camera"]
		c.current = true

		# Llamar al método start_move() de la cámara para iniciar animación
		if c.has_method("start_move"):
			c.start_move()

	timer.start()


func _input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		_next_step()


func _next_step():
	step += 1
	if step < tutorial_steps.size():
		_show_step()
	else:
		_end_tutorial()


func _end_tutorial():
	timer.stop()

	# Desactivar todas las cámaras del tutorial
	cam_components.current = false
	cam_pc.current = false
	cam_info.current = false

	# Volver a mostrar UI y reactivar juego
	ui.visible = true
	canvas_layer.visible = true
	get_tree().paused = false
	self.visible = false
	queue_free()
