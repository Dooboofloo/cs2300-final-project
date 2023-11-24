extends Node

#global variables
var db 
var db_name = "res://DB Scripts/database"	#path to db


# Called when the node enters the scene tree for the first time.
func _ready():
	db = SQLite.new()	#This creates the database
	db.path = db_name	#This provides the path to the database
	commitDataToDB()
	readFromDB()



func commitDataToDB():
	db.open_db()	#opening the database
	var tableName = "Character"      #name of the table within the database we want
	var dict : Dictionary = Dictionary()	#One way of inserting a new entry into database
	dict["name"] = "this is a test user"	#specify column then what you want in the column
	dict["level"] = 89
	db.insert_row(tableName, dict)	#takes the table we want then the dict which hold our edit.
	#OR
	db.query("insert into Character(name) VALUES('Godfried')")	#do it through query, any string must be denoted with ''
	db.close_db()	#Make sure to close after function runs


func readFromDB():
	db.open_db()
	var tableName = "Character"
	db.query("SELECT * FROM " + tableName)	#creating our resulting table for our query
	print(db.query_result.size())	#printing size of table we have made using query.
	for i in range(0, db.query_result.size()):	#This should work, with this we can grab a certain attribute from all in table.
		print("Query results ", db.query_result[i]["name"])	#always must define key of dictionary.
		#We could try and do this with db.get_query_result but that provides us with a list of dicts.
		#So we have to use a for loop to only get the one thing we wish to print.
	db.close_db()	#Make sure to close after function runs


func removeDataFromDB():
	db.open_db()
	var tableName = "Character"
	db.delete_rows("Character", "name = 'Godfried'") #Example on how we can delete rows. Don't forget the '' for text!
	#OR
	db.query("DELETE FROM " + tableName + "WHERE name = 'Godfried'")	#example on how to delete through query.
	db.close_db()
