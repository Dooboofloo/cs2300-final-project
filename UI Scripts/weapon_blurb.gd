extends HBoxContainer

var weaponDetails

func _ready():
	$WeaponName.text = weaponDetails['weapon_name']
	$AttackBonus.prefix = '+' if weaponDetails['atk_bonus'] >= 0 else ''
	$AttackBonus.value = weaponDetails['atk_bonus']
	$DamageType.text = weaponDetails['damage']

func _on_delete_button_pressed():
	Database.db.open()
	Database.deleteWeapon(weaponDetails['owning_char'], weaponDetails['weapon_name'])
	Database.db.close()
	queue_free()
