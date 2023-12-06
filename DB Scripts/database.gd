extends Node

#global variables
var db 
var db_name = "res://DB Scripts/database"	#path to db
var activeUser = "Bill" #Stores active user for sql queries
var currentChar = 0 #Stores current character uuid

# Called when the node enters the scene tree for the first time.
func _ready():
	db = SQLite.new()	#This creates the database
	db.path = db_name	#This provides the path to the database
	var intermission = getCharacters(4, "pity")
	var count = intermission[0]
	var data = intermission [1]
	print(count)
	print(data)


#Login Screen Functions
#=============================================
func login(user: String, passW: String):
	db.open_db()
	var tableName = "User"
	db.query("SELECT COUNT(1) FROM " + tableName + " WHERE username = '" + user + "' AND password = '" + passW + "'") #Finding if any matches exist
	var exist = db.query_result[0]["COUNT(1)"]
	db.close_db()
	
	if(bool(exist) == true):
		activeUser = user #Setting the global variable to the now active user
		return true #successful login
	else:
		print("Wrong username or password.") #Replace with some UI message
		return false #failure to login


func register(user: String, passW: String):
	db.open_db()
	var tableName = "User"
	db.query("SELECT COUNT(1) FROM " + tableName + " WHERE username = '" + user + "'") #Finding if any matches exist
	var exist = db.query_result[0]["COUNT(1)"]
	db.close_db()
	
	if(bool(exist) == true):
		print("User already exists.") #Replace with some UI message
		return false #user or pass exists in registry
	else:
		#add user to registry.
		var dict : Dictionary = Dictionary()
		dict["username"] = user
		dict["password"] = passW
		db.insert_row(tableName, dict)
		return true

#We could add a function to change password. Doing so would just need user and then an UPDATE query.
#============================================================



#Main Screen Functions
#============================================================
#Pulls characters to be displayed based on current sort/search.
#Returns number of results and results as an array.
func getCharacters(sort = 0, search = ""):
	db.open_db()
	
	db.query("SELECT COUNT(C.uuid) FROM Character C WHERE EXISTS
			(SELECT * FROM 'Character Manager' M WHERE '" + activeUser + "' = M.user AND M.char_id = C.uuid)")
	var resultAmount = db.query_result[0]["COUNT(C.uuid)"] #Done out here as always constant except after search sort
	
	match sort:
		0: #Default no sort
			db.query("SELECT C.name, C.level, C.class, C.notes FROM Character C WHERE EXISTS
					(SELECT * FROM 'Character Manager' M WHERE '" + activeUser + "' = M.user AND M.char_id = C.uuid)")
			db.close_db()
			
			return [resultAmount, db.query_result]
		
		1: #Sort by level
			db.query("SELECT C.name, C.level, C.class, C.notes FROM Character C WHERE EXISTS
					(SELECT * FROM 'Character Manager' M WHERE '" + activeUser + "' = M.user AND M.char_id = C.uuid )
					ORDER BY C.level DESC")
			db.close_db()
			
			return [resultAmount, db.query_result]
			
		2: #Sort by name
			db.query("SELECT C.name, C.level, C.class, C.notes FROM Character C WHERE EXISTS
					(SELECT * FROM 'Character Manager' M WHERE '" + activeUser + "' = M.user AND M.char_id = C.uuid )
					ORDER BY C.name")
			db.close_db()
			
			return [resultAmount, db.query_result]
			
		3: #Sort by class
			db.query("SELECT C.name, C.level, C.class, C.notes FROM Character C WHERE EXISTS
					(SELECT * FROM 'Character Manager' M WHERE '" + activeUser + "' = M.user AND M.char_id = C.uuid )
					ORDER BY C.class")
			db.close_db()
			
			return [resultAmount, db.query_result]
			
		4: #Search sorting. Searching for % only will cause all to pop up as it makes it a wild card.
			db.query("SELECT COUNT(C.uuid) FROM Character C WHERE EXISTS
					(SELECT * FROM 'Character Manager' M WHERE '" + activeUser + "' = M.user AND M.char_id = C.uuid AND C.notes LIKE '%" + search + "%')")
			resultAmount = db.query_result[0]["COUNT(C.uuid)"]
			
			db.query("SELECT C.name, C.level, C.class, C.notes FROM Character C WHERE EXISTS
					(SELECT * FROM 'Character Manager' M WHERE '" + activeUser + "' = M.user AND M.char_id = C.uuid AND C.notes LIKE '%" + search + "%')")
			db.close_db()
			
			return [resultAmount, db.query_result]
			
		_: #Any other number
			print("Invalid sort procedure.") #some sort of pop up warning if they somehow do this
			return [0,0]


func newChar(): #Creates a new blank character linked with the active user.
	db.open_db()
	var dict : Dictionary = Dictionary()
	#Since all char_id are set as unique we can just create the rows and they will auto link unless the user edits the database outside.
	#So NO TOUCHY DATABASE OUTSIDE OF APPLICATION!!!!
	db.insert_row("Character", dict) 
	db.insert_row("'Ability Score'", dict) 
	db.insert_row("Backstory", dict) 
	db.insert_row("'Death Saves'", dict) 
	db.insert_row("'Hit Dice'", dict) 
	db.insert_row("'Hit Points'", dict) 
	db.insert_row("Money", dict) 
	db.insert_row("'Physical Stats", dict) 
	db.insert_row("Skill", dict) 
	db.insert_row("Spell", dict)
	db.insert_row("'Spell Slot'", dict)  
	db.insert_row("Spellcasting", dict) 
	db.insert_row("Weapon", dict) 
	
	dict["user"] = activeUser
	db.insert_row("'Character Manager'", dict) #Only thing which we actually need a value for.
	
	db.query("SELECT MAX(uuid) FROM Character")
	currentChar = db.query_result[0]["MAX(uuid)"] #Setting the current char to the newly created one for getting data post screen change.
	
	db.close_db()
	
	return fetchChar() #can be changed to any return which is actually needed.

func delChar(id):#deletes character based on given uuid
	db.open_db()
	
	db.query("DELETE FROM Character WHERE uuid = " + id) # This is the only line which should be needed if all foreign keys are CASCADE on delete.

	db.close_db()
	
	return


func fetchChar(id = currentChar): #Fetch the character table based on uuid
	db.open_db()
	db.query("SELECT * FROM Character WHERE uuid = " + id)
	db.close_db()
	
	return db.query_result
	
# need to make functions that fetch each specific table only for easy data access


#=========================================================================



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
