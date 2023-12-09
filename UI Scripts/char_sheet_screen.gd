extends Control

@onready var delete_button = $SideContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer2/DeleteButton

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

@onready var cHP = $CharContainer/TabBar/Stats/VBoxContainer/Health
@onready var cMaxHP = $CharContainer/TabBar/Stats/VBoxContainer/Health/MaxHP
@onready var cTempHP = $CharContainer/TabBar/Stats/VBoxContainer/Health/TempHP

# NOTE: cHitDiceTotal's text should be NdK where N is the amount and K is the die type (both ints)
@onready var cHitDice = $CharContainer/TabBar/Stats/VBoxContainer/HitDiceDS/HitDice
@onready var cHitDiceTotal = $CharContainer/TabBar/Stats/VBoxContainer/HitDiceDS/HitDiceTotal
@onready var cDSSuccess = $CharContainer/TabBar/Stats/VBoxContainer/HitDiceDS/DSSuccess
@onready var cDSFail = $CharContainer/TabBar/Stats/VBoxContainer/HitDiceDS/DSFail

@onready var cAC = $CharContainer/TabBar/Stats/VBoxContainer/PhysStats/AC
@onready var cInitiative = $CharContainer/TabBar/Stats/VBoxContainer/PhysStats/Initiative
@onready var cSpeed = $CharContainer/TabBar/Stats/VBoxContainer/PhysStats/Speed

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


var delete_button_pressed = 0
func _on_delete_button_pressed():
	match delete_button_pressed:
		0:
			delete_button.text = "Are you sure? (No undo)"
		1:
			delete_button.text = "Click again to delete."
		2:
			Database.deleteChar(Database.currentChar)
			_on_back_button_pressed()
	
	delete_button_pressed += 1
