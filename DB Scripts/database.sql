BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "User" (
	"username"	TEXT NOT NULL UNIQUE,
	"password"	TEXT NOT NULL,
	PRIMARY KEY("username")
);
CREATE TABLE IF NOT EXISTS "Money" (
	"char_id"	INTEGER NOT NULL UNIQUE,
	"cp"	INTEGER DEFAULT 0,
	"sp"	INTEGER DEFAULT 0,
	"ep"	INTEGER DEFAULT 0,
	"gp"	INTEGER DEFAULT 0,
	"pp"	INTEGER DEFAULT 0,
	PRIMARY KEY("char_id"),
	FOREIGN KEY("char_id") REFERENCES "Character"("uuid") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "Character Manager" (
	"user"	TEXT NOT NULL,
	"char_id"	INTEGER NOT NULL UNIQUE,
	PRIMARY KEY("char_id" AUTOINCREMENT),
	FOREIGN KEY("user") REFERENCES "User"("username") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "Physical Stats" (
	"char_id"	INTEGER NOT NULL UNIQUE,
	"armor_class"	INTEGER DEFAULT 10,
	"initiative"	INTEGER DEFAULT 0,
	"speed"	INTEGER DEFAULT 30,
	PRIMARY KEY("char_id"),
	FOREIGN KEY("char_id") REFERENCES "Character"("uuid") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "Hit Points" (
	"char_id"	INTEGER NOT NULL UNIQUE,
	"max"	INTEGER DEFAULT 0,
	"current"	INTEGER DEFAULT 0,
	"temp"	INTEGER DEFAULT 0,
	PRIMARY KEY("char_id"),
	FOREIGN KEY("char_id") REFERENCES "Character"("uuid") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "Death Saves" (
	"char_id"	INTEGER NOT NULL UNIQUE,
	"num_success"	INTEGER DEFAULT 0,
	"num_fail"	INTEGER DEFAULT 0,
	PRIMARY KEY("char_id"),
	FOREIGN KEY("char_id") REFERENCES "Character"("uuid") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "Backstory" (
	"char_id"	INTEGER NOT NULL UNIQUE,
	"race"	TEXT DEFAULT 'Human',
	"background"	TEXT DEFAULT 'Soldier',
	"alignment"	TEXT DEFAULT 'Lawful Good',
	PRIMARY KEY("char_id"),
	FOREIGN KEY("char_id") REFERENCES "Character"("uuid") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "Character" (
	"uuid"	INTEGER NOT NULL UNIQUE,
	"name"	TEXT,
	"level"	INTEGER DEFAULT 1,
	"class"	TEXT,
	"prof_bonus"	INTEGER DEFAULT 2,
	"equipment"	TEXT DEFAULT '',
	"notes"	TEXT,
	PRIMARY KEY("uuid"),
	FOREIGN KEY("uuid") REFERENCES "Character Manager"("char_id") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "Hit Dice" (
	"char_id"	INTEGER NOT NULL UNIQUE,
	"num_used"	INTEGER DEFAULT 0,
	"total"	INTEGER DEFAULT 1,
	"type"	INTEGER DEFAULT 10,
	PRIMARY KEY("char_id"),
	FOREIGN KEY("char_id") REFERENCES "Character"("uuid") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "Skill" (
	"char_id"	INTEGER NOT NULL,
	"governing_score"	TEXT NOT NULL,
	"skill_name"	TEXT NOT NULL,
	"proficiency_mult"	INTEGER DEFAULT 0,
	"bonus"	INTEGER DEFAULT 0,
	PRIMARY KEY("char_id","governing_score","skill_name"),
	FOREIGN KEY("char_id","governing_score") REFERENCES "Ability Score"("char_id","name") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "Ability Score" (
	"char_id"	INTEGER NOT NULL,
	"name"	TEXT NOT NULL,
	"score"	INTEGER DEFAULT 10,
	"modifier"	INTEGER DEFAULT 0,
	FOREIGN KEY("char_id") REFERENCES "Character"("uuid") ON DELETE CASCADE,
	PRIMARY KEY("char_id","name")
);
CREATE TABLE IF NOT EXISTS "Weapon" (
	"owning_char"	INTEGER NOT NULL,
	"weapon_id"	INTEGER NOT NULL UNIQUE,
	"weapon_name"	TEXT NOT NULL DEFAULT 'Shortsword',
	"atk_bonus"	INTEGER DEFAULT 0,
	"damage"	TEXT DEFAULT 'Damage',
	FOREIGN KEY("owning_char") REFERENCES "Character"("uuid") ON DELETE CASCADE,
	PRIMARY KEY("weapon_id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Spellcasting" (
	"char_id"	INTEGER NOT NULL UNIQUE,
	"ability_score"	TEXT,
	"save_dc"	INTEGER DEFAULT 0,
	"atk_bonus"	INTEGER DEFAULT 0,
	FOREIGN KEY("char_id") REFERENCES "Character"("uuid") ON DELETE CASCADE,
	PRIMARY KEY("char_id")
);
CREATE TABLE IF NOT EXISTS "Spell Slot" (
	"char_id"	INTEGER NOT NULL,
	"slot_level"	INTEGER NOT NULL DEFAULT 1,
	"total"	INTEGER DEFAULT 0,
	"num_expended"	INTEGER DEFAULT 0,
	FOREIGN KEY("char_id") REFERENCES "Character"("uuid") ON DELETE CASCADE,
	PRIMARY KEY("char_id","slot_level")
);
CREATE TABLE IF NOT EXISTS "Spell" (
	"char_id"	INTEGER NOT NULL,
	"spell_id"	INTEGER NOT NULL UNIQUE,
	"level"	INTEGER DEFAULT 1,
	"name"	TEXT NOT NULL DEFAULT 'Spell Name',
	FOREIGN KEY("char_id") REFERENCES "Character"("uuid") ON DELETE CASCADE,
	PRIMARY KEY("spell_id" AUTOINCREMENT)
);
COMMIT;
