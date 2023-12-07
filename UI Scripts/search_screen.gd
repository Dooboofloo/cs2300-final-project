extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	# Show user who they are
	$UserContainer/HBoxContainer/UserLabel.text = "Current User: " + Database.activeUser
	
	#example of how to parse getCharacters()
	#var chars = Database.getCharacters()
	#var count = chars[0]
	#var data = chars [1]
	#print(count)
	#print(data)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_log_out_button_pressed():
	# Reset active user
	Database.activeUser = ""
	get_tree().change_scene_to_file("res://Scenes/login_screen.tscn")
