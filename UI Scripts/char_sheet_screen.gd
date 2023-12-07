extends Control

func _ready():
	$Label.text = str(Database.currentChar)
