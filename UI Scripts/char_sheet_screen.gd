extends Control

const CLASS_TO_ID = {
	'Artificer': 0,
	'Barbarian': 1,
	'Bard': 2,
	'Cleric': 3,
	'Druid': 4,
	'Fighter': 5,
	'Monk': 6,
	'Paladin': 7,
	'Ranger': 8,
	'Rogue': 9,
	'Sorcerer': 10,
	'Warlock': 11,
	'Wizard': 12
}

@onready var cName = $SideContainer/Panel/MarginContainer/VBoxContainer/Name
@onready var cLevel = $SideContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/Level
@onready var cClass = $SideContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/Class
@onready var cNotes = $SideContainer/Panel/MarginContainer/VBoxContainer/Notes

func _ready():
	print("Loaded character: " + str(Database.currentChar))
	load_char_data()

func load_char_data():
	Database.db.open_db()
	var Char = Database.fetchChar()[0]
	Database.db.close_db()
	
	print(Char)
	
	cName.text = str(Char['name'])
	cLevel.value = Char['level']
	cClass.selected = CLASS_TO_ID[Char['class']]
	cNotes.text = Char['notes']


func _on_back_button_pressed():
	Database.currentChar = 0 # Reset database current char
	get_tree().change_scene_to_file("res://Scenes/search_screen.tscn")


func _on_save_button_pressed():
	# Commit changes to the DB
	var updateDict = Dictionary()
	updateDict['name'] = cName.text
	updateDict['level'] = cLevel.value
	updateDict['class'] = CLASS_TO_ID.keys()[cClass.selected]
	updateDict['notes'] = cNotes.text
	
	Database.db.open_db()
	Database.updateChar(updateDict)
	Database.db.close_db()
