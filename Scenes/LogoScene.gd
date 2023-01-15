extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var soundPlayed = false

# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.
	


func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
	pass # Replace with function body.


func _on_TransitionOpen_transition_done():
	$AnimationPlayer.play("shine")
	if !soundPlayed:
		$AudioStreamPlayer.play()
		soundPlayed = true
	pass # Replace with function body.
