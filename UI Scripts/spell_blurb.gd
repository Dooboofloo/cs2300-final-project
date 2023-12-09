extends HBoxContainer

var spellDetails

func _ready():
	$Level.value = spellDetails['level']
	$SpellName.text = spellDetails['name']

func _on_delete_button_pressed():
	Database.db.open_db()
	Database.deleteSpell(spellDetails['char_id'], spellDetails['spell_id'])
	Database.db.close_db()
	queue_free()

func get_values():
	return {'char_id': spellDetails['char_id'], 'spell_id': spellDetails['spell_id'], 'level': $Level.value, 'name': $SpellName.text}
