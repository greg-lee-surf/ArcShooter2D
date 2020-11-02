extends KinematicBody2D

const VITESSE_DEPLACEMENT_MAX = 500
const ACCELERATION = 10
const FORCE_SAUT = 1000
const GRAVITE = 100
const VITESSE_CHUTE_MAX = 600

var vitesse = 0
var deplacement_y = 0
var facing_right = false

func _physics_process(delta):
	$Label.text = str(global_position.x) + "   " + str(global_position.y)
	var deplacement_x = 0
	if Input.is_action_pressed("ui_right"):
		deplacement_x += 1
		$AnimatedSprite.flip_h = false
	if Input.is_action_pressed("ui_left"):
		deplacement_x -= 1
		$AnimatedSprite.flip_h = true
		
	vitesse = 100
	move_and_slide(Vector2(deplacement_x * VITESSE_DEPLACEMENT_MAX, deplacement_y), Vector2(0, -1))
	

	deplacement_y += GRAVITE
	if is_on_floor() and Input.is_action_just_pressed("ui_select"):
		deplacement_y = -FORCE_SAUT
	if deplacement_y > VITESSE_CHUTE_MAX: #On borne la vitesse de chute
		deplacement_y = VITESSE_CHUTE_MAX


	if is_on_floor():
		if deplacement_x == 0:
			$AnimatedSprite.play("idle")
		else:
			$AnimatedSprite.play("walk")
	else:
#		play_anim("jump")
		pass 
