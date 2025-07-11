extends Node
# Base interface for all states: it doesn't do anything by itself,
# but forces us to pass the right arguments to the methods below
# and makes sure every State object had all of these methods.

# warning-ignore:unused_signal
signal finished(next_state_name)


# variable pas du tout flexible donc à changer selon les besoins, réutilisée pour le déplacement ici, sinon jpp agir sur le parent
var player : CharacterBody3D

var speed = 5.0  # ou autre valeur



# Initialize the state. E.g. change the animation.
func enter():
	print("enter run mode")
	#animation


# Clean up the state. Reinitialize values like a timer.
func exit():
	print("exit run mode")


func handle_input(_event):
	pass


func update(_delta):
	#c'est ici pour le mouvement
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_dir = input_dir.normalized()
	
	
	# TOUTE CETTE PARTIE EST POUR LE FLIP DU SPRITE (+vérifie que le sprite existe bien)
	if input_dir.x != 0:
		# Cherche dans l'arbre du personnage, pas forcément direct
		var sprite = player.get_node_or_null("Sprite")
		if sprite == null:
			sprite = player.get_node_or_null("AnimatedSprite3D") # si le nom change à un moment ça devrait pas tout casesr grâce à ça

		if sprite:
			if input_dir.x > 0:
				sprite.scale.x = abs(sprite.scale.x)
			else:
				sprite.scale.x = -abs(sprite.scale.x)
		else:
			print("Sprite node not found on player")
	
	
	# Déplace réellement le joueur + appelle le player (parent) à move and slide (fonction gd)
	player.velocity.x = input_dir.x * speed
	player.move_and_slide()


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("jump"):
		finished.emit("jump")
	else:
		finished.emit("run")


func _on_animation_finished(_anim_name):
	pass
