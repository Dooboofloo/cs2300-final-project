extends PanelContainer

var charDetails

func _ready():
	# Set name text
	$MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/CharName.text = str(charDetails['name'])
	# Set level text
	$MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Level.text = str(charDetails['level'])
	# Set Class text
	$MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Class.text = str(charDetails['class'])
	# Set notes text
	$MarginContainer/HBoxContainer/VBoxContainer/Notes.text = str(charDetails['notes'])

func _on_view_button_pressed():
	print('Switching to character ID: ' + str(charDetails['uuid']))
	Database.currentChar = charDetails['uuid'] # set DB manager's currentChar var
	get_tree().change_scene_to_file('res://Scenes/char_sheet_screen.tscn')
