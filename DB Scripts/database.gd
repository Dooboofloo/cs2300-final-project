extends Node

#global variables
var db 
var db_name = "res://DB Scripts/database"	#path to db
var activeUser = "" #Stores active user for sql queries
var currentChar = 0 #Stores current character uuid

# Called when the node enters the scene tree for the first time.
func _ready():
	db = SQLite.new()	#This creates the database
	db.path = db_name	#This provides the path to the database






#Login Screen Functions
#=============================================
func login(user: String, passW: String): #Runs if user tries to login
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


func register(user: String, passW: String): #Runs if the user hits the register button to register an account
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

func getCharacters(sort = 0, search = ""):#Pulls characters to be displayed based on current sort/search. Returns number of results and results as an array.
	db.open_db()
	# Note, these queries may have to change as currently we cannot cascade delete based on user since they are not connected.
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


func newChar(): #Creates a new blank character linked with the active user. Used for any new characters to be added.
	db.open_db()
	#Upon new character a new uuid will be generated
	
	addCharM(activeUser)#Setting up location in manager for all to reference	
	
	db.query("SELECT MAX(char_id) FROM 'Character Manager'")
	currentChar = db.query_result[0]["MAX(char_id)"] #Setting the current char to the newly created one for getting data post screen change.	
	print(currentChar)
	
	addChar() #creating a new character now to link to new row in Character Manager
	
	#make new row in character manager and character table.
	#CM will take user and Character will take the newly generated uuid.
	#The other tables will have their rows added with the currentChar as the condition put in when they are needed.
	db.close_db()
	
	return #a value can be added here to be returned if needed.



func deleteChar(id):#deletes character based on given uuid. Requires that id.
	db.open_db()
	db.query("DELETE FROM 'Character Manager' WHERE char_id = '" + str(id) + "'") # This is the only line which should be needed to delete a character since CASCADE
	db.close_db()
	
	return
#=========================================================================



#Character Screen Functions
#Note: All these functions will assume the database is open already. They will also not close it.
#	   This is because they are to be used within other functions. Not stand alone. If you want
#	   them to be stand alone, adding open and close db, you must be make sure to open_db() after they run once more.
#	   For all these functions assume string unless otherwise defined.
#=========================================================================

#Fetch Functions
#Here is where you would change the queries to fetch data if PKs change.
#Assume that column used in here is also marked as UNIQUE as it is part of PK.
#================================================================================
func fetchChar(id = currentChar): #Fetch the character table based on uuid
	db.query("SELECT * FROM Character WHERE uuid = '" + str(id) + "'")
	
	return db.query_result


#no real need for a User table fetch or Character manager one as we should already have all the data needed. Unless you wanted to frequently check ownership through it.


func fetchAbilityScore(name, id = currentChar):
	db.query("SELECT * FROM 'Ability Score' WHERE char_id = '" + str(id) + "' AND name = '" + name + "'")
	
	return db.query_result


func fetchBackstory(id = currentChar):
	db.query("SELECT * FROM Backstory WHERE char_id = '" + str(id) + "'")
	
	return db.query_result


func fetchDeathSaves(id = currentChar):
	db.query("SELECT * FROM 'Death Saves' WHERE char_id = '" + str(id) + "'")
	
	return db.query_result


func fetchHitDice(id = currentChar):
	db.query("SELECT * FROM 'Hit Dice' WHERE char_id = '" + str(id) + "'")
	
	return db.query_result


func fetchHitPoints(id = currentChar):
	db.query("SELECT * FROM 'Hit Points' WHERE char_id = '" + str(id) + "'")
	
	return db.query_result


func fetchMoney(id = currentChar):
	db.query("SELECT * FROM Money WHERE char_id = '" + str(id) + "'")
	
	return db.query_result


func fetchPhysicalStats(id = currentChar):
	db.query("SELECT * FROM 'Physical Stats' WHERE char_id = '" + str(id) + "'")
	
	return db.query_result


func fetchSkill(govScore, skillName, id = currentChar):
	db.query("SELECT * FROM Skill WHERE char_id = '" + str(id) + "' AND governing_score = '" + govScore + "' AND skill_name = '" + skillName + "'")
	
	return db.query_result


func fetchSpell(spellName, id = currentChar):
	db.query("SELECT * FROM Spell WHERE char_id = '" + str(id) + "' AND name = '" + spellName + "'")
	
	return db.query_result


