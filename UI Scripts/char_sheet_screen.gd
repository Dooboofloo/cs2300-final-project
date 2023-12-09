extends Control

var weaponBlurb = preload("res://Scenes/Instantiable/weapon_blurb.tscn")
var spellBlurb = preload("res://Scenes/Instantiable/spell_blurb.tscn")

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

const CLASS_HD = {
	'Artificer': 8,
	'Barbarian': 12,
	'Bard': 8,
	'Cleric': 8,
	'Druid': 8,
	'Fighter': 10,
	'Monk': 8,
	'Paladin': 10,
	'Ranger': 10,
	'Rogue': 8,
	'Sorcerer': 6,
	'Warlock': 8,
	'Wizard': 6
}

const SC_ABILITIES = ['Intelligence', 'Wisdom', 'Charisma']

@onready var cName = $SideContainer/Panel/MarginContainer/VBoxContainer/Name
@onready var cLevel = $SideContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/Level
@onready var cClass = $SideContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/Class
@onready var cNotes = $SideContainer/Panel/MarginContainer/VBoxContainer/Notes
@onready var cPB = $CharContainer/TabBar/Info/VBoxContainer/PhysStats/PBPanel/PB

@onready var cHP = $CharContainer/TabBar/Info/VBoxContainer/Health/Health
@onready var cMaxHP = $CharContainer/TabBar/Info/VBoxContainer/Health/MaxHP
@onready var cTempHP = $CharContainer/TabBar/Info/VBoxContainer/Health/TempHP

@onready var cHitDice = $CharContainer/TabBar/Info/VBoxContainer/HitDiceDS/HitDice
@onready var cHitDiceTotal = $CharContainer/TabBar/Info/VBoxContainer/HitDiceDS/HitDiceTotalPanel/HitDiceTotal
@onready var cDSSuccess = $CharContainer/TabBar/Info/VBoxContainer/HitDiceDS/DSSuccess
@onready var cDSFail = $CharContainer/TabBar/Info/VBoxContainer/HitDiceDS/DSFail

@onready var cAC = $CharContainer/TabBar/Info/VBoxContainer/PhysStats/AC
@onready var cInitiative = $CharContainer/TabBar/Info/VBoxContainer/PhysStats/Initiative
@onready var cSpeed = $CharContainer/TabBar/Info/VBoxContainer/PhysStats/Speed

@onready var cAS = {
	'Strength': $CharContainer/TabBar/Stats/AbilityScores/VBoxContainer/Str/AspectRatioContainer/StrScore,
	'Dexterity': $CharContainer/TabBar/Stats/AbilityScores/VBoxContainer/Dex/AspectRatioContainer/DexScore,
	'Constitution': $CharContainer/TabBar/Stats/AbilityScores/VBoxContainer/Con/AspectRatioContainer/ConScore,
	'Intelligence': $CharContainer/TabBar/Stats/AbilityScores/VBoxContainer2/Int/AspectRatioContainer/IntScore,
	'Wisdom': $CharContainer/TabBar/Stats/AbilityScores/VBoxContainer2/Wis/AspectRatioContainer/WisScore,
	'Charisma': $CharContainer/TabBar/Stats/AbilityScores/VBoxContainer2/Cha/AspectRatioContainer/ChaScore
}
var cASMods = {
	'Strength': 0,
	'Dexterity': 0,
	'Constitution': 0,
	'Intelligence': 0,
	'Wisdom': 0,
	'Charisma': 0
}
@onready var cASModLabels = {
	'Strength': $CharContainer/TabBar/Stats/AbilityScores/VBoxContainer/StrLabel,
	'Dexterity': $CharContainer/TabBar/Stats/AbilityScores/VBoxContainer/DexLabel,
	'Constitution': $CharContainer/TabBar/Stats/AbilityScores/VBoxContainer/ConLabel,
	'Intelligence': $CharContainer/TabBar/Stats/AbilityScores/VBoxContainer2/IntLabel,
	'Wisdom': $CharContainer/TabBar/Stats/AbilityScores/VBoxContainer2/WisLabel,
	'Charisma': $CharContainer/TabBar/Stats/AbilityScores/VBoxContainer2/ChaLabel
}
var cSkills = {}

