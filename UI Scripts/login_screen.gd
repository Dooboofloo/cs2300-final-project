extends Control

var regex = RegEx.new()

enum SUBMIT_MODE {MODE_LOGIN = 0, MODE_NEW_USER = 1}

@onready var UsernameText = $LoginContainer/LoginPanel/MarginContainer/LoginVBoxContainer/UsernameTextEdit
@onready var PasswordText = $LoginContainer/LoginPanel/MarginContainer/LoginVBoxContainer/PasswordTextEdit
@onready var ErrorLabel = $LoginContainer/ErrorLabel
@onready var SubmitModeTabContainer = $LoginContainer/LoginModeTabContainer

func _ready():
	# Acceptable characters for username and password
	regex.compile(r'[^a-zA-z0-9_]+') # checks for characters other than a-z, A-Z, 0-9, and '_'

func show_error(s: String) -> void:
	# Show errors relating to login or user creation failure
	ErrorLabel.visible = true
	ErrorLabel.text = s

func _on_submit_button_pressed():
	# Triggers any time the submit button is pressed
	var user = UsernameText.text
	var passw = PasswordText.text
	
	# Error checking text
	if user == "":
		show_error("Username must not be blank!")
		return
	if passw == "":
		show_error("Password must not be blank!")
		return
	
	# Check for invalid characters
	# Only a-z, A-Z, 0-9, and '_' are allowed in usernames and passwords
	if regex.search(user) or regex.search(passw):
		show_error("Only letters, numbers, and '_' are allowed!")
		return
	
	
	# When submit button is pressed, check if user is trying to login or create new
	match(SubmitModeTabContainer.current_tab):
		# Attempt login
		SUBMIT_MODE.MODE_LOGIN:
			var success = Database.login(user, passw)
			
			if success:
				# Success! Change scenes
				get_tree().change_scene_to_file("res://Scenes/search_screen.tscn")
			else:
				# Fail :( show error to user
				show_error("Wrong username or password!")
				return
		
		# Attempt create new user
		SUBMIT_MODE.MODE_NEW_USER:
			var success = Database.register(user, passw)
			
			if success:
				# Success! Login as new user and change scenes
				Database.login(user, passw)
				get_tree().change_scene_to_file("res://Scenes/search_screen.tscn")
			else:
				# Fail :( show error to user
				show_error("User already exists.")
				return
		
		# Default behavior
		_:
			print("Something got messed up...")
