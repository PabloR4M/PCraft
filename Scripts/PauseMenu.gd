extends Control

signal continue_pressed
signal exit_pressed

func _ready():
	$ContinueButton.pressed.connect(_on_continue)
	$ExitButton.pressed.connect(_on_exit)
	visible = false

func _on_continue():
	emit_signal("continue_pressed")
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	visible = false

func _on_exit():
	emit_signal("exit_pressed")
