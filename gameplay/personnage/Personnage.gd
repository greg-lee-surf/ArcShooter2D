extends KinematicBody2D


# Les variables pour les déplacements
const VITESSE_MAX :int = 500
const ACCELERATION :int = 50
const FORCE_SAUT :int = 1000
const GRAVITE :int = 50
const VITESSE_CHUTE_MAX :int = 600
var facing_right :bool = false
var deplacement :Vector2 = Vector2.RIGHT
var frottements :bool = true # On enlève les frottements de l'air


# Les variables pour tirer la flèche
onready var FLECHE = preload("res://gameplay/personnage/arc/fleche.tscn")
var vitesse_fleche :int = 5
var mousepos0 : Vector2 # La position de la souris lors du clic
var mousepos1 : Vector2 # Position de la souris lorseque le clic est finit
var can_shoot :bool = true
var rate :float = 1 # La durée entre deux tires


func _ready() -> void:
	# On synchronise les animations
	$BrasArriere._set_playing(true)
	$BrasAvant._set_playing(true)
	$AnimatedBody._set_playing(true)


func _physics_process(delta):
	courrir()
	sauter()
	animer()


func sauter():
	deplacement.y = min(deplacement.y + GRAVITE, VITESSE_CHUTE_MAX)
	if is_on_floor():
		frottements = true
		if Input.is_action_just_pressed("ui_up"):
			deplacement.y = -FORCE_SAUT
	else: 
		frottements = false


func animer():
	if is_on_floor():
		if deplacement.x == 0:
			$AnimatedBody.play("idle")
		else:
			$AnimatedBody.play("marche")
	else:
#		play_anim("jump")
		pass 


func courrir():
	if Input.is_action_pressed("ui_right"):
		deplacement.x = min(deplacement.x + ACCELERATION, VITESSE_MAX)
		$AnimatedBody.flip_h = false
		$BrasArriere.play("gauche_arc")
		$BrasAvant.play("droit_ballant")
		placement_bras(true) # Le personnage est tourné vers la droite
	elif Input.is_action_pressed("ui_left"):
		deplacement.x = max(deplacement.x - ACCELERATION, -VITESSE_MAX)
		$AnimatedBody.flip_h = true
		$BrasArriere.play("droit_ballant")
		$BrasAvant.play("gauche_arc")
		placement_bras(false)
	elif frottements:
		deplacement.x = lerp(deplacement.x, 0, 0.5)
	deplacement = move_and_slide(Vector2(deplacement.x, deplacement.y), Vector2(0, -1))


func _input(event):
	if event is InputEventMouseButton and can_shoot:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			mousepos0 = get_viewport().get_mouse_position()
		if event.button_index == BUTTON_LEFT and !event.pressed:
			mousepos1 = get_viewport().get_mouse_position()
			var fleche = FLECHE.instance()
			get_parent().add_child(fleche)
			tire_fleche(fleche)

func tire_fleche(fleche : RigidBody2D) -> void:
	fleche.global_position = $Arc/Position2D.global_position
	fleche.set_linear_velocity((mousepos0 - mousepos1) * vitesse_fleche)
	can_shoot = false
	$ShootingRate.start(rate)


func _on_ShootingRate_timeout():
	can_shoot = true

func placement_bras(regarde_droite : bool) -> void:
	if regarde_droite:
		$BrasArriere.set_offset(Vector2(-6, 0)) # On colle les bras au corps
		$BrasAvant.set_offset(Vector2(-6, 0))
	else:
		$BrasArriere.set_offset(Vector2(6, 0))
		$BrasAvant.set_offset(Vector2(6, 0))
