extends Control

@onready var estrella1: TextureRect = $HBoxContainer/estrella1
@onready var estrella2: TextureRect = $HBoxContainer/estrella2
@onready var estrella3: TextureRect = $HBoxContainer/estrella3
@onready var texto_chancla: Label = $"texto-chancla"
@onready var boton: Button = $reiniciar
@onready var yay: AudioStreamPlayer = $Yay

var gris := Color(0.3, 0.3, 0.3)
var color := Color(1, 1, 1)

func _ready() -> void:
	yay.play()
	var recogidas := GameState.estrellas_recogidas
	estrella1.modulate = color if recogidas >= 1 else gris
	estrella2.modulate = color if recogidas >= 2 else gris
	estrella3.modulate = color if recogidas >= 3 else gris
	texto_chancla.visible = recogidas < 3
	boton.pressed.connect(_on_reiniciar)
	GameState.estrellas_recogidas = 0

func _on_reiniciar() -> void:
	get_tree().change_scene_to_file("res://assets/fondo-jugable/fondo_planetas.tscn")
