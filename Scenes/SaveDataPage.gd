extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const first_scene = "res://Scenes/Levels/IntroLevel.tscn"

const main_menu = "res://Scenes/MainMenu.tscn"

var transitionClose = preload("res://Scenes/TransitionClose.tscn")

var current_selection = 0

var refRectArray = []

var intToMonth = {
	1: "January",
	2: "February",
	3: "March",
	4: "April",
	5: "May",
	6: "June",
	7: "July",
	8: "August",
	9: "September",
	10: "October",
	11: "November",
	12: "December"
}

onready var dynamic_font
# Called when the node enters the scene tree for the first time.
func _ready():
	dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/Onett.ttf")
	dynamic_font.size = 32
	dynamic_font.outline_color = Color("#ffffff")
	dynamic_font.use_filter = true
	
	var i = 0
	print("save d len")
	print(len(Global.saveData))
	for sc in Global.saveData:

		print("hello?")
		print(str(sc.selectedCharacterIndex))
		var centerContainer = CenterContainer.new()
		centerContainer.rect_size.y = 100
		var horizontalContainer = HBoxContainer.new()
		var label = Label.new()  
		var tempName = sc.playerName
		if len(tempName) > 10:
			tempName = tempName.substr(0,9)
			tempName += ".."
		label.text += tempName
		label.text += "\n"
		label.text += intToMonth[sc.lastPlayTime.month] + " " + str(sc.lastPlayTime.day) + " " + str(sc.lastPlayTime.year) 
		label.add_font_override("font", dynamic_font)
		label.rect_min_size.x = 20
		label.rect_min_size.y = 10

		
		
		var textureRect = TextureRect.new()
		if sc.selectedCharacterIndex == 0:
			textureRect.texture = preload("res://spriteSheets/Caleb.png")
		else:
			textureRect.texture = load("res://spriteSheets/PlayerF_64_single.png")
		
		#horizontalContainer.add_child(label_playerName)
		horizontalContainer.add_child(textureRect)
		horizontalContainer.add_child(label)
		var RefRec = ReferenceRect.new()
		RefRec.border_color = Color.green
		if i == 0:
			RefRec.visible = true
		else:
			RefRec.visible = false

		RefRec.editor_only = false
		RefRec.border_width = 5
		RefRec.rect_size.y = 50
		
		horizontalContainer.add_child(RefRec)
				

		centerContainer.add_child(horizontalContainer)
		refRectArray.push_back(RefRec)
		
		horizontalContainer.mouse_filter = Control.MOUSE_FILTER_STOP
		horizontalContainer.process_priority = 100
		horizontalContainer.connect("gui_input", self, "_saveFile_mouseEvent", [i])
		
		$ScrollContainer/VContainer.add_child(centerContainer)
		i += 1
		


func _process(_delta):

	if Input.is_action_just_pressed("ui_down") and current_selection < (len(Global.saveData) - 1):
		refRectArray[current_selection].visible = false
		current_selection += 1
		refRectArray[current_selection].visible = true
	elif Input.is_action_just_pressed("ui_up") and current_selection > 0:
		refRectArray[current_selection].visible = false
		current_selection -= 1
		refRectArray[current_selection].visible = true
	elif Input.is_action_just_pressed("ui_accept"):
		Global.activeSaveContext = Global.saveData[current_selection]
		Global.sceneToChangeTo = first_scene
		Global.activeCharacterIndex = Global.activeSaveContext.selectedCharacterIndex
		add_child(transitionClose.instance())
	elif Input.is_action_just_pressed("pause"):
		Global.sceneToChangeTo = main_menu
		add_child(transitionClose.instance())
		
func _saveFile_mouseEvent(event, index):
	refRectArray[current_selection].visible = false
	current_selection = index
	refRectArray[current_selection].visible = true
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		Global.activeSaveContext = Global.saveData[current_selection]
		Global.sceneToChangeTo = first_scene
		Global.activeCharacterIndex = Global.activeSaveContext.selectedCharacterIndex
		add_child(transitionClose.instance())
	

