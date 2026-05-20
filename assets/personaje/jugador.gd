extends CharacterBody2D
const SPEED = 150.0
const GRAVEDAD_TIERRA = 450.0
const GRAVEDAD_LUNA = 100.0
const JUMP_VELOCITY = -250.0
const IMPULSO_GRAVEDAD = -120.0
const COOLDOWN_TIEMPO = 2.0
var intro_activa := true
var pos_destino_x := 0.0
var gravity_inverted := false
var float_mode := false
var cooldown_restante := 0.0
var muriendo := false
var barra_muerte_ancho: float = 0.0
var timer_muerte: float = 0.0
const TIEMPO_MUERTE = 2.0

@onready var nave: Node = get_node("/root/Node2D/nave/Nave")
@onready var nave_morado: Node = get_node("/root/Node2D/nave/NaveMorado")
@onready var niebla: AnimatedSprite2D = get_node("/root/Node2D/efecto-comienzo/Control/Niebla_gravedad-efecto")
@onready var barra: ColorRect = get_node("/root/Node2D/efecto-comienzo/Control/ColorRect2")
@onready var sonido_gravedad: AudioStreamPlayer = $SonidoGravedad
@onready var contador: Label = get_node("/root/Node2D/efecto-comienzo/Control/ContadorEstrellas")
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var barra_ancho_total: float = 0.0
@onready var fondo_muerte: ColorRect = get_node("/root/Node2D/efecto-comienzo/Control/muerte/fondo-muerte")
@onready var texto_muerte: Label = get_node("/root/Node2D/efecto-comienzo/Control/muerte/texto-muerte")
@onready var barra_muerte: ColorRect = get_node("/root/Node2D/efecto-comienzo/Control/muerte/barra-muerte")
@onready var sonido_muerte_jugador: AudioStreamPlayer = $SonidoMuerte

func _ready() -> void:
	barra_muerte_ancho = barra_muerte.size.x
	barra_muerte.size.x = 0.0
	barra_ancho_total = barra.size.x
	nave.visible = true
	nave_morado.visible = false
	niebla.modulate.a = 0.0
	niebla.visible = true
	pos_destino_x = position.x
	position.x = -200.0
func _physics_process(delta: float) -> void:
	if intro_activa:
		position.x = move_toward(position.x, pos_destino_x, 80.0 * delta)
		if anim.animation != "walk":
			anim.play("walk")
		if position.x >= pos_destino_x:
			intro_activa = false
			anim.play("idle")
		return
	if muriendo:
		timer_muerte += delta
		barra_muerte.size.x = barra_muerte_ancho * (timer_muerte / TIEMPO_MUERTE)
		if timer_muerte >= TIEMPO_MUERTE:
			get_tree().reload_current_scene()
		return
	if cooldown_restante > 0.0:
		cooldown_restante -= delta
		cooldown_restante = max(cooldown_restante, 0.0)
		var progreso := 1.0 - (cooldown_restante / COOLDOWN_TIEMPO)
		barra.size.x = barra_ancho_total * progreso
	else:
		barra.size.x = barra_ancho_total
	if gravity_inverted:
		velocity.y -= GRAVEDAD_LUNA * delta
	else:
		velocity.y += GRAVEDAD_TIERRA * delta
	if Input.is_action_just_pressed("ui_select") and cooldown_restante <= 0.0:
		sonido_gravedad.play()
		gravity_inverted = not gravity_inverted
		float_mode = true
		anim.rotation_degrees = 180 if gravity_inverted else 0
		if gravity_inverted:
			velocity.y = IMPULSO_GRAVEDAD
		else:
			velocity.y = 0
		cooldown_restante = COOLDOWN_TIEMPO
		_hacer_efecto_niebla()
	if Input.is_action_just_pressed("move_up"):
		if not gravity_inverted and is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif gravity_inverted and is_on_ceiling():
			velocity.y = GRAVEDAD_LUNA * 1.2
	var en_aire := not is_on_floor() and not is_on_ceiling()
	var cayendo := (not gravity_inverted and velocity.y > 0) or (gravity_inverted and velocity.y < 0)
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * SPEED
		anim.flip_h = (direction < 0) != gravity_inverted
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if float_mode or (en_aire and cayendo):
		if anim.animation != "float":
			anim.play("float")
	elif direction != 0:
		if anim.animation != "walk":
			anim.play("walk")
	else:
		if anim.animation != "idle":
			anim.play("idle")
	if float_mode:
		if gravity_inverted and is_on_ceiling():
			float_mode = false
		elif not gravity_inverted and is_on_floor():
			float_mode = false
	contador.text = str(GameState.estrellas_recogidas) + " / 3"
	move_and_slide()
func _hacer_efecto_niebla() -> void:
	niebla.modulate.a = 0.0
	niebla.play("gravity_change_effect")
	var tween := create_tween()
	tween.tween_property(niebla, "modulate:a", 1.0, 0.25)
	tween.tween_callback(_cambiar_fondo)
	tween.tween_property(niebla, "modulate:a", 0.0, 0.25)
func _cambiar_fondo() -> void:
	nave.visible = not gravity_inverted
	nave_morado.visible = gravity_inverted
func morir() -> void:
	GameState.estrellas_recogidas = 0
	get_node("/root/Node2D/Soundtrack").stop()
	sonido_muerte_jugador.play()
	if muriendo:
		return
	muriendo = true
	timer_muerte = 0.0
	get_node("/root/Node2D/efecto-comienzo/Control/muerte").visible = true
	get_node("/root/Node2D/efecto-comienzo").visible = true
	fondo_muerte.visible = true
	texto_muerte.visible = true
	barra_muerte.visible = true
	barra_muerte.size.x = 0.0
