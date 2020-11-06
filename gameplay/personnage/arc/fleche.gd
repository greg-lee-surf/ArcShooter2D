extends RigidBody2D


var angle_fleche = 0 # Pour bien orienter la flèche lors du tir
onready var pos_x = position.x + 1 # La position de x à la frame précédente
onready var pos_y = position.y
var delta_x # Déplacement de la flèche suivant l'axe des x
var delta_y


func _physics_process(delta):
	delta_x = position.x - pos_x if position.x - pos_x != 0 else 1 # On évite la division par 0
	delta_y = position.y - pos_y
	angle_fleche = atan(delta_y/delta_x)
	rotate(angle_fleche)
	pos_x = position.x
	pos_y = position.y
	

func _on_Timer_timeout():
	queue_free()
