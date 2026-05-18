extends Node2D
@onready var negro: ColorRect = $CanvasLayer2/ColorRect

func _ready() -> void:
	negro.visible = true
	negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	negro.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(negro, "modulate:a", 0.0, 4.0)
	tween.tween_callback(func(): negro.visible = false)
