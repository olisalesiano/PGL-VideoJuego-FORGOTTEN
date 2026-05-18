extends Area2D

@onready var estrella_sonido: AudioStreamPlayer = $EstrellaSonido

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("jugador"):
		GameState.estrellas_recogidas += 1
		estrella_sonido.play()
		$Sprite2D.visible = false
		$CollisionShape2D.disabled = true
		await estrella_sonido.finished
		queue_free()
