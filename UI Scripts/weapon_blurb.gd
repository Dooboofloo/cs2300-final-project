extends HBoxContainer

var weaponDetails

func _ready():
	$WeaponName.text = weaponDetails['weapon_name']
	$AttackBonus.prefix = '+' if weaponDetails['atk_bonus'] >= 0 else ''
	$AttackBonus.value = weaponDetails['atk_bonus']
	$DamageType.text = weaponDetails['damage']

func _on_delete_button_pressed():
	Database.db.open_db()
	Database.deleteWeapon(weaponDetails['owning_char'], weaponDetails['weapon_id'])
	Database.db.close_db()
	queue_free()

func get_values():
	return {'owning_char': weaponDetails['owning_char'], 'weapon_id': weaponDetails['weapon_id'], 'weapon_name': $WeaponName.text, 'atk_bonus': $AttackBonus.value, 'damage': $DamageType.text}

func _on_attack_bonus_value_changed(value):
	$AttackBonus.prefix = '+' if value >= 0 else ''
