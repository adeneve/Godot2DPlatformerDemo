extends CanvasLayer


signal transition_done


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("OpenScene")
	layer = 1


func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("transition_done")
	queue_free()