@onready var cRace = $CharContainer/TabBar/Info/VBoxContainer/Backstory/Race
@onready var cBackground = $CharContainer/TabBar/Info/VBoxContainer/Backstory/Background
@onready var cAlignment = $CharContainer/TabBar/Info/VBoxContainer/Backstory/Alignment

@onready var cEquipment = $CharContainer/TabBar/Info/VBoxContainer/Equipment

@onready var cCP = $CharContainer/TabBar/Inventory/HBoxContainer/VBoxContainer/Money/CP
@onready var cSP = $CharContainer/TabBar/Inventory/HBoxContainer/VBoxContainer/Money/SP
@onready var cEP = $CharContainer/TabBar/Inventory/HBoxContainer/VBoxContainer/Money/EP
@onready var cGP = $CharContainer/TabBar/Inventory/HBoxContainer/VBoxContainer/Money/GP
@onready var cPP = $CharContainer/TabBar/Inventory/HBoxContainer/VBoxContainer/Money/PP

@onready var weaponsNode = $CharContainer/TabBar/Inventory/HBoxContainer/VBoxContainer2/WeaponsScrollBox/Weapons
@onready var spellsNode = $CharContainer/TabBar/Spellcasting/VBoxContainer/HBoxContainer/VBoxContainer2/WeaponsScrollBox/Spells

@onready var cSpellAbility = $CharContainer/TabBar/Spellcasting/VBoxContainer/Spellcasting/SpellcastingAbility
@onready var cSpellDC = $CharContainer/TabBar/Spellcasting/VBoxContainer/Spellcasting/SaveDCPanel/SaveDC
@onready var cSpellAttack = $CharContainer/TabBar/Spellcasting/VBoxContainer/Spellcasting/AtkBonusPanel/AtkBonus

func _ready():
	print("Loaded character: " + str(Database.currentChar))
	load_char_data()
	refresh_weapons()
	refresh_spell_list()

func _input(_event):
	if Input.is_action_just_pressed("save"):
		_on_save_button_pressed()

func load_char_data():
	Database.db.open_db()
	# Fetch Character
	var Char = Database.fetchChar()[0]
	
	# Fetch Ability Scores
	var AbilityScores = Dictionary()
	for i in Database.ABILITY_SCORES.keys():
		AbilityScores[i] = Database.fetchAbilityScore(i)[0]
	
	# Fetch Skills
	var Skills = Database.fetchSkills()
	
	# Fetch Others
	var Backstory = Database.fetchBackstory()[0]
	var DeathSaves = Database.fetchDeathSaves()[0]
	var HitDice = Database.fetchHitDice()[0]
	var HitPoints = Database.fetchHitPoints()[0]
	var Money = Database.fetchMoney()[0]
	var PhysicalStats = Database.fetchPhysicalStats()[0]
	
	var Spellcasting = Database.fetchSpellcasting()[0]
	
	# Spell Slots
	for i in range (1, 10):
		var slot = Database.fetchSpellSlot(i)[0]
		get_node("CharContainer/TabBar/Spellcasting/VBoxContainer/HBoxContainer/SpellSlots/SpellSlots%s/Expended" % str(i)).value = slot['num_expended']
		get_node("CharContainer/TabBar/Spellcasting/VBoxContainer/HBoxContainer/SpellSlots/SpellSlots%s/Total" % str(i)).value = slot['total']
	
	Database.db.close_db()
	
	#print(Char)
	#print(Backstory)
	#print(DeathSaves)
	#print(HitDice)
	#print(HitPoints)
	#print(Money)
	#print(PhysicalStats)
	
	# Character
	cName.text = Char['name']
	cLevel.value = int(Char['level'])
	cClass.selected = int(CLASS_TO_ID[str(Char['class'])])
	cPB.text = '+' + str(Char['prof_bonus'])
	cEquipment.text = str(Char['equipment'])
	cNotes.text = str(Char['notes'])
	
	# HP
	cHP.value = int(HitPoints['current'])
	cMaxHP.value = int(HitPoints['max'])
	cTempHP.value = int(HitPoints['temp'])
	
	# Hit Dice and Death Saves
	cHitDice.value = int(HitDice['num_used'])
	cHitDiceTotal.text = str(HitDice['total']) + 'd' + str(HitDice['type'])
	cDSSuccess.value = int(DeathSaves['num_success'])
	cDSFail.value = int(DeathSaves['num_fail'])
	
	# Physical Stats
	cAC.value = int(PhysicalStats['armor_class'])
	cInitiative.value = int(PhysicalStats['initiative'])
	cSpeed.value = int(PhysicalStats['speed'])
	
	# Skills
	for skill in Skills:
		cSkills[skill['skill_name']] = skill
		var skillNode = find_child(skill['skill_name'])
		skillNode.button_pressed = bool(skill['proficiency_mult'])
		calculate_bonus(skill, skillNode)
	
	# Ability Scores
	for scoreName in cAS.keys():
		cAS[scoreName].value = int(AbilityScores[scoreName]['score'])
		cASMods[scoreName] = int(AbilityScores[scoreName]['modifier'])
		calculate_modifier(scoreName, cAS[scoreName].value)
	
	# Backstory
	cRace.text = str(Backstory['race'])
	cBackground.text = str(Backstory['background'])
	cAlignment.text = str(Backstory['alignment'])
	
	# Money
	cCP.value = int(Money['cp'])
	cSP.value = int(Money['sp'])
	cEP.value = int(Money['ep'])
	cGP.value = int(Money['gp'])
	cPP.value = int(Money['pp'])
	
	if Spellcasting['ability_score'] != null:
		refresh_spell_stuff(Spellcasting['ability_score'])

