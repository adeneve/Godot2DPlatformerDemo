extends PanelContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	rect_position.x = get_parent().get_parent().get_node("Player").position.x - 160
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

