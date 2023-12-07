extends PanelContainer

var charDetails

var charId: int

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
	print(charId)
	# Switch scene to character sheet view with Database.currentChar = charId
