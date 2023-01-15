extends Button

var key
var value
var menu

var waiting_input = false

func _ready():
	pass # Replace with function body.

func _input(event):
	if waiting_input:
		if event is InputEventKey:
			if !menu.change_bind(key, event.scancode):
				value = event.scancode
			text = OS.get_scancode_string(value)
			pressed = false
			waiting_input = false
		if event is InputEventMouseButton:
			text = OS.get_scancode_string(value)
			pressed = false
			waiting_input = false
	
func _toggled(button_pressed):
	if button_pressed:
		waiting_input = true
		set_text("Press Any Key")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