func _on_back_button_pressed():
	Database.currentChar = 0 # Reset database current char
	get_tree().change_scene_to_file("res://Scenes/search_screen.tscn")

func _on_save_button_pressed():
	# Commit changes to the DB
	
	# Character Update
	var charDict = {}
	charDict['name'] = cName.text
	charDict['level'] = cLevel.value
	charDict['class'] = CLASS_TO_ID.keys()[cClass.selected]
	charDict['prof_bonus'] = int(cPB.text)
	charDict['equipment'] = cEquipment.text
	charDict['notes'] = cNotes.text
	
	var hpDict = {}
	hpDict['current'] = cHP.value
	hpDict['max'] = cMaxHP.value
	hpDict['temp'] = cTempHP.value
	
	var hdDict = {}
	hdDict['num_used'] = cHitDice.value
	var split = cHitDiceTotal.text.split('d')
	hdDict['total'] = int(split[0])
	hdDict['type'] = int(split[1])
	
	var dsDict = {}
	dsDict['num_success'] = int(cDSSuccess.value)
	dsDict['num_fail'] = int(cDSFail.value)
	
	var physDict = {}
	physDict['armor_class'] = cAC.value
	physDict['initiative'] = cInitiative.value
	physDict['speed'] = cSpeed.value
	
	var bsDict = {}
	bsDict['race'] = str(cRace.text)
	bsDict['background'] = str(cBackground.text)
	bsDict['alignment'] = str(cAlignment.text)
	
	var moneyDict = {}
	moneyDict['cp'] = int(cCP.value)
	moneyDict['sp'] = int(cSP.value)
	moneyDict['ep'] = int(cEP.value)
	moneyDict['gp'] = int(cGP.value)
	moneyDict['pp'] = int(cPP.value)
	
	var scDict = {}
	scDict['ability_score'] = SC_ABILITIES[cSpellAbility.selected]
	scDict['save_dc'] = int(cSpellDC.text)
	scDict['atk_bonus'] = int(cSpellAttack.text.substr(1, -1))
	
	Database.db.open_db()
	Database.updateChar(charDict)
	Database.updateHitPoints(hpDict)
	Database.updateHitDice(hdDict)
	Database.updateDeathSaves(dsDict)
	Database.updatePhysicalStats(physDict)
	Database.updateBackstory(bsDict)
	Database.updateMoney(moneyDict)
	print(scDict)
	Database.updateSpellcasting(scDict)
	
	# Ability scores
	for scoreName in cAS.keys():
		var asDict = {}
		asDict['score'] = cAS[scoreName].value
		asDict['modifier'] = cASMods[scoreName]
		Database.updateAbilityScore(asDict, scoreName)
	
	# Skills
	for skill in Database.fetchSkills():
		var skillNode = find_child(skill['skill_name'])
		
		var skillDict = {}
		skillDict['proficiency_mult'] = int(skillNode.button_pressed)
		#skillDict['bonus'] = int(something) #TODO
		
		Database.updateSkill(skillDict, skill['skill_name'])
	
	# Weapons
	for w in weaponsNode.get_children():
		var wpnDict = w.get_values()
		Database.updateWeapon(wpnDict, wpnDict['weapon_id'])
	
	# Spell Slots
	for i in range (1, 10):
		var slotDict = {}
		slotDict['num_expended'] = get_node("CharContainer/TabBar/Spellcasting/VBoxContainer/HBoxContainer/SpellSlots/SpellSlots%s/Expended" % str(i)).value
		slotDict['total'] = get_node("CharContainer/TabBar/Spellcasting/VBoxContainer/HBoxContainer/SpellSlots/SpellSlots%s/Total" % str(i)).value 
		Database.updateSpellSlot(slotDict, i)
	
	# Spells 
	for s in spellsNode.get_children():
		var splDict = s.get_values()
		Database.updateSpell(splDict, splDict['spell_id'])
	
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

