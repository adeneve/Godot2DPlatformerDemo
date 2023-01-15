extends Popup

#const first_scene = preload("res://World.tscn")

onready var selector_one = $CenterContainer/vboxContainer/CenterContainer/HBoxContainer/Selector
onready var selector_two = $CenterContainer/vboxContainer/CenterContainer2/HBoxContainer/Selector
onready var selector_three = $CenterContainer/vboxContainer/CenterContainer3/HBoxContainer/Selector

var transitionClose = preload("res://Scenes/TransitionClose.tscn")

var first_scene = "res://Scenes/MainMenu.tscn"

var current_selection = 0

var saveLabelResetDelay = 5
var saveLabelResetTimer = 0

func _ready():
	set_current_selection(0)

func _process(_delta):
	if !get_parent().get_node("Player").game_paused:
		return
	rect_position.x = get_parent().get_node("Player").position.x - 100
	rect_position.y = get_parent().get_node("Player").position.y - 160
	if Input.is_action_just_pressed("ui_down") and current_selection < 2:
		current_selection += 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_up") and current_selection > 0:
		current_selection -= 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_accept"):
		handle_selection(current_selection)
		
	saveLabelResetTimer += _delta 
	if saveLabelResetTimer > saveLabelResetDelay:
		$SaveLabel.visible = false

func handle_selection(_current_selection):
	if _current_selection == 0:
		get_tree().paused = 0
		get_parent().get_node("Player").game_paused = 0
		self.hide()
	elif _current_selection == 1:
		#save game
		Global.write_save_file()
		$SaveLabel.visible = true
		saveLabelResetTimer = 0
	elif _current_selection == 2:
		get_tree().paused = 0
		Global.sceneToChangeTo = first_scene
		add_child(transitionClose.instance())

func set_current_selection(_current_selection):
	selector_one.text = ""
	selector_two.text = ""
	selector_three.text = ""
	if _current_selection == 0:
		selector_one.text = ">"
	elif _current_selection == 1:
		selector_two.text = ">"
	elif _current_selection == 2:
		selector_three.text = ">"
