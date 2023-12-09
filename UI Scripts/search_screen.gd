extends Control

var sheetblurb = preload("res://Scenes/Instantiable/sheet_blurb.tscn")

@onready var CharList = $CharListContainer/PanelContainer/MarginContainer/ScrollContainer/CharacterList
@onready var keyword = $"SideContainer/Panel/MarginContainer/Sort Types/SearchBar/KeywordLineEdit"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Show user who they are
	$UserContainer/HBoxContainer/UserLabel.text = " Current User: " + Database.activeUser + ' '
	
	#example of how to parse getCharacters()
	var chars = Database.getCharacters()
	var count = chars[0]
	var data = chars[1]
	print(count)
	print(data)
	
	refresh_list()

func refresh_list(sort_mode = 0, search = ""):
	# Remove all entries in the current character list
	for n in CharList.get_children():
		CharList.remove_child(n)
	
	# Fill it with newly sorted / gathered entries
	search = search.replace("'", '')
	var chars = Database.getCharacters(sort_mode, search)
	var data = chars[1]
	
	for chr in data:
		var blurb = sheetblurb.instantiate()
		blurb.charDetails = chr
		CharList.add_child(blurb)


func _on_log_out_button_pressed():
	# Reset active user
	Database.activeUser = ""
	get_tree().change_scene_to_file("res://Scenes/login_screen.tscn")


func _on_new_character_button_pressed():
	Database.newChar() # Create new character
	get_tree().change_scene_to_file("res://Scenes/char_sheet_screen.tscn") # go to char sheet screen


func _on_sort_default_button_pressed():
	refresh_list()


func _on_sort_level_button_pressed():
	refresh_list(1)


func _on_sort_name_button_pressed():
	refresh_list(2)


func _on_sort_class_button_pressed():
	refresh_list(3)


func _on_sort_keyword_button_pressed():
	refresh_list(4, keyword.text)


func _on_reverse_search_button_pressed():
	# Reverse search order
	var tmp = CharList.get_children()
	tmp.reverse()
	
	for n in CharList.get_children():
		CharList.remove_child(n)
	
	for n in tmp:
		CharList.add_child(n)