func _on_class_item_selected(_index):
	# Calculate hit dice type by class
	cHitDiceTotal.text = str(cLevel.value) + 'd' + str(CLASS_HD.values()[cClass.selected])

func _on_level_value_changed(value):
	# Calculate proficiency bonus according to level
	cPB.text = '+' + str(floor((value - 1) / 4.0) + 2)
	cHitDiceTotal.text = str(cLevel.value) + 'd' + str(CLASS_HD.values()[cClass.selected])

func calculate_modifier(scoreName, value):
	var newMod = floor((value - 10.0) / 2.0)
	cASMods[scoreName] = newMod
	cASModLabels[scoreName].text = '%s (%s)' % [scoreName, ('+' if newMod >= 0 else '') + str(newMod)]

func _on_str_score_value_changed(value):
	calculate_modifier('Strength', value)
	for skillName in Database.ABILITY_SCORES['Strength']:
		calculate_bonus(cSkills[skillName])

func _on_dex_score_value_changed(value):
	calculate_modifier('Dexterity', value)
	for skillName in Database.ABILITY_SCORES['Dexterity']:
		calculate_bonus(cSkills[skillName])

func _on_con_score_value_changed(value):
	calculate_modifier('Constitution', value)
	for skillName in Database.ABILITY_SCORES['Constitution']:
		calculate_bonus(cSkills[skillName])

func _on_int_score_value_changed(value):
	calculate_modifier('Intelligence', value)
	for skillName in Database.ABILITY_SCORES['Intelligence']:
		calculate_bonus(cSkills[skillName])
	if cSpellAbility.text == 'INT':
		refresh_spell_stuff('Intelligence')

func _on_wis_score_value_changed(value):
	calculate_modifier('Wisdom', value)
	for skillName in Database.ABILITY_SCORES['Wisdom']:
		calculate_bonus(cSkills[skillName])
	if cSpellAbility.text == 'WIS':
		refresh_spell_stuff('Wisdom')

func _on_cha_score_value_changed(value):
	calculate_modifier('Charisma', value)
	for skillName in Database.ABILITY_SCORES['Charisma']:
		calculate_bonus(cSkills[skillName])
	if cSpellAbility.text == 'CHA':
		refresh_spell_stuff('Charisma')

func calculate_bonus(skill, skillNode = null):
	var skillName = skill['skill_name']
	var govScore = skill['governing_score']
	
	if skillNode == null:
		skillNode = find_child(skillName)
	
	var newBonus = cASMods[govScore] + (int(skillNode.button_pressed) * int(cPB.text))
	
	if skillName in ['StrSave', 'DexSave', 'ConSave', 'IntSave', 'WisSave', 'ChaSave']:
		skillName = 'Saving Throws'
	
	skillNode.text = '%s (%s)' % [skillName, ('+' if newBonus >= 0 else '') + str(newBonus)]