func fetchSpellSlot(slotLevel: int, id = currentChar):
	db.query("SELECT * FROM 'Spell Slot' WHERE char_id = '" + str(id) + "' AND slot_level = '" + str(slotLevel) + "'")
	
	return db.query_result


func fetchSpellcasting(id = currentChar):
	db.query("SELECT * FROM Spellcasting WHERE char_id = '" + str(id) + "'")
	
	return db.query_result


func fetchWeapon(wepName, id = currentChar):
	db.query("SELECT * FROM 'Weapon' WHERE owning_char = '" + str(id) + "' AND weapon_name = '" + wepName + "'")
	
	return db.query_result
#=======================================================================================


#Insert Functions
#Here is where you would change base insertion things if NOT NULL conditions change.
#The inserts will fail if the values are also marked as unique. If they are NOT NULL, mainly assume UNIQUE.
#=======================================================================================
func addChar(id = currentChar): #Add a new empty character to the character table linked to a user.
	db.query("INSERT INTO Character(uuid) VALUES('" + str(id) + "')")
	
	return


func addCharM(user = activeUser): #add to Character Manager table. By default connects to active user.
	#Auto increment added a new table. Don't ask me. I could not delete it. Must be to make autoinc work. This also changed the primary key.
	db.query("INSERT INTO 'Character Manager'(user) VALUES('" + user + "')")
	
	return


#This is where the add function would be for user if we even did want it to exist. Only ever used on register so it is in that function.


func addAbilityScore(name, id = currentChar):
	db.query("INSERT INTO 'Ability Score'(char_id, name) VALUES('" + str(id) + "', '" + name + "')")
	
	return


func addBackstory(id = currentChar):
	db.query("INSERT INTO Backstory(char_id) VALUES('" + str(id) + "')")
	
	return


func addDeathSaves(id = currentChar):
	db.query("INSERT INTO 'Death Saves'(char_id) VALUES('" + str(id) + "')")
	
	return


func addHitDice(id = currentChar):
	db.query("INSERT INTO 'Hit Dice'(char_id) VALUES('" + str(id) + "')")
	
	return


func addHitPoints(id = currentChar):
	db.query("INSERT INTO 'Hit Points'(char_id) VALUES('" + str(id) + "')")
	
	return


func addMoney(id = currentChar):
	db.query("INSERT INTO Money(char_id) VALUES('" + str(id) + "')")
	
	return


func addPhysicalStats(id = currentChar):
	db.query("INSERT INTO 'Physical Stats'(char_id) VALUES('" + str(id) + "')")
	
	return


func addSkill(govScore, skillName, id = currentChar):
	db.query("INSERT INTO 'Skill'(char_id, governing_score, skill_name) VALUES('" + str(id) + "', '" + govScore + "', '" + skillName + "')")
	
	return


func addSpell(spellName, id = currentChar):
	db.query("INSERT INTO Spell(char_id, name) VALUES('" + str(id) + "', '" + spellName + "')")
	
	return


func addSpellSlot(slotLevel: int, id = currentChar):
	db.query("INSERT INTO 'Spell Slot'(char_id, slot_level) VALUES('" + str(id) + "', '" + str(slotLevel) + "')")
	
	return


func addSpellcasting(id = currentChar):
	db.query("INSERT INTO Spellcasting(char_id) VALUES('" + str(id) + "')")
	
	return


func addWeapon(wepName, id = currentChar):
	db.query("INSERT INTO Weapon(owning_char, weapon_name) VALUES('" + str(id) + "', '" + wepName + "')")
	
	return
#===================================================================================================


#Update Functions
#Here is where you would edit conditions on which things get updated if FK changes or PK changes.
#===================================================================================================
func updateChar(dict, id = currentChar): #Update the data in the character. dict is a provided dictionary with all changes.
	var tableName = "Character"
	var condition = "uuid = '" + str(id) + "'"
	db.update_rows(tableName, condition, dict) 
	#Turns the given into a sql query based on input data.
	#Simpler than coming up with the long query to update all columns based on input dict.
	
	return


func updateCharM(dict, id = currentChar):
	var tableName = "'Character Manager'"
	var condition = "char_id = '" + str(id) + "'"
	db.update_rows(tableName, condition, dict)
	
	return


func updateUser(dict, username): #Only use would be to change password of a user.
	var tableName = "User"
	var condition = "username = '" + username + "'"
	db.update_rows(tableName, condition, dict)
	
	return


