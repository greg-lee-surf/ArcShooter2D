extends KinematicBody2D

enum {
	INACTIF,
	NOUVELLE_DIRECTION,
	MOUVEMENT,
	ATTAQUE
}

const ZONE_DETECTION = 300 # Un rayon de 400 pixels
const ANGLE_VISION = PI / 2 # Vision de l'ennemi
const ACCELERATION = 30

var pv = 3 # points de vie
var vitesse = 50
var vitesse_max = 200
var etat = INACTIF
var liste_directions = [
		Vector2(1,0), 
		Vector2(1, 1).normalized(),
		Vector2(0,1), 
		Vector2(-1,1).normalized(), 
		Vector2(-1, 0), 
		Vector2(-1, -1).normalized(), 
		Vector2(0, -1),
		Vector2(1, -1).normalized()
]
var direction = Vector2(1, 0)

onready var taille_ecran = get_viewport_rect().size
onready var joueur = get_parent().get_node("Personnage")
onready var position_joueur


func _ready():
	randomize() #Pour que la machine à etat soit différente à chaque appel


func _physics_process(delta):
	
	position_joueur = joueur.global_position
	detecte_joueur(position_joueur - global_position)
	
	match etat:
		INACTIF:
			pass
		
		NOUVELLE_DIRECTION:
			direction = choix(liste_directions)
			etat = choix([INACTIF, MOUVEMENT])
			vitesse = 0
			
		MOUVEMENT:
			move(vitesse_max)
			vitesse_max = 200

		ATTAQUE:
			move(vitesse_max)
			$Label.text = "À l'attaque !!!"


func move(vitesse_max):
	vitesse = min(vitesse + ACCELERATION, vitesse_max)
	move_and_slide(direction * vitesse, Vector2(0, -1))
	position.x = clamp(position.x, 64, taille_ecran.x - 64)
	position.y = clamp(position.y, 64, taille_ecran.y - 64)
	if direction.x > 0:
		$AnimatedSprite.flip_h = true
	elif direction.x < 0:
		$AnimatedSprite.flip_h = false

func choix(liste):
	"""Permet de choisir aleatoirement un élément dans une liste"""
	return liste[randi()%liste.size()]


func _on_Timer_timeout():
	$Timer.wait_time = choix([0.1, 0.2, 0.3])
	etat = NOUVELLE_DIRECTION
	vitesse_max = 150 # on revient à la vitesse de déplacement

func detecte_joueur(distance):
	"""Permet la detection puis déclenche l'attaque si le joueur est détecté"""
	if distance.length() < ZONE_DETECTION :
		$Label.set_text(str(direction.angle_to(distance)))
		if direction.angle_to(distance) < ANGLE_VISION:
			$RayCast2D.set_cast_to(distance)
			$Label.set_text(str($RayCast2D.get_collider()))
			if $RayCast2D.is_colliding() and $RayCast2D.get_collider().name == "Personnage" and $TimerAttack.get_time_left() > 3:
				etat = ATTAQUE
				direction = $RayCast2D.get_cast_to().normalized()
				vitesse_max = 400
	else:
		$Label.set_text("Je ne te vois pas !")


func _on_TimerAttack_timeout():
	"""Quand le timer s'arrête, l'attaque peut reprendre"""
	$TimerAttack.set_wait_time(4)


func _on_Area2D_body_entered(body):
	if "fleche" in body.name:
		$AfficheDegat.text = "10 dégats"
		pv -= 1
		if pv == 0:
			queue_free()