func _on_str_save_toggled(_toggled_on):
	calculate_bonus(cSkills['StrSave'])

func _on_athletics_toggled(_toggled_on):
	calculate_bonus(cSkills['Athletics'])

func _on_dex_save_toggled(_toggled_on):
	calculate_bonus(cSkills['DexSave'])

func _on_acrobatics_toggled(_toggled_on):
	calculate_bonus(cSkills['Acrobatics'])

func _on_sleight_of_hand_toggled(_toggled_on):
	calculate_bonus(cSkills['Sleight of Hand'])

func _on_stealth_toggled(_toggled_on):
	calculate_bonus(cSkills['Stealth'])

func _on_con_save_toggled(_toggled_on):
	calculate_bonus(cSkills['ConSave'])

func _on_int_save_toggled(_toggled_on):
	calculate_bonus(cSkills['IntSave'])

func _on_arcana_toggled(_toggled_on):
	calculate_bonus(cSkills['Arcana'])

func _on_history_toggled(_toggled_on):
	calculate_bonus(cSkills['History'])

func _on_investigation_toggled(_toggled_on):
	calculate_bonus(cSkills['Investigation'])

func _on_nature_toggled(_toggled_on):
	calculate_bonus(cSkills['Nature'])

func _on_religion_toggled(_toggled_on):
	calculate_bonus(cSkills['Religion'])

func _on_wis_save_toggled(_toggled_on):
	calculate_bonus(cSkills['WisSave'])

func _on_animal_handling_toggled(_toggled_on):
	calculate_bonus(cSkills['Animal Handling'])

func _on_insight_toggled(_toggled_on):
	calculate_bonus(cSkills['Insight'])

func _on_medicine_toggled(_toggled_on):
	calculate_bonus(cSkills['Medicine'])

func _on_perception_toggled(_toggled_on):
	calculate_bonus(cSkills['Perception'])

func _on_survival_toggled(_toggled_on):
	calculate_bonus(cSkills['Survival'])

func _on_cha_save_toggled(_toggled_on):
	calculate_bonus(cSkills['ChaSave'])

func _on_deception_toggled(_toggled_on):
	calculate_bonus(cSkills['Deception'])

func _on_intimidation_toggled(_toggled_on):
	calculate_bonus(cSkills['Intimidation'])

func _on_performance_toggled(_toggled_on):
	calculate_bonus(cSkills['Performance'])

func _on_persuasion_toggled(_toggled_on):
	calculate_bonus(cSkills['Persuasion'])

func refresh_weapons():
	Database.db.open_db()
	
	for w in weaponsNode.get_children():
		var wpnDict = w.get_values()
		Database.updateWeapon(wpnDict, wpnDict['weapon_id'])
		weaponsNode.remove_child(w)
	
	for w in Database.fetchWeapons():
		var wpnBlrb = weaponBlurb.instantiate()
		wpnBlrb.weaponDetails = w
		weaponsNode.add_child(wpnBlrb)
	Database.db.close_db()

func _on_add_weapon_button_pressed():
	Database.db.open_db()
	Database.addWeapon()
	Database.db.close_db()
	refresh_weapons()

func refresh_spell_stuff(ability):
	var atk = cASMods[ability] + int(cPB.text)
	var dc = 8 + atk
	cSpellAbility.selected = SC_ABILITIES.find(ability)
	cSpellAttack.text = ('+' if atk >= 0 else '') + str(atk)
	cSpellDC.text = str(dc)

func _on_spellcasting_ability_item_selected(index):
	var ability = SC_ABILITIES[index]
	refresh_spell_stuff(ability)

func refresh_spell_list():
	Database.db.open_db()
	for s in spellsNode.get_children():
		var splDict = s.get_values()
		Database.updateSpell(splDict, splDict['spell_id'])
		spellsNode.remove_child(s)
	
	for s in Database.fetchSpells():
		var splBlrb = spellBlurb.instantiate()
		splBlrb.spellDetails = s
		spellsNode.add_child(splBlrb)
	Database.db.close_db()

func _on_add_spell_button_pressed():
	Database.db.open_db()
	Database.addSpell()
	Database.db.close_db()
	refresh_spell_list()