func updateAbilityScore(dict, name, id = currentChar):
	var tableName = "'Ability Score'"
	var condition = "char_id = '" + str(id) + "' AND name = '" + name + "'"
	db.update_rows(tableName, condition, dict)
	
	return


func updateBackstory(dict, id = currentChar):
	var tableName = "Backstory"
	var condition = "char_id = '" + str(id) + "'"
	db.update_rows(tableName, condition, dict)
	
	return


func updateDeathSaves(dict, id = currentChar):
	var tableName = "'Death Saves'"
	var condition = "char_id = '" + str(id) + "'"
	db.update_rows(tableName, condition, dict)
	
	return


func updateHitDice(dict, id = currentChar):
	var tableName = "'Hit Dice'"
	var condition = "char_id = '" + str(id) + "'"
	db.update_rows(tableName, condition, dict)
	
	return


func updateHitPoints(dict, id = currentChar):
	var tableName = "'Hit Points'"
	var condition = "char_id = '" + str(id) + "'"
	db.update_rows(tableName, condition, dict)
	
	return


func updateMoney(dict, id = currentChar):
	var tableName = "Money"
	var condition = "char_id = '" + str(id) + "'"
	db.update_rows(tableName, condition, dict)
	
	return


func updatePhysicalStats(dict, id = currentChar):
	var tableName = "'Physical Stats'"
	var condition = "char_id = '" + str(id) + "'"
	db.update_rows(tableName, condition, dict)
	
	return


func updateSkill(dict, govScore, skillName, id = currentChar):
	var tableName = "Skill"
	var condition = "char_id = '" + str(id) + "' AND governing_score = '" + govScore + "' AND skill_name = '" + skillName + "'"
	db.update_rows(tableName, condition, dict)
	
	return


func updateSpell(dict, spellName, id = currentChar):
	var tableName = "Spell"
	var condition = "char_id = '" + str(id) + "' AND name = '" + spellName + "'"
	db.update_rows(tableName, condition, dict)
	
	return


func updateSpellSlot(dict, slotLevel: int, id = currentChar):
	var tableName = "'Spell Slot'"
	var condition = "char_id = '" + str(id) + "' AND slot_level = '" + str(slotLevel) + "'"
	db.update_rows(tableName, condition, dict)
	
	return


func updateSpellcasting(dict, id = currentChar):
	var tableName = "Spellcasting"
	var condition = "char_id = '" + str(id) + "'"
	db.update_rows(tableName, condition, dict)
	
	return


func updateWeapon(dict, wepName, id = currentChar):
	var tableName = "Weapon"
	var condition = "char_id = '" + str(id) + "' AND weapon_name = '" + wepName + "'"
	db.update_rows(tableName, condition, dict)
	
	return
#===================================================================================================


#Delete Functions
#For all your single delete needs. Just make note of somes cascade effect with others like Ability Score and the higher level tables
#Like with update here is where you would edit conditions on which things get updated if FK changes or PK changes.
#Alot less in here as some make no sense regarding everbeing singularly deleted.
#===================================================================================================
func deleteUser(username):
	db.query("DELETE FROM 'User' WHERE username = '" + username + "'") # This is the only line which should be needed to delete a character since CASCADE
	
	return


func deleteBackstory(id):
	db.query("DELETE FROM 'Backstory' WHERE char_id = '" + str(id) + "'") 
	
	return


func deleteSkill(id, govScore, skillName):
	db.query("DELETE FROM 'Skill' WHERE char_id = '" + str(id) + "' AND governing_score = '" + govScore + "' AND skill_name = '" + skillName + "'") 
	
	return


func deleteSpell(id, spellName):
	db.query("DELETE FROM 'Spell' WHERE char_id = '" + str(id) + "' AND name = '" + spellName + "'") 
	
	return



func deleteSpellSlot(id, slotLevel): #This function could easily be completely useless. Edit PKs if so to fix conditions here.
	db.query("DELETE FROM 'Spell Slot' WHERE char_id = '" + str(id) + "' AND slot_level = '" + str(slotLevel) + "'") 
	
	return



func deleteSpellcasting(id):
	db.query("DELETE FROM 'Spellcasting' WHERE char_id = '" + str(id) + "'") 
	
	return


func deleteWeapon(id, wepName):
	db.query("DELETE FROM 'Weapon' WHERE char_id = '" + str(id) + "' AND weapon_name = '" + wepName + "'") 
	
	return
#===================================================================================================










#Learning Functions
#No real purpose except serving as examples of the sql extension in godot.
#===================================================================================================
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
