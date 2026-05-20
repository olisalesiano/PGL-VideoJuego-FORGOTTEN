extends CharacterBody2D

const SPEED = 60.0
const GRAVEDAD = 450.0

@export var invertido := false
var direccion := 1.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var cabeza: Area2D = $cabeza
@onready var cuerpo: Area2D = $cuerpo
@onready var sonido_muerte: AudioStreamPlayer = $SplashDeath
@onready var sonido_aww: AudioStreamPlayer = $Aww

func _ready() -> void:
	cabeza.body_entered.connect(_on_cabeza_body_entered)
	if invertido:
		rotation_degrees = 180
		anim.flip_h = true
	else:
		anim.flip_h = false

func _physics_process(delta: float) -> void:
	if invertido:
		anim.flip_h = direccion > 0
	else:
		anim.flip_h = direccion < 0

	velocity.x = SPEED * direccion

	if is_on_wall():
		direccion *= -1
		velocity.x = SPEED * direccion * 2.0

	if not anim.is_playing():
		anim.play("alien_floor_walk")

	for body in cuerpo.get_overlapping_bodies():
		if body.is_in_group("jugador"):
			body.morir()

	move_and_slide()

func _on_cabeza_body_entered(body: Node) -> void:
	if body.is_in_group("jugador"):
		_morir()
		body.velocity.y = 200.0 if invertido else -200.0

func _morir() -> void:
	cuerpo.queue_free()
	cabeza.queue_free()
	set_physics_process(false)
	anim.visible = false
	sonido_muerte.play()
	await get_tree().create_timer(0.5).timeout
	sonido_aww.play()
	await sonido_aww.finished
	queue_free()
