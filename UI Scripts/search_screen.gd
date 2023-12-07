extends Control

var sheetblurb = preload("res://Scenes/Instantiable/sheet_blurb.tscn")

@onready var CharList = $CharListContainer/PanelContainer/MarginContainer/ScrollContainer/CharacterList

# Called when the node enters the scene tree for the first time.
func _ready():
	# Show user who they are
	$UserContainer/HBoxContainer/UserLabel.text = "Current User: " + Database.activeUser + ' '
	
	#example of how to parse getCharacters()
	var chars = Database.getCharacters()
	var count = chars[0]
	var data = chars[1]
	print(count)
	print(data)
	
	refresh_list()

func refresh_list(sort_mode = 0, search = ""):
	# Remove all entries in the character list
	for n in CharList.get_children():
		CharList.remove_child(n)
	
	var chars = Database.getCharacters(sort_mode, search)
	var data = chars[1]
	
	for char in data:
		var blurb = sheetblurb.instantiate()
		# blurb.charId = # TODO: Figure out how to give the function the character id here
		# Iain Note: You could use a for loop with data[i]["uuid"] to grab uuid of each row. Then in future use the fetchChar(id) function for its data.
		blurb.charDetails = char
		CharList.add_child(blurb)
		
	
	


func _on_log_out_button_pressed():
	# Reset active user
	Database.activeUser = ""
	get_tree().change_scene_to_file("res://Scenes/login_screen.tscn")


func _on_new_character_button_pressed():
	Database.newChar() # Create new character
	get_tree().change_scene_to_file("res://Scenes/char_sheet_screen.tscn") # go to char sheet screen
