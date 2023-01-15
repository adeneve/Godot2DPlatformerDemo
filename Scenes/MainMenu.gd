extends MarginContainer

signal signal_close_scene

const first_scene = "res://Scenes/CharacterSelect.tscn"
const options_page = "res://Scenes/OptionsPage.tscn"
const saved_games_page = "res://Scenes/SaveDataPage.tscn"

var transitionClose = preload("res://Scenes/TransitionClose.tscn")

onready var selector_one = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer/HBoxContainer/Selector
onready var selector_two = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer2/HBoxContainer/Selector
onready var selector_three = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer3/HBoxContainer/Selector
onready var selector_four = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer4/HBoxContainer/Selector

onready var label_newGame = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer/HBoxContainer/NewGame
onready var label_loadGame = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer2/HBoxContainer/LoadGame
onready var label_options = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer3/HBoxContainer/Options
onready var label_exit = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer4/HBoxContainer/Exit

var current_selection = 0

var game_start = false
var start_delay = 0

var max_options_index = 3 if len(Global.saveData) > 0 else 2

func _ready():
	AudioController.playMenu()
	OS.min_window_size = Vector2(600, 350)
	set_current_selection(0)
	if len(Global.saveData) > 0:
		$CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer2.visible = true

func _process(_delta):
			
	if Input.is_action_just_pressed("ui_down") and current_selection < max_options_index:
		current_selection += 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_up") and current_selection > 0:
		current_selection -= 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_accept"):
		handle_selection(current_selection)

func handle_selection(_current_selection):
	if _current_selection == 0:
		prepareNewGame()
	
	if len(Global.saveData) > 0:
		if _current_selection == 1:
			Global.sceneToChangeTo = saved_games_page
		elif _current_selection == 2:
			Global.sceneToChangeTo = options_page
		elif _current_selection == 3:
			get_tree().quit()
		
	else:
		if _current_selection == 1:
			Global.sceneToChangeTo = options_page
		elif _current_selection == 2:
			get_tree().quit()
			
	transition()


func set_current_selection(_current_selection):
	selector_one.text = ""
	selector_two.text = ""
	selector_three.text = ""
	selector_four.text = ""
	
	label_newGame.get_node("RefLine").visible = false
	label_loadGame.get_node("RefLine").visible = false
	label_options.get_node("RefLine").visible = false
	label_exit.get_node("RefLine").visible = false
	
	if len(Global.saveData) > 0:
		if _current_selection == 0:
			selector_one.text = ">"
			label_newGame.get_node("RefLine").visible = true
		elif _current_selection == 1:
			selector_two.text = ">"
			label_loadGame.get_node("RefLine").visible = true
		elif _current_selection == 2:
			selector_three.text = ">"
			label_options.get_node("RefLine").visible = true
		elif _current_selection == 3:
			selector_four.text = ">"
			label_exit.get_node("RefLine").visible = true
	else:
		if _current_selection == 0:
			selector_one.text = ">"
			label_newGame.get_node("RefLine").visible = true
		elif _current_selection == 1:
			selector_three.text = ">"
			label_options.get_node("RefLine").visible = true
		elif _current_selection == 2:
			selector_four.text = ">"
			label_exit.get_node("RefLine").visible = true
		

func _on_NewGame_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		prepareNewGame()
		transition()
		
		
func _on_NewGame_mouse_entered():
	set_current_selection(0)
	current_selection = 0


func _on_LoadGame_mouse_entered():
	set_current_selection(1)
	current_selection = 1


func _on_LoadGame_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		Global.sceneToChangeTo = saved_games_page
		transition()
	
func _on_Options_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		Global.sceneToChangeTo = options_page
		transition()
		
		
func _on_Options_mouse_entered():
	if len(Global.saveData) > 0:
		set_current_selection(2)
		current_selection = 2
	else:
		set_current_selection(1)
		current_selection = 1


func _on_Exit_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		get_tree().quit()
		
func _on_Exit_mouse_entered():
	if len(Global.saveData) > 0:
		set_current_selection(3)
		current_selection = 3
	else:
		set_current_selection(2)
		current_selection = 2


func prepareNewGame():
	Global.sceneToChangeTo = first_scene
	AudioController.stopMenu()
	game_start = true
	
func transition():
	add_child(transitionClose.instance())

	


