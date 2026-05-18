extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("jugador"):
		call_deferred("_cambiar_escena")

func _cambiar_escena() -> void:
	get_tree().change_scene_to_file("res://victoria.tscn")
