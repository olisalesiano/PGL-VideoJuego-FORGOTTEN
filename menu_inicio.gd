extends Node2D

@onready var hover: Node = $Inicio/NuevaPartidaHover
@onready var button: Button = $Inicio/Button
@onready var negro: ColorRect = $CanvasLayer/ColorRect
@onready var sonido_gravedad: AudioStreamPlayer = $SonidoGravedad

func _ready() -> void:
	hover.visible = false
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)

func _on_button_pressed() -> void:
	sonido_gravedad.play()
	button.disabled = true
	var tween := create_tween()
	tween.tween_property(negro, "modulate:a", 1.0, 1.0)
	tween.tween_callback(_cambiar_escena)

func _cambiar_escena() -> void:
	get_tree().change_scene_to_file("res://assets/fondo-jugable/fondo_planetas.tscn")

func _on_mouse_entered() -> void:
	hover.visible = true

func _on_mouse_exited() -> void:
	hover.visible = false
