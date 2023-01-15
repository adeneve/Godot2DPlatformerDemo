extends Resource
class_name SaveContext


export var playerName : String

export var selectedCharacterIndex : int

export var lastPlayTime : Dictionary

export var iceBoss_defeated : bool


func setPlayerName(name):
	playerName = name
	
func setCharacter(index):
	selectedCharacterIndex = index
	
func setlastPlayTime(time):
	lastPlayTime = time
