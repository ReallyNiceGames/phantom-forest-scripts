extends Node

# Code below can be used to manage preloads if there's too many later on
#var loadedFiles:Dictionary 
#for filePath in DirAccess.get_files_at("res://assets/"):  
	#loadedFiles[filePath] = load(filePath) 
#Var someResource = MySingleton.loadedFiles["res://assets/sprite.tres"]

const scenes = {
	"main_menu":"res://assets/scenes/main_menu.tscn",
	"battle":"res://assets/scenes/battle.tscn",
	"shop":"res://assets/scenes/shop.tscn",
	"camp":"res://assets/scenes/camp.tscn",
	"ambush":"res://assets/scenes/ambush.tscn",
	"gamble":"res://assets/scenes/gamble.tscn",
	"grove":"res://assets/scenes/grove.tscn",
	"intro":"res://assets/scenes/intro_cutscene.tscn",
	"chase":"res://assets/scenes/runikesh_cutscene.tscn",
	"end":"res://assets/scenes/end_cutscene.tscn",
}

const music = {
	"stage1":preload("res://assets/music/stage1.ogg"),
	"stage20":preload("res://assets/music/stage20.ogg"),
	"stage40":preload("res://assets/music/stage40.ogg"),
	"stage60":preload("res://assets/music/stage60.ogg"),
	"stage80":preload("res://assets/music/stage80.ogg"),
	"stage101":preload("res://assets/music/stage101.ogg"),
	"shop1":preload("res://assets/music/shop1.ogg"),
	#"shop2":preload("res://assets/music/shop2.ogg"),
	"boss1":preload("res://assets/music/boss1.ogg"),
	"boss2":preload("res://assets/music/boss2.ogg"),
	"main_menu":preload("res://assets/music/main_menu.ogg"),
	"grove":preload("res://assets/music/grove.ogg"),
}

const icons = {
	"default":preload("res://assets/sprites/icons/icon.svg"),
	"sword":preload("res://assets/sprites/icons/sword.png"),
	"explosion":preload("res://assets/sprites/icons/explosion.png"),
	"explosion2":preload("res://assets/sprites/icons/explosion2.png"),
	"explosion3":preload("res://assets/sprites/icons/explosion3.png"),
	"heart":preload("res://assets/sprites/icons/heart.png"),
	"bread":preload("res://assets/sprites/icons/bread.png"),
	"rock":preload("res://assets/sprites/icons/rock.png"),
	"coin":preload("res://assets/sprites/icons/coin.png"),
	"bread2":preload("res://assets/sprites/icons/bread2.png"),
	"cake":preload("res://assets/sprites/icons/cake.png"),
	"juice":preload("res://assets/sprites/icons/juice.png"),
	"tea":preload("res://assets/sprites/icons/tea.png"),
	"axe":preload("res://assets/sprites/icons/axe.png"),
	"dagger":preload("res://assets/sprites/icons/dagger.png"),
	"ice":preload("res://assets/sprites/icons/ice.png"),
	"sword2":preload("res://assets/sprites/icons/sword2.png"),
	"sword3":preload("res://assets/sprites/icons/sword3.png"),
	"sword4":preload("res://assets/sprites/icons/sword4.png"),
	"sword5":preload("res://assets/sprites/icons/sword5.png"),
	"bomb":preload("res://assets/sprites/icons/bomb.png"),
	"shield":preload("res://assets/sprites/icons/shield.png"),
	"shield_cracked":preload("res://assets/sprites/icons/shield_cracked.png"),
	"helm_dull":preload("res://assets/sprites/icons/armour/helm_dull.png"),
	"chest_dull":preload("res://assets/sprites/icons/armour/chest_dull.png"),
	"arms_dull":preload("res://assets/sprites/icons/armour/arms_dull.png"),
	"legs_dull":preload("res://assets/sprites/icons/armour/legs_dull.png"),
	"helm_green":preload("res://assets/sprites/icons/armour/helm_green.png"),
	"chest_green":preload("res://assets/sprites/icons/armour/chest_green.png"),
	"arms_green":preload("res://assets/sprites/icons/armour/arms_green.png"),
	"legs_green":preload("res://assets/sprites/icons/armour/legs_green.png"),
	"helm_blue":preload("res://assets/sprites/icons/armour/helm_blue.png"),
	"chest_blue":preload("res://assets/sprites/icons/armour/chest_blue.png"),
	"arms_blue":preload("res://assets/sprites/icons/armour/arms_blue.png"),
	"legs_blue":preload("res://assets/sprites/icons/armour/legs_blue.png"),
	"helm_purple":preload("res://assets/sprites/icons/armour/helm_purple.png"),
	"chest_purple":preload("res://assets/sprites/icons/armour/chest_purple.png"),
	"arms_purple":preload("res://assets/sprites/icons/armour/arms_purple.png"),
	"legs_purple":preload("res://assets/sprites/icons/armour/legs_purple.png"),
	"helm_red":preload("res://assets/sprites/icons/armour/helm_red.png"),
	"chest_red":preload("res://assets/sprites/icons/armour/chest_red.png"),
	"arms_red":preload("res://assets/sprites/icons/armour/arms_red.png"),
	"legs_red":preload("res://assets/sprites/icons/armour/legs_red.png"),
	"helm_gold":preload("res://assets/sprites/icons/armour/helm_gold.png"),
	"chest_gold":preload("res://assets/sprites/icons/armour/chest_gold.png"),
	"arms_gold":preload("res://assets/sprites/icons/armour/arms_gold.png"),
	"legs_gold":preload("res://assets/sprites/icons/armour/legs_gold.png"),
	"helm_true":preload("res://assets/sprites/icons/armour/helm.png"),
	"chest_true":preload("res://assets/sprites/icons/armour/chest.png"),
	"arms_true":preload("res://assets/sprites/icons/armour/arms.png"),
	"legs_true":preload("res://assets/sprites/icons/armour/legs.png"),
	"head_empty":preload("res://assets/sprites/icons/armour/helm_greyed.png"),
	"chest_empty":preload("res://assets/sprites/icons/armour/chest_greyed.png"),
	"arms_empty":preload("res://assets/sprites/icons/armour/arms_greyed.png"),
	"legs_empty":preload("res://assets/sprites/icons/armour/legs_greyed.png"),
	"disabled":preload("res://assets/sprites/icons/disabled.png"),
	"skull":preload("res://assets/sprites/icons/skull.png"),
	"small_sword":preload("res://assets/sprites/icons/small_sword.png"),
	"small_sword_bloody":preload("res://assets/sprites/icons/small_sword_bloody.png"),
	"boots":preload("res://assets/sprites/icons/boots.png"),
	"speed_down":preload("res://assets/sprites/icons/speed_down.png"),
	"speed_up":preload("res://assets/sprites/icons/speed_up.png"),
	"explosion4":preload("res://assets/sprites/icons/explosion4.png"),
	"acc_up":preload("res://assets/sprites/icons/acc_up.png"),
	"acc_down":preload("res://assets/sprites/icons/acc_down.png"),
	"explosion5":preload("res://assets/sprites/icons/explosion5.png"),
	"flame":preload("res://assets/sprites/icons/flame.png"),
	"flame2":preload("res://assets/sprites/icons/flame2.png"),
	"fire1":preload("res://assets/sprites/icons/fire1.png"),
	"fire2":preload("res://assets/sprites/icons/fire2.png"),
	"fire3":preload("res://assets/sprites/icons/fire3.png"),
	"runikesh":preload("res://assets/sprites/icons/runikesh_icon.png"),
	"gourmet":preload("res://assets/sprites/icons/gourmet.png"),
	"amulet":preload("res://assets/sprites/icons/amulet.png"),
	"bag":preload("res://assets/sprites/icons/bag.png"),
	"equipment":preload("res://assets/sprites/icons/equipment.png"),
	"favor":preload("res://assets/sprites/icons/favor.png"),
	"help":preload("res://assets/sprites/icons/help.png"),
	"jewel":preload("res://assets/sprites/icons/jewel.png"),
	"mirror":preload("res://assets/sprites/icons/mirror.png"),
	"options":preload("res://assets/sprites/icons/options.png"),
	"restart":preload("res://assets/sprites/icons/restart.png"),
	"unknown":preload("res://assets/sprites/icons/unknown.png"),
	"chest1":preload("res://assets/sprites/icons/chest.png"),
	"chest2":preload("res://assets/sprites/icons/chest2.png"),
}

const backgrounds = {
	"background1":preload("res://assets/sprites/backgrounds/background1.png"),
	"background2":preload("res://assets/sprites/backgrounds/background2.png"),
	"background3":preload("res://assets/sprites/backgrounds/background3.png"),
	"background4":preload("res://assets/sprites/backgrounds/background4.png"),
	"background5":preload("res://assets/sprites/backgrounds/background5.png"),
	"background6":preload("res://assets/sprites/backgrounds/background_graveyard.png"),
	"background7":preload("res://assets/sprites/backgrounds/background_lava.png"),
	"camp_lava":preload("res://assets/sprites/backgrounds/background_no_lava.png"),
	"shop":preload("res://assets/sprites/backgrounds/background_shop.png"),
}

const enemies = {
	0:{"name": "Crow", "type": "basic", "actions": [0,1]},
	1:{"name": "Cobra", "type": "basic", "actions": [0,2]},
	2:{"name": "Toad", "type": "basic", "actions": [0,5]},
	3:{"name": "Merman", "type": "basic", "actions": [0,7,4]},
	4:{"name": "Ogre", "type": "basic", "actions": [8,0,1]},
	5:{"name": "Mage", "type": "basic", "actions": [6,1,5]},
	6:{"name": "Ghost", "type": "basic", "actions": [6,12,4,14]},
	7:{"name": "Spectre", "type": "basic", "actions": [5,2,11,3]},
	8:{"name": "Werewolf", "type": "basic", "actions": [0,8,2,7]},
	9:{"name": "Skull", "type": "basic", "actions": [6,11,12,9]},
	10:{"name": "Demon", "type": "basic", "actions": [0,1,13,10,11]},
	11:{"name": "Hellhound", "type": "basic", "actions": [0,2,14]},
	12:{"name": "Hellhorse", "type": "basic", "actions": [8,7,12]},
	13:{"name": "Hellbeast", "type": "basic", "actions": [13,14,10,5,9]},
	14:{"name": "Dragon", "type": "basic", "actions": [16,14,17,1,15]},
	15:{"name": "Phantom", "type": "boss", "actions": [0,14,1,23]},
	16:{"name": "Runikesh", "type": "boss", "actions": [22,20,21,18,19]},
	17:{"name": "Highwayman", "type": "boss", "actions": [0,6,2,3]},
}

const enemy_actions = {
	0:{"name": "", "type": "attack", "power": 1.0, "duration": 0},
	1:{"name": "", "type": "idle", "power": 0.0, "duration": 0},
	2:{"name": "rend", "type": "bleeding", "power": 0.5, "duration": 3},
	3:{"name": "heal", "type": "healing", "power": 1.5, "duration": 0},
	4:{"name": "regenerate", "type": "HP regen", "power": 0.75, "duration": 3},
	5:{"name": "leech", "type": "MP steal", "power": 0.7, "duration": 0},
	6:{"name": "fireball", "type": "magic attack", "power": 1.0, "duration": 0},
	7:{"name": "sunder", "type": "defence down", "power": 0.5, "duration": 3},
	8:{"name": "pulverise", "type": "attack", "power": 1.2, "duration": 0},
	9:{"name": "curse", "type": "disable items", "power": 0.0, "duration": 4},
	10:{"name": "siphon", "type": "lifesteal", "power": 1.0, "duration": 3},
	11:{"name": "screech", "type": "speed down", "power": 0.25, "duration": 4},
	12:{"name": "fog", "type": "accuracy down", "power": 0.5, "duration": 4},
	13:{"name": "hellfire", "type": "magic attack", "power": 1.4, "duration": 0},
	14:{"name": "ignite", "type": "burning", "power": 0.6, "duration": 4},
	15:{"name": "mend_flesh", "type": "healing", "power": 2.5, "duration": 0},
	16:{"name": "obliterate", "type": "attack", "power": 1.5, "duration": 0},
	17:{"name": "expose", "type": "defence down", "power": 1.1, "duration": 3},
	18:{"name": "azurefire_weapon", "type": "disable weapon", "power": 1.8, "duration": 3},
	19:{"name": "azurefire_magic", "type": "disable magic", "power": 1.8, "duration": 3},
	20:{"name": "runikesh_burn", "type": "burning", "power": 0.8, "duration": 4},
	21:{"name": "runikesh_siphon", "type": "lifesteal", "power": 1.1, "duration": 3},
	22:{"name": "runikesh_smash", "type": "attack", "power": 1.8, "duration": 0},
	23:{"name": "azurefire_lesser", "type": "disable weapon", "power": 1.4, "duration": 3},
}

const weapons = {
	# ID: {WEAPON NAME, 1ST SKILL REF, 2ND SKILL REF, NTH SKILL REF, NO. OF SKILLS, SHOP VALUE, QUALITY, ICON}
	0: {"name": "Basic Sword", "skills": [0,1], "price": 0, "quality": 1, "icon": icons["sword"]},
	1: {"name": "Sharp Sword", "skills": [2,3,1], "price": 80, "quality": 2, "icon": icons["sword2"]},
	2: {"name": "Mighty Sword", "skills": [4,6,5], "price": 200, "quality": 3, "icon": icons["sword3"]},
	3: {"name": "Shining Cutlass", "skills": [7,8,9,10], "price": 600, "quality": 4, "icon": icons["sword4"]},
	4: {"name": "Grandbrandt", "skills": [11,12,13,14,15], "price": 999, "quality": 5, "icon": icons["sword5"]},
}

const weapon_skills = {
	0: {"name": "Slash", "power": 5, "type": "attack", "duration": 0, "icon": icons["sword"]},
	1: {"name": "Guard", "power": 15, "type": "defence up", "duration": 1, "icon": icons["sword"]},
	2: {"name": "Sharp Slash", "power": 10, "type": "attack", "duration": 0, "icon": icons["sword2"]},
	3: {"name": "Rend", "power": 7, "type": "bleeding", "duration": 3, "icon": icons["sword2"]},
	4: {"name": "Mighty Slash", "power": 22, "type": "attack", "duration": 0, "icon": icons["sword3"]},
	5: {"name": "Fortify", "power": 30, "type": "defence up", "duration": 1, "icon": icons["sword3"]},
	6: {"name": "Deep Wound", "power": 12, "type": "bleeding", "duration": 3, "icon": icons["sword3"]},
	7: {"name": "Dismember", "power": 45, "type": "attack", "duration": 0, "icon": icons["sword4"]},
	8: {"name": "Gouge", "power": 22, "type": "bleeding", "duration": 3, "icon": icons["sword4"]},
	9: {"name": "Deflect", "power": 50, "type": "defence up", "duration": 1, "icon": icons["sword4"]},
	10: {"name": "Shine", "power": 12, "type": "HP regen", "duration": 4, "icon": icons["sword4"]},
	11: {"name": "Execute", "power": 75, "type": "attack", "duration": 0, "icon": icons["sword5"]},
	12: {"name": "Hemorrhage", "power": 35, "type": "bleeding", "duration": 4, "icon": icons["sword5"]},
	13: {"name": "Barrier", "power": 100, "type": "defence up", "duration": 1, "icon": icons["sword5"]},
	14: {"name": "Invigorate", "power": 25, "type": "HP regen", "duration": 4, "icon": icons["sword5"]},
	15: {"name": "Draw Power", "power": 10, "type": "MP regen", "duration": 4, "icon": icons["sword5"]},
}

const magic_spells = {
	0: {"name": "Fireball", "power": 8, "cost": 5, "type": "attack", "duration": 0, "price": 0, "icon": icons["explosion"]},
	1: {"name": "Minor Heal", "power": 12, "cost": 6, "type": "healing", "duration": 0, "price": 30, "icon": icons["heart"]},
	2: {"name": "Ignite", "power": 12, "cost": 10, "type": "burning", "duration": 3, "price": 100, "icon": icons["fire1"]},
	3: {"name": "Mega Fireball", "power": 30, "cost": 12, "type": "attack", "duration": 0, "price": 120, "icon": icons["explosion3"]},
	4: {"name": "Heal", "power": 25, "cost": 10, "type": "healing", "duration": 0, "price": 90, "icon": icons["heart"]},
	5: {"name": "Soul Siphon", "power": 10, "cost": 5, "type": "MP steal", "duration": 0, "price": 150, "icon": icons["ice"]},
	6: {"name": "Flame Burst", "power": 30, "cost": 18, "type": "burning", "duration": 3, "price": 250, "icon": icons["flame"]},
	7: {"name": "Cataclysm", "power": 65, "cost": 20, "type": "attack", "duration": 0, "price": 400, "icon": icons["explosion5"]},
	8: {"name": "Major Heal", "power": 40, "cost": 18, "type": "healing", "duration": 0, "price": 180, "icon": icons["heart"]},
	9: {"name": "Incinerate", "power": 60, "cost": 35, "type": "burning", "duration": 4, "price": 800, "icon": icons["flame2"]},
	10: {"name": "Grand Heal", "power": 80, "cost": 28, "type": "healing", "duration": 0, "price": 500, "icon": icons["heart"]},
	11: {"name": "Scorch Earth", "power": 120, "cost": 30, "type": "attack", "duration": 0, "price": 999, "icon": icons["explosion4"]},
	12: {"name": "Lich Feast", "power": 50, "cost": 40, "type": "lifesteal", "duration": 4, "price": 0, "icon": icons["runikesh"]},
}

const usable_items = {
	0: {"name": "Rations", "power": 5, "type": "healing", "duration": 0, "price": 0, "uses": -1, "icon": icons["bag"], "anim": "player_heart"},
	1: {"name": "Rock", "power": 12, "type": "attack", "duration": 0, "price": 5, "uses": 1, "icon": icons["rock"], "anim": "player_rock"},
	2: {"name": "Bread", "power": 15, "type": "healing", "duration": 0, "price": 5, "uses": 3, "icon": icons["bread"], "anim": "player_heart"},
	3: {"name": "Throwing Knife", "power": 28, "type": "attack", "duration": 0, "price": 15, "uses": 1, "icon": icons["dagger"], "anim": "player_dagger"},
	4: {"name": "Baguette", "power": 30, "type": "healing", "duration": 0, "price": 12, "uses": 1, "icon": icons["bread2"], "anim": "player_heart"},
	5: {"name": "Power Juice", "power": 25, "type": "MP gain", "duration": 0, "price": 30, "uses": 2, "icon": icons["juice"], "anim": "player_juice"},
	6: {"name": "Throwing Axe", "power": 60, "type": "attack", "duration": 0, "price": 35, "uses": 1, "icon": icons["axe"], "anim": "player_axe"},
	7: {"name": "Cake", "power": 45, "type": "healing", "duration": 0, "price": 40, "uses": 2, "icon": icons["cake"], "anim": "player_heart"},
	8: {"name": "Quali-Tea", "power": 15, "type": "HP regen", "duration": 5, "price": 60, "uses": 1, "icon": icons["tea"], "anim": "player_heart"},
	9: {"name": "Bomb", "power": 100, "type": "attack", "duration": 0, "price": 80, "uses": 1, "icon": icons["bomb"], "anim": "player_bomb"},
	10: {"name": "The Gourmet", "power": 120, "type": "healing", "duration": 0, "price": 100, "uses": 1, "icon": icons["gourmet"], "anim": "player_heart"}
}

const armour_pieces = {
	# STATS IN ORDER: HP, HP_REGEN, MP, MP_REGEN, DEFENCE, ATTACK, SPELLPOWER
	0: {"name": "Dull Helmet", "stats": [2, 0, 0, 0, 1, 0, 0], "slot": "head", "price": 20, "quality": 1, "icon": icons["helm_dull"]},
	1: {"name": "Dull Cuirass", "stats": [3, 0, 0, 0, 2, 0, 0], "slot": "chest", "price": 30, "quality": 1, "icon": icons["chest_dull"]},
	2: {"name": "Dull Gauntlets", "stats": [2, 0, 0, 0, 1, 1, 0], "slot": "arms", "price": 25, "quality": 1, "icon": icons["arms_dull"]},
	3: {"name": "Dull Greaves", "stats": [3, 0, 0, 0, 1, 0, 0], "slot": "legs", "price": 20, "quality": 1, "icon": icons["legs_dull"]},
	4: {"name": "Casque of Strength", "stats": [3, 0, 0, 0, 2, 1, 0], "slot": "head", "price": 50, "quality": 2, "icon": icons["helm_green"]},
	5: {"name": "Hauberk of Strength", "stats": [5, 1, 0, 0, 2, 2, 0], "slot": "chest", "price": 70, "quality": 2, "icon": icons["chest_green"]},
	6: {"name": "Vambraces of Strength", "stats": [3, 0, 0, 0, 2, 2, 0], "slot": "arms", "price": 50, "quality": 2, "icon": icons["arms_green"]},
	7: {"name": "Sabatons of Strength", "stats": [4, 1, 0, 0, 2, 1, 0], "slot": "legs", "price": 60, "quality": 2, "icon": icons["legs_green"]},
	8: {"name": "Enchanted Armet", "stats": [6, 0, 4, 1, 2, 2, 2], "slot": "head", "price": 100, "quality": 2, "icon": icons["helm_blue"]},
	9: {"name": "Enchanted Chain", "stats": [10, 0, 6, 0, 3, 3, 3], "slot": "chest", "price": 125, "quality": 2, "icon": icons["chest_blue"]},
	10: {"name": "Enchanted Gauntlets", "stats": [6, 0, 4, 1, 2, 2, 2], "slot": "arms", "price": 95, "quality": 2, "icon": icons["arms_blue"]},
	11: {"name": "Enchanted Tassets", "stats": [8, 0, 5, 0, 3, 2, 2], "slot": "legs", "price": 110, "quality": 2, "icon": icons["legs_blue"]},
	12: {"name": "Royal Knight Casque", "stats": [12, 1, 0, 0, 3, 4, 0], "slot": "head", "price": 175, "quality": 3, "icon": icons["helm_purple"]},
	13: {"name": "Royal Knight Hauberk", "stats": [16, 2, 0, 0, 5, 6, 0], "slot": "chest", "price": 250, "quality": 3, "icon": icons["chest_purple"]},
	14: {"name": "Royal Knight Gloves", "stats": [12, 1, 0, 0, 3, 4, 0], "slot": "arms", "price": 150, "quality": 3, "icon": icons["arms_purple"]},
	15: {"name": "Royal Knight Treads", "stats": [14, 1, 0, 0, 4, 5, 0], "slot": "legs", "price": 200, "quality": 3, "icon": icons["legs_purple"]},
	16: {"name": "Hellwalker Mantle", "stats": [5, 0, 10, 1, 1, 0, 6], "slot": "head", "price": 170, "quality": 3, "icon": icons["helm_red"]},
	17: {"name": "Hellwalker Crest", "stats": [5, 0, 13, 2, 2, 0, 8], "slot": "chest", "price": 200, "quality": 3, "icon": icons["chest_red"]},
	18: {"name": "Hellwalker Catalysts", "stats": [5, 0, 15, 3, 1, 0, 10], "slot": "arms", "price": 225, "quality": 3, "icon": icons["arms_red"]},
	19: {"name": "Hellwalker Striders", "stats": [5, 0, 12, 2, 1, 0, 6], "slot": "legs", "price": 180, "quality": 3, "icon": icons["legs_red"]},
	20: {"name": "Glorious Helmet", "stats": [20, 2, 3, 1, 4, 6, 5], "slot": "head", "price": 350, "quality": 4, "icon": icons["helm_gold"]},
	21: {"name": "Supreme Cuirass", "stats": [35, 3, 5, 2, 7, 8, 6], "slot": "chest", "price": 450, "quality": 4, "icon": icons["chest_gold"]},
	22: {"name": "Dauntless Gauntlets", "stats": [20, 2, 3, 1, 6, 6, 4], "slot": "arms", "price": 300, "quality": 4, "icon": icons["arms_gold"]},
	23: {"name": "Invincible Greaves", "stats": [25, 3, 4, 1, 5, 7, 6], "slot": "legs", "price": 375, "quality": 4, "icon": icons["legs_gold"]},
	24: {"name": "True Crown", "stats": [45, 5, 12, 3, 8, 10, 12], "slot": "head", "price": 650, "quality": 5, "icon": icons["helm_true"]},
	25: {"name": "True Platemail", "stats": [60, 5, 20, 5, 15, 15, 10], "slot": "chest", "price": 850, "quality": 5, "icon": icons["chest_true"]},
	26: {"name": "True Crushers", "stats": [45, 5, 12, 3, 7, 12, 10], "slot": "arms", "price": 600, "quality": 5, "icon": icons["arms_true"]},
	27: {"name": "True Warboots", "stats": [50, 5, 16, 4, 10, 13, 8], "slot": "legs", "price": 750, "quality": 5, "icon": icons["legs_true"]},
}

const relics = {
	0: {"name": "Mirror of Lyra", "stats": [0, 0, 0.1], "spell": 0, "price": 0, "quality": 4, "icon": icons["mirror"]},
	1: {"name": "Amulet of Vandar", "stats": [10, 0, 0], "spell": 1, "price": 0, "quality": 4, "icon": icons["amulet"]},
	2: {"name": "Jewel of Amarok", "stats": [0, 0.2, 0], "spell": 2, "price": 0, "quality": 4, "icon": icons["jewel"]},
	3: {"name": "Favor of Rascal", "stats": [15, 0.3, 0.2], "spell": 3, "price": 500, "quality": 5, "icon": icons["favor"]},
}

const relic_spells = {
	0: {"name": "Lyra's Misery", "power": 0.25, "cost": 10, "type": "lyra", "duration": 4, "icon": icons["mirror"]},
	1: {"name": "Vandar's Fury", "power": 1.5, "cost": 10, "type": "vandar", "duration": 2, "icon": icons["amulet"]},
	2: {"name": "Amarok's Thirst", "power": 0.35, "cost": 10, "type": "amarok", "duration": 6, "icon": icons["jewel"]},
	3: {"name": "Phylactery Buster", "power": 500, "cost": 0, "type": "rascal", "duration": 99, "icon": icons["favor"]},
}

# Save Data strings
const save_file_path: String = "Saves/"
const save_file_name: String = "SavedData.tres"
# Game constants
const sell_ratio: float = 0.2 # Determines sell price
const text_pause: float = 0.5 # Used to briefly pause the game after displaying text
const coin_reward_base: float = 5.0 # Base amount of coins given in rewards
const coin_reward_range: float = 0.25 # Between 0.0 and 1.0, allows for coin gain variation
const coin_reward_scaling: float = 0.6 # Higher values increase rewards exponentially each level
const weapon_stock_chance: float = 0.25 # 0.0 to 1.0 = 0% - 100%
const weapon_stock_max: int = 1 # Max amount of weapons that can be in the shop
const magic_stock_chance: float = 0.4 # 0.0 to 1.0 = 0% - 100%
const magic_stock_max: int = 2 # Max amount of spells that can be in the shop
const relic_loot_chance: float = 0.01 # 0.0 to 1.0 = 0% - 100%
const armour_loot_chance: float = 0.125 # 0.0 to 1.0 = 0% - 100%
const armour_stock_chance: float = 0.5 # 0.0 to 1.0 = 0% - 100%
const armour_stock_max: int = 2 # Max amount of armour that can be in the shop
const min_loot: int = 1
const max_loot: int = 2 # Max amount of object rewards that can be found in one enemy
const max_level: int = 100 # Final main stage, capped for scaling reasons
const min_stock: int = magic_stock_max + armour_stock_max + weapon_stock_max
const max_stock: int = min_stock + 5 # Limits how many items are sold by the shop
const player_status_scaling: float = 0.5 # Used to scale statuses used/inflicted by player
const item_limit: int = 1000
const magic_limit: int = 100
const weapon_limit: int = 100
const armour_limit: int = 100
const relic_limit: int = 100
const coin_limit: int = 9999
const status_limit: int = 1000
# Reduces enemy stat scaling every 10 levels to prevent it ramping up too quickly
const enemy_scaling_reduction: float = 0.28 # 0.1 = 10%, 0.2 = 20%, etc.
const crit_ratio: float = 2.0 # Multiplier applied to high-accuracy physical attacks
const min_shop_level: int = 5 # Earliest stage you can start seeing the shop
const base_shop_chance: float = 0.1 # 0.0 to 1.0, 0% to 100%
const min_event_level: int = min_shop_level + 1 # Earliest stage you can start seeing events
const base_event_chance: float = 0.1 # 0.0 to 1.0, 0% to 100%
const music_volume_limit: float = 0.2 # In percentage relative to master bus: 0.0 to 1.0, 0% to 100%
const music_fade_time: float = 2.0 # In seconds
const music_fade_rate: float = music_volume_limit / music_fade_time # Rate in which music fades in or out
const ambush_base_coin_cost: int = 20 # Default coin cost for "pay" option in an ambush
const ambush_base_health_cost: int = 12 # Default health cost for "run" option in an ambush
const gamble_base_cost: int = 20 # Default coin cost for buying the key in gamble scene
const player_wins_tiebreaks: bool = true

# Forces a specific enemy to appear
var forced_enemy_id: int = -1

# Tracks the highest stage reached
var best_stage: int = 0

# Game-changing variables for options menu
var text_speed: float = 45.0 # Higher = Faster
var hide_battle_anims: bool = false # Hides the non-character-sprite animations in battle scenes

# Stores a copy of any equippment, items, spells and stats for after a camp scene after dying
var checkpoint: Checkpoint
var checkpoint_available: bool = false
var checkpoint_loaded: bool = false # Used to run the camp scene differently when loading

# Player stats/variables
var player_max_HP: int = 100
var player_HP: int = player_max_HP
var player_HP_regen: int = 0
var player_max_MP: int = 40
var player_MP: int = player_max_MP
var player_MP_regen: int = 1
var player_defence: int = 0
var player_attack_power: int = 0
var player_spellpower: int = 0
var player_temp_defence: int = 0
var player_temp_attack: int = 0
var player_temp_spell: int = 0
var player_accuracy: float = 1.0
var player_speed: float = 1.0
var player_item_damage_ratio: float = 1.0
var player_weapon_lifesteal: float = 0.0

# Equipment slots
var player_weapon: Weapon = null
var player_relic: Relic = null
var player_head: Armour = null
var player_chest: Armour = null
var player_arms: Armour = null
var player_legs: Armour = null

# Relic bools
var lyra_obtained: bool = false
var vandar_obtained: bool = false
var amarok_obtained: bool = false
var relics_collected: bool = false # Used to determine if Favor of Rascal will be available in the shop
var rascal_obtained: bool = false
var favor_active: bool = false

# Enemy base stats/variables
var enemy_HP_multiplier: float = 1.0
var enemy_attack_multiplier: float = 1.0
var enemy_spell_multiplier: float = 1.0
var enemy_HP_scaling: float = 1.08 # Applies exponential gains in enemy base HP
var enemy_attack_scaling: float = 1.06 # Applies exponential gains in enemy attack damage
var enemy_spell_scaling: float = 1.05 # Applies exponential gains in enemy spell power
var enemy_id: int = -1 # Holds the most recent enemy ID

# Used to determine the kind of enemy that can appear
# Goes up after each victory and is used to increase difficulty/rewards scaling
var level: int = 1

# Money for shop
var coins: int = 10 

# Scene-related values
var shop_chance: float = 1.0 # The current chance, first is guaranteed
var event_chance: float = 0.2 # The current chance of finding an event, first one defaulting to 20% initially
var event_recent: String = "" # Most recent event name, used to prevent seeing the same twice in a row
var ambush_seen: bool = false # Tracks if an ambush has been seen this playthrough
var gamble_seen: bool = false # Tracks if a gamble has been seen this playthrough
var grove_seen: bool = false # Tracks if a grove has been seen this playthrough

# Name of the most recent song played
var current_song: String = ""
var music_volume: float = 0.0

# Storage arrays
var stored_weapons: Array = []
var stored_items: Array = []
var stored_magic: Array = []
var stored_armour: Array = []
var stored_relics: Array = []

func _ready() -> void:
	verify_save_directory(save_file_path)
	checkpoint = Checkpoint.new()
	load_game() # Try to load game data, if it exists
	#set_coins(46)
	#set_level(5)
	#create_all()
	#forced_enemy_id = 7
	#player_max_HP = 9999
	#player_HP = 88
	#player_max_MP = 999
	#player_MP = 36
	#player_attack_power = 9999
	#player_spellpower = 20

func verify_save_directory(path: String) -> void:
	var error: Error = DirAccess.make_dir_absolute(path)
	if error == 32:
		print("Save path directory already exists")
	elif error:
		printerr("Save path directory error")
		printerr("Error code: " + str(error))

func save_game() -> void:
	var error: Error = ResourceSaver.save(checkpoint, save_file_path + save_file_name)
	if error:
		printerr("Saving data failed!")
		printerr("Error code: " + str(error))

func load_game() -> void:
	if ResourceLoader.exists(save_file_path + save_file_name):
		checkpoint = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
		checkpoint_available = true
	else:
		print("No save data available")

func reset() -> void:
	# Reset variables
	# Player stats/variables
	checkpoint = Checkpoint.new()
	checkpoint_available = false
	checkpoint_loaded = false
	player_max_HP = 100
	player_HP = player_max_HP
	player_HP_regen = 0
	player_max_MP = 40
	player_MP = player_max_MP
	player_MP_regen = 1
	player_defence = 0
	player_attack_power = 0
	player_spellpower = 0
	player_temp_defence = 0
	player_temp_attack = 0
	player_temp_spell = 0
	player_accuracy = 1.0
	player_speed = 1.0
	player_item_damage_ratio = 1.0
	player_weapon_lifesteal = 0.0
	# Equipment slots
	player_weapon = null
	player_relic = null
	player_head = null
	player_chest = null
	player_arms = null
	player_legs = null
	# Relic bools
	lyra_obtained = false
	vandar_obtained = false
	amarok_obtained = false
	relics_collected = false
	rascal_obtained = false
	favor_active = false
	# Enemy stats/variables
	enemy_HP_multiplier = 1.0
	enemy_attack_multiplier = 1.0
	enemy_spell_multiplier = 1.0
	enemy_HP_scaling = 1.08 # Used to control exponential gains in enemy HP
	enemy_attack_scaling = 1.06 # Used to control exponential gains in enemy attack damage
	enemy_spell_scaling = 1.05 # Used to control exponential gains in enemy spell power
	enemy_id = -1 
	# Misc
	level = 1
	coins = 10
	shop_chance = 1.0 # The current chance, first is guaranteed
	event_chance = 0.2 # The current chance of finding an event
	event_recent = "" 
	ambush_seen = false
	gamble_seen = false
	grove_seen = false
	clear_storage()

func play_music(next_song:String, from:float = 0.0) -> void:
	if next_song == current_song: return
	current_song = next_song
	Music.stream = music[current_song]
	if from:
		Music.play(from)
	else:
		Music.play()

func set_level(level_num: int) -> void:
	for x in level_num - 1:
		level_up()

func set_coins(new_coins: int) -> void:
	if (coins + new_coins) > 0:
		coins = min(coin_limit, coins + new_coins)
	else:
		coins = 0

func set_stats_up(stat_changes: Array, equip_type: String) -> void:
	if equip_type == "armour":
		# 0: HP, 1: HP Regen, 2: MP, 3: MP Regen, 4: Defence, 5: Attack, 6: Spellpower
		var defaults: Array = [0,0,0,0,0,0,0] # Used to assure 7 stat assignments are always made
		if stat_changes.size() == defaults.size(): # Check if 7 stats were sent
			defaults = stat_changes
		else:
			for x in stat_changes.size():
				defaults[x] = stat_changes[x]
				if x >= defaults.size() - 1:
					break
		player_max_HP += defaults[0]
		if player_HP > player_max_HP:
			player_HP = player_max_HP
		player_HP_regen += defaults[1]
		player_max_MP += defaults[2]  
		if player_MP > player_max_MP:
			player_MP = player_max_MP
		player_MP_regen += defaults[3]
		player_defence += defaults[4]
		player_attack_power += defaults[5]
		player_spellpower += defaults[6]
	else:
		var defaults: Array = [0,0,0]
		if stat_changes.size() == defaults.size():
			defaults = stat_changes
		else:
			for x in stat_changes.size():
				defaults[x] = stat_changes[x]
				if x >= defaults.size() - 1:
					break
		player_defence += defaults[0]
		player_accuracy += defaults[1]
		player_speed += defaults[2]

func set_stats_down(stat_changes: Array, equip_type: String) -> void:
	if equip_type == "armour":
		# 0: HP, 1: HP Regen, 2: MP, 3: MP Regen, 4: Defence, 5: Attack, 6: Spellpower
		var defaults: Array = [0,0,0,0,0,0,0] # Used to assure 7 stat assignments are always made
		if stat_changes.size() == defaults.size(): # Check if 7 stats were sent
			defaults = stat_changes
		else:
			for x in stat_changes.size():
				defaults[x] = stat_changes[x]
				if x >= defaults.size() - 1:
					break
		player_max_HP -= defaults[0]
		if player_HP > player_max_HP:
			player_HP = player_max_HP
		player_HP_regen -= defaults[1]
		player_max_MP -= defaults[2]  
		if player_MP > player_max_MP:
			player_MP = player_max_MP
		player_MP_regen -= defaults[3]
		player_defence -= defaults[4]
		player_attack_power -= defaults[5]
		player_spellpower -= defaults[6]
	else:
		var defaults: Array = [0,0,0]
		if stat_changes.size() == defaults.size():
			defaults = stat_changes
		else:
			for x in stat_changes.size():
				defaults[x] = stat_changes[x]
				if x >= defaults.size() - 1:
					break
		player_defence -= defaults[0]
		player_accuracy -= defaults[1]
		player_speed -= defaults[2]

func level_up() -> void:
	level += 1 # Increase level variable
	if level > best_stage: 
		best_stage = level # Set a new stage record
		checkpoint.best_stage = best_stage
	if level < max_level:
		if level % 10 == 0:
			# Reduce scaling every 10 levels
			enemy_HP_scaling -= ((enemy_HP_scaling - 1.0) * enemy_scaling_reduction)
			enemy_attack_scaling -= ((enemy_attack_scaling - 1.0) * enemy_scaling_reduction)
			enemy_spell_scaling -= ((enemy_spell_scaling - 1.0) * enemy_scaling_reduction)
	else:
		if level % 10 == 0:
			# Increase scaling every 10 levels
			enemy_HP_scaling += ((enemy_HP_scaling - 1.0) * enemy_scaling_reduction)
			enemy_attack_scaling += ((enemy_attack_scaling - 1.0) * enemy_scaling_reduction)
			enemy_spell_scaling += ((enemy_spell_scaling - 1.0) * enemy_scaling_reduction)
	# Apply level scaling
	enemy_HP_multiplier *= enemy_HP_scaling
	enemy_attack_multiplier *= enemy_attack_scaling
	enemy_spell_multiplier *= enemy_spell_scaling

func store_rewards(new_loot: Array, new_coins: int) -> void:
	if new_coins:
		set_coins(new_coins) # Add rewarded coins to total
	# Add rewarded loot to storage
	var storage: Callable
	for loot in new_loot:
		storage = Callable(self, "store_" + loot.obj_name)
		storage.call(loot)

func store_item(item: Item) -> void:
	# Stores an item for it to be accessed globally
	if stored_items.size() < item_limit:
		stored_items.append(item) # Store item in GameManager
		item.storage_index = stored_items.size() - 1 # Attach the stored index to the item
	else:
		refresh_storage()
		item.queue_free()

func store_weapon(weapon: Weapon) -> void:
	# Stores a weapon for it to be accessed globally
	if stored_weapons.size() < weapon_limit:
		stored_weapons.append(weapon) # Store weapon in GameManager
		weapon.storage_index = stored_weapons.size() - 1 # Attach the stored index to the weapon
	else:
		refresh_storage()
		weapon.queue_free()

func store_magic(magic: Magic) -> void:
	# Stores a spell for it to be accessed globally
	if stored_magic.size() < magic_limit:
		stored_magic.append(magic) # Store spell in GameManager
		magic.storage_index = stored_magic.size() - 1 # Attach the stored index to the spell
	else:
		refresh_storage()
		magic.queue_free()

func store_armour(armour: Armour) -> void:
	# Stores a piece of armour for it to be accessed globally
	if stored_armour.size() < armour_limit:
		stored_armour.append(armour) # Store armour in GameManager
		armour.storage_index = stored_armour.size() - 1
	else:
		refresh_storage()
		armour.queue_free()

func store_relic(relic: Relic) -> void:
	# Stores a relic for it to be accessed globally
	if stored_relics.size() < relic_limit:
		stored_relics.append(relic) # Store relic in GameManager
		relic.storage_index = stored_relics.size() - 1
		match relic.name:
			"Mirror of Lyra":
				lyra_obtained = true
			"Amulet of Vandar":
				vandar_obtained = true
			"Jewel of Amarok":
				amarok_obtained = true
			"Favor of Rascal":
				rascal_obtained = true
		if lyra_obtained and vandar_obtained and amarok_obtained:
			relics_collected = true
	else:
		refresh_storage()
		relic.queue_free()

func equip_weapon(index: int) -> void:
	# Checks if a weapon is already equipped
	if is_instance_valid(player_weapon):
		player_weapon.is_equipped = false # Tells the weapon it's not equipped anymore
	player_weapon = stored_weapons[index] # Equips the new weapon
	player_weapon.is_equipped = true

func equip_relic(index: int) -> void:
	# Checks if a relic is already equipped
	if is_instance_valid(player_relic):
		player_relic.is_equipped = false
		set_stats_down(player_relic.get_stats(), player_relic.obj_name)
	player_relic = stored_relics[index]
	player_relic.is_equipped = true
	set_stats_up(player_relic.get_stats(), player_relic.obj_name)

func equip_armour(index: int) -> void:
	match stored_armour[index].slot:
		"head":
			# Remove currently-equipped head armour, if one exists
			if is_instance_valid(player_head):
				player_head.is_equipped = false
				set_stats_down(player_head.get_stats(), player_head.obj_name)
			player_head = stored_armour[index]
			player_head.is_equipped = true
			set_stats_up(player_head.get_stats(), player_head.obj_name)
		"chest":
			# Remove currently-equipped chest armour, if one exists
			if is_instance_valid(player_chest):
				player_chest.is_equipped = false
				set_stats_down(player_chest.get_stats(), player_chest.obj_name)
			player_chest = stored_armour[index]
			player_chest.is_equipped = true
			set_stats_up(player_chest.get_stats(), player_chest.obj_name)
		"arms":
			# Remove currently-equipped arm armour, if one exists
			if is_instance_valid(player_arms):
				player_arms.is_equipped = false
				set_stats_down(player_arms.get_stats(), player_arms.obj_name)
			player_arms = stored_armour[index]
			player_arms.is_equipped = true
			set_stats_up(player_arms.get_stats(), player_arms.obj_name)
		"legs":
			# Remove currently-equipped leg armour, if one exists
			if is_instance_valid(player_legs):
				player_legs.is_equipped = false
				set_stats_down(player_legs.get_stats(), player_legs.obj_name)
			player_legs = stored_armour[index]
			player_legs.is_equipped = true
			set_stats_up(player_legs.get_stats(), player_legs.obj_name)
		_:
			printerr("ERROR: Armour slot type not found for " + stored_armour[index].name + " in equip_armour()")

func unequip_weapon() -> void:
	# Unequip current weapon
	if is_instance_valid(player_weapon):
		player_weapon.is_equipped = false # Tells the weapon it's not equipped anymore
	player_weapon = null # Removes weapon from slot

func unequip_relic() -> void:
	# Unequip current relic
	if is_instance_valid(player_relic):
		player_relic.is_equipped = false # Tells the relic it's not equipped anymore
		set_stats_down(player_relic.get_stats(), player_relic.obj_name)
	player_relic = null # Removes relic from slot

func unequip_armour(slot: String) -> void:
	match slot:
		"head":
			# Remove currently-equipped head armour, if one exists
			if is_instance_valid(player_head):
				player_head.is_equipped = false
				set_stats_down(player_head.get_stats(), player_head.obj_name)
			player_head = null
		"chest":
			# Remove currently-equipped chest armour, if one exists
			if is_instance_valid(player_chest):
				player_chest.is_equipped = false
				set_stats_down(player_chest.get_stats(), player_chest.obj_name)
			player_chest = null
		"arms":
			# Remove currently-equipped arm armour, if one exists
			if is_instance_valid(player_arms):
				player_arms.is_equipped = false
				set_stats_down(player_arms.get_stats(), player_arms.obj_name)
			player_arms = null
		"legs":
			# Remove currently-equipped leg armour, if one exists
			if is_instance_valid(player_legs):
				player_legs.is_equipped = false
				set_stats_down(player_legs.get_stats(), player_legs.obj_name)
			player_legs = null
		_:
			printerr("ERROR: Armour slot type not found for unequip_armour()")

func get_item(index: int) -> Item:
	return stored_items[index]

func get_weapon(index: int) -> Weapon:
	return stored_weapons[index]

func get_magic(index: int) -> Magic:
	return stored_magic[index]

func get_armour(index: int) -> Armour:
	return stored_armour[index]
	
func get_relic(index: int) -> Relic:
	return stored_relics[index]

func get_prefix() -> String:
	# Get enemy prefix based on stage
	if level < 100:
		if level < 50:
			if level < 30:
				if level < 10:
					return "" # 1-9
				elif level < 20:
					return "Big\n" # 10-19
				else:
					return "Mighty\n" # 20-29
			elif level < 40:
				return "Spiteful\n" # 30-39
			else:
				return "Evil\n" # 40-49
		else:
			if level < 80:
				if level < 60:
					if level == 50:
						return "Shade of\nThe " # Mini Boss at 50
					else:
						return "Powerful\n" # 51-59
				elif level < 70:
					return "Supreme\n" # 60-69
				else:
					return "Terror\n" # 70-79
			elif level < 90:
				return "Almighty\n" # 80-89
			else:
				return "Final\n" # 90-99
	elif level == 100:
		return "The Phantom\n" # Final Boss at 100
	else:
		return "Immortal\n" # Endless stages

func get_quality_colour(quality: int) -> Color:
	match quality:
		1:
			return Color.WHITE
		2:
			return Color.GREEN
		3:
			return Color.DEEP_SKY_BLUE
		4:
			return Color.DARK_MAGENTA
		5:
			return Color.DARK_ORANGE
		6:
			return Color.CRIMSON
		_:
			return Color.WHITE

func get_quality_name(quality: int) -> String:
	match quality:
		1:
			return "white"
		2:
			return "green"
		3:
			return "deep_sky_blue"
		4:
			return "dark_magenta"
		5:
			return "dark_orange"
		6:
			return "crimson"
		_:
			return "white"

func get_enemy_id() -> int:
	if forced_enemy_id != -1:
		enemy_id = -1
		return forced_enemy_id
	if level < 100:
		if level < 50:
			if level < 30:
				if level < 10:
					return randi_range(0,2) # 1-9
				elif level < 20:
					return randi_range(0,4) # 10-19
				else:
					return randi_range(0,5) # 20-29
			elif level < 40:
				return randi_range(0,6) # 30-39
			else:
				return randi_range(3,7) # 40-49
		else:
			if level < 80:
				if level < 60:
					if level == 50:
						return 15 # Middle boss
					else:
						return randi_range(4,8) # 51-59
				elif level < 70:
					return randi_range(6,10) # 60-69
				else:
					return randi_range(7,11) # 70-79
			elif level < 90:
				return randi_range(8,12) # 80-89
			else:
				return randi_range(11,14) # 90-99
	elif level == 100:
		return 16 # Final boss
	else:
		return randi_range(0,14) # Extra stages

func create_defaults() -> void:
	store_item(create_item(0))
	store_magic(create_magic(0))
	store_weapon(create_weapon(0))
	equip_weapon(0)

func create_all() -> void:
	for x in usable_items.size():
		store_item(create_item(x))
	for x in magic_spells.size():
		store_magic(create_magic(x))
	for x in armour_pieces.size():
		store_armour(create_armour(x))
	for x in relics.size():
		store_relic(create_relic(x))
	for x in weapons.size():
		store_weapon(create_weapon(x))

func create_item(id: int) -> Item:
	# Returns a new item instance and uses an ID to populate it from the usable_items dictionary
	var item_name: String = usable_items[id]["name"]
	var power: int = usable_items[id]["power"]
	var type: String = usable_items[id]["type"]
	var duration: int = usable_items[id]["duration"]
	var uses: int = usable_items[id]["uses"]
	var buy_price: int = usable_items[id]["price"]
	var icon: CompressedTexture2D = usable_items[id]["icon"]
	var anim: String = usable_items[id]["anim"]
	var tooltip: String
	if duration == 0:
		if uses == -1:
			tooltip = "%s\n%s: %d\nUnlimited" % [item_name, type, power]
		else:
			tooltip = "%s\n%s: %d\nUses left: %d" % [item_name, type, power, uses]
	else:
		if uses == -1:
			tooltip = "%s\n%s: %d\nDuration: %d" % [item_name, type, power, duration]
		else:
			tooltip = "%s\n%s: %d\nDuration: %d\nUses left: %d" % [item_name, type, power, duration, uses]
	return Item.new(item_name, power, type, duration, uses, buy_price, id, icon, tooltip, anim)

func create_skill(id: int) -> Skill:
	# Returns a new skill instance and uses an ID to populate it from the weapon_skills dictionary
	var skill_name: String = weapon_skills[id]["name"]
	var power: int = weapon_skills[id]["power"]
	var type: String = weapon_skills[id]["type"]
	var duration: int = weapon_skills[id]["duration"]
	var icon: CompressedTexture2D = weapon_skills[id]["icon"]
	var tooltip: String
	if duration == 0:
		tooltip = "%s\n%s: %d" % [skill_name, type, power]
	else:
		tooltip = "%s\n%s: %d\nDuration: %d" % [skill_name, type, power, duration]
	return Skill.new(skill_name, power, type, duration, id, icon, tooltip)

func create_weapon(id: int) -> Weapon:
	# Returns a new weapon object and uses an ID to populate it from the weapons dictionary
	var weapon_name: String = weapons[id]["name"]
	var buy_price: int = weapons[id]["price"]
	var quality: int = weapons[id]["quality"]
	var icon: CompressedTexture2D = weapons[id]["icon"]
	# Finds out how many skills the weapon should have
	var skill_ids: Array = weapons[id]["skills"]
	var skills: Array = []
	var tooltip: String = "[color=%s]%s[/color]\nSlot: Weapon\n-Skills-\n" % [get_quality_name(quality), weapon_name]
	for skill_id in skill_ids:
		skills.append(create_skill(skill_id)) # Adds the skills one by one until the total is reached
		tooltip += skills[-1].name + "\n" # Add each skill name to tooltip
	return Weapon.new(weapon_name, buy_price, id, quality, skills, icon, tooltip)

func create_magic(id: int) -> Magic:
	# Returns a new magic object and uses an ID to populate it from the magic_spells dictionary
	var spell_name: String = magic_spells[id]["name"]
	var power: int = magic_spells[id]["power"]
	var type: String = magic_spells[id]["type"]
	var duration: int = magic_spells[id]["duration"]
	var cost: int = magic_spells[id]["cost"]
	var buy_price: int = magic_spells[id]["price"]
	var icon: CompressedTexture2D = magic_spells[id]["icon"]
	var tooltip: String
	if duration == 0:
		tooltip = "[color=green]%s[/color]\n%s: %d\nMP Cost: %d" % [spell_name, type, power, cost]
	else:
		tooltip = "[color=green]%s[/color]\n%s: %d\nMP Cost: %d\nDuration: %d" % [spell_name, type, power, cost, duration]
	return Magic.new(spell_name, power, type, duration, cost, buy_price, id, icon, tooltip)

func create_armour(id: int) -> Armour:
	var armour_name: String = armour_pieces[id]["name"]
	var stats: Array = armour_pieces[id]["stats"]
	var slot: String = armour_pieces[id]["slot"]
	var quality: int = armour_pieces[id]["quality"]
	var price: int = armour_pieces[id]["price"]
	var icon: CompressedTexture2D = armour_pieces[id]["icon"]
	var tooltip: String = "[color=%s]%s[/color]\nSlot: %s" % [get_quality_name(quality), armour_name, slot]
	for x in stats.size():
		if stats[x] > 0:
			match x:
				0:
					tooltip += "\nHP: "
				1:
					tooltip += "\nHP Regen: "
				2:
					tooltip += "\nMP: "
				3:
					tooltip += "\nMP Regen: "
				4:
					tooltip += "\nDefence: "
				5:
					tooltip += "\nAttack: "
				6:
					tooltip += "\nSpell: "
			tooltip += "[color=green]+%d[/color]" % [stats[x]]
	return Armour.new(armour_name, stats, slot, id, quality, price, icon, tooltip)

func create_relic(id: int) -> Relic:
	# Get the item variables
	var relic_name: String = relics[id]["name"]
	var stats: Array = relics[id]["stats"]
	var price: int = relics[id]["price"]
	var quality: int = relics[id]["quality"]
	var icon: CompressedTexture2D = relics[id]["icon"]
	# Get the spell variables
	var spell_id: int = relics[id]["spell"]
	var spell_name: String = relic_spells[spell_id]["name"]
	var power: float = relic_spells[spell_id]["power"]
	var cost: int = relic_spells[spell_id]["cost"]
	var type: String = relic_spells[spell_id]["type"]
	var duration: int = relic_spells[spell_id]["duration"]
	var spell_tooltip: String = "[color=%s]%s[/color]" % [get_quality_name(quality), spell_name]
	match spell_name:
		"Lyra's Misery":
			spell_tooltip += "\nAccuracy: -%d%%\nSpeed: -%d%%" % [power * 100, power * 100]
		"Vandar's Fury":
			spell_tooltip += "\nItem dmg: +%d%%" % [power * 100]
		"Amarok's Thirst":
			spell_tooltip += "\nWeapon life steal: +%d%%" % [power * 100]
		"Phylactery Buster":
			spell_tooltip += "\n???"
	spell_tooltip += "\nMP Cost: %d\nDuration: %d" % [cost, duration]
	var spell: Magic = Magic.new(spell_name, power, type, duration, cost, 0, spell_id, icon, spell_tooltip)
	var relic_tooltip: String = "[color=%s]%s[/color]\nSlot: Relic" % [get_quality_name(quality), relic_name]
	for x in stats.size():
		if stats[x] > 0:
			match x:
				0:
					relic_tooltip += "\nDefence: "
					relic_tooltip += "[color=green]+%d[/color]" % [stats[x]]
				1:
					relic_tooltip += "\nAccuracy: "
					relic_tooltip += "[color=green]+%d%%[/color]" % [stats[x] * 100]
				2:
					relic_tooltip += "\nSpeed: "
					relic_tooltip += "[color=green]+%d%%[/color]" % [stats[x] * 100]
	relic_tooltip += "\n-Spell-\n%s" % [spell_name]
	if relic_name == "Favor of Rascal":
		relic_tooltip += "\n\n[color=crimson]It seems to hold latent lich-slaying power...[/color]"
	return Relic.new(relic_name, stats, price, quality, id, icon, relic_tooltip, spell)

func create_action(id: int) -> Action:
	# Creates an action for an enemy to use
	var action_name: String = enemy_actions[id]["name"]
	var type: String = enemy_actions[id]["type"]
	var power: float = enemy_actions[id]["power"]
	var duration: int = enemy_actions[id]["duration"]
	return Action.new(action_name, type, power, duration, id)

func create_enemy(id: int) -> Enemy:
	# Creates an enemy to face in battle
	var enemy_name: String = enemies[id]["name"]
	var prefix: String = get_prefix()
	var type: String = enemies[id]["type"]
	var HP: float = enemy_HP_multiplier
	var attack_power: float = enemy_attack_multiplier
	var spellpower: float = enemy_spell_multiplier
	var action_ids: Array = enemies[id]["actions"]
	var actions: Array[Action] = []
	for action_id in action_ids:
		actions.append(create_action(action_id))
	return Enemy.new(enemy_name, prefix, type, HP, attack_power, spellpower, actions, id)

func create_status(new_name: String, power: float, type: String, duration: int, target: String) -> Status:
	var tooltip: String
	var icon: CompressedTexture2D
	var is_buff: bool = true
	match type:
		"HP regen":
			tooltip = "%s\n+%d HP/turn" % [new_name, power]
			icon = icons["heart"]
		"bleeding":
			tooltip = "%s\n-%d HP/turn" % [new_name, power]
			icon = icons["small_sword_bloody"]
			is_buff = false
		"burning":
			tooltip = "%s\n-%d HP/turn" % [new_name, power]
			icon = icons["fire1"]
			is_buff = false
		"MP regen":
			tooltip = "%s\n+%d MP/turn" % [new_name, power]
			icon = icons["juice"]
		"MP degen":
			tooltip = "%s\n-%d MP/turn" % [new_name, power]
			icon = icons["ice"]
			is_buff = false
		"defence up":
			tooltip = "%s\n+%d defence" % [new_name, power]
			icon = icons["shield"]
		"defence down":
			tooltip = "%s\n-%d defence" % [new_name, power]
			icon = icons["shield_cracked"]
			is_buff = false
		"speed up":
			tooltip = "%s\n+%d%% speed" % [new_name, power * 100]
			icon = icons["speed_up"]
		"speed down":
			tooltip = "%s\n-%d%% speed" % [new_name, power * 100]
			icon = icons["speed_down"]
			is_buff = false
		"accuracy up":
			tooltip = "%s\n+%d%% hit chance" % [new_name, power * 100]
			icon = icons["acc_up"]
		"accuracy down":
			tooltip = "%s\n-%d%% hit chance" % [new_name, power * 100]
			icon = icons["acc_down"]
			is_buff = false
		"disable weapon":
			tooltip = "%s\nWeapon skills disabled" % [new_name]
			icon = icons["skull"]
			is_buff = false
		"disable magic":
			tooltip = "%s\nMagic spells disabled" % [new_name]
			icon = icons["skull"]
			is_buff = false
		"disable items":
			tooltip = "%s\nItems disabled" % [new_name]
			icon = icons["skull"]
			is_buff = false
		"lyra":
			tooltip = "%s\n-%d%% hit chance\n-%d%% speed" % [new_name, power * 100, power * 100]
			icon = icons["mirror"]
			is_buff = false
		"vandar":
			tooltip = "%s\n+%d%% item dmg" % [new_name, power * 100]
			icon = icons["amulet"]
		"amarok":
			tooltip = "%s\n+%d%% weapon lifesteal" % [new_name, power * 100]
			icon = icons["jewel"]
		"rascal":
			tooltip = "Rascal's Barrier\nImmunity to Azurefire"
			icon = icons["favor"]
		_:
			printerr("ERROR: status type not found in create_status")
	return Status.new(new_name, power, type, duration, target, is_buff, icon, tooltip)

func update_item_tooltip(item: Item) -> void:
	if item.duration == 0:
		if item.uses == -1:
			item.tooltip = "%s\n%d %s" % [item.name, item.power, item.type]
		else:
			item.tooltip = "%s\n%d %s\nUses left: %d" % [item.name, item.power, item.type, item.uses]
	else:
		if item.uses == -1:
			item.tooltip = "%s\n%d %s\nDuration: %d" % [item.name, item.power, item.type, item.duration]
		else:
			item.tooltip = "%s\n%d %s\nDuration: %d\nUses left: %d" % [item.name, item.power, item.type, item.duration, item.uses]

func generate_coins(coin_multiplier: float = 1.0) -> int:
	# Set the highest and lowest of the random coin reward
	var coin_max: int = round(coin_reward_base + (coin_reward_base * coin_reward_range))
	var coin_min: int = round(coin_reward_base - (coin_reward_base * coin_reward_range))
	# Randomise the amount of coins rewarded between the max and min
	var new_coins: int = randi_range(coin_min,coin_max)
	# Scale the coin reward based on level
	return round(max(new_coins, round((new_coins + level) * coin_reward_scaling)) * coin_multiplier)

func generate_loot(extra_loot: int = 0, chance_multiplier: float = 1.0) -> Array:
	var loot: Array = [] # Holds the generated loot
	var loot_amount: int = randi_range(min_loot,max_loot) + extra_loot # Randomises the amount of loot created
	var loot_chance: int # Stores a random number to decide which loot is obtained
	var selected: int = -1 # Variable used to determine which items are picked
	var add_armour: bool = false
	var add_relic: bool = false
	if armour_loot_chance * chance_multiplier >= randf():
		add_armour = true
	if relic_loot_chance * chance_multiplier >= randf() and not relics_collected:
		add_relic = true
	# Generate any special loot and then fill rest with random items based on level
	for x in loot_amount:
		if add_relic:
			var copy_found: bool = true
			while copy_found:
				copy_found = false
				selected = randi_range(0,2)
				for relic in stored_relics:
					if relic.id == selected:
						copy_found = true
			loot.append(create_relic(selected))
			add_relic = false
		elif add_armour:
			if level < 11: # Select a random quality 1 armour piece
				selected = randi_range(0,3)
			elif level < 21: # Select a random quality 1 or 2 armour piece
				selected = randi_range(0,7)
			elif level < 41: # Select a random quality 2 armour piece
				selected = randi_range(4,11)
			elif level < 61: # Select a random quality 3 armour piece
				selected = randi_range(12,19)
			elif level < 81: # Select a random quality 3 or 4 armour piece
				selected = randi_range(12,23)
			elif level < 91: # Select a random quality 4 or 5 armour piece
				selected = randi_range(20,27)
			else: # Select a random quality 5 armour piece
				selected = randi_range(24,27)
			loot.append(create_armour(selected))
			add_armour = false
		else:
			loot_chance = randi() % round(((max_level * max_level) / level) + 1)
			if level < loot_chance: # Select an early-game item
				selected = randi_range(1,4)
			else: # Select a late-game item
				selected = randi_range(5,10)
			loot.append(create_item(selected))
	return loot

func generate_stock() -> Array:
	var stock: Array = [] # Holds the stock
	var stock_chance: int # Used to adjust odds of early or late stage stocking
	# Create the number of stock to display between min and max stock
	var stock_amount: int = randi_range(min_stock,max_stock)
	var add_weapon: bool = false # Should a weapon be added to stock?
	var magic_to_stock: int = 0 # How many spells should be added to stock
	var armour_to_stock: int = 0 # How many armour pieces should be added to stock
	var weapon: Weapon
	var magic: Magic
	var armour: Armour
	var item: Item
	var replacement_items: int = 0 # Additional items added to fill stock when duplicates occur
	var selected: int # The ID selected to be added to the stock
	if weapon_stock_chance >= randf(): # Randomly decide if a weapon should be added
		add_weapon = true
	for x in magic_stock_max: # Randomly decide how many spells should be added
		if magic_stock_chance >= randf():
			magic_to_stock += 1
	for x in armour_stock_max: # Randomly decide how many armour pieces should be added
		if armour_stock_chance >= randf():
			armour_to_stock += 1
	# Stocks Favor of Rascal if all other relics are obtained
	if relics_collected and not rascal_obtained:
		stock.append(create_relic(3))
	# Generate the set amount of stock
	for x in stock_amount:
		# Add a weapon to the stock
		if add_weapon:
			var best_weapon_owned: int = 0
			for owned in stored_weapons:
				if owned.id > best_weapon_owned:
					best_weapon_owned = owned.id
			if best_weapon_owned == 0:
				selected = 1
			elif best_weapon_owned == 1 and level > 25:
				selected = 2
			elif best_weapon_owned == 2 and level > 50:
				selected = 3
			elif best_weapon_owned == 3 and level > 75:
				selected = 4
			else:
				selected = -1
			if selected != -1: # Stock the weapon if no copies found in player storage
				weapon = create_weapon(selected)
				stock.append(weapon)
				weapon.storage_index = stock.size() - 1
			else: # If duplicate weapon is found, skip stocking
				replacement_items += 1
			add_weapon = false
		# Add amount of magic to the stock
		elif magic_to_stock > 0: 
			stock_chance = randi() % round(((max_level * max_level) / level) + 1)
			var options: Array = []
			if level < stock_chance: # Select a random early-game spell
				options = range(1,5)
			else: # Select a random early or late game spell
				options = range(1,11)
			for y in stored_magic.size(): # Prevents seeing a spell that's already owned
				if stored_magic[y].id in options:
					options.erase(stored_magic[y].id)
			for y in stock.size(): # Prevents stocking the same spell twice
				if stock[y].obj_name == "magic" and stock[y].id in options:
					options.erase(stock[y].id)
			if options: # If there's still options left, pick one at random and add it to stock
				magic = create_magic(options.pick_random())
				stock.append(magic)
				magic.storage_index = stock.size() - 1
				magic_to_stock -= 1
			else: # If no options left, prevent stocking anymore magic and replace this failed instance with an item
				magic_to_stock = 0
				replacement_items += 1
		# Add amount of armour to the stock
		elif armour_to_stock > 0: 
			var options: Array = []
			if level < 11: # Select a random quality 1 armour piece
				options = range(0,3)
			elif level < 21: # Select a random quality 1 or 2 armour piece
				options = range(0,7)
			elif level < 41: # Select a random quality 2 armour piece
				options = range(4,11)
			elif level < 61: # Select a random quality 3 armour piece
				options = range(12,19)
			elif level < 81: # Select a random quality 3 or 4 armour piece
				options = range(12,23)
			elif level < 91: # Select a random quality 4 or 5 armour piece
				options = range(20,27)
			else: # Select a random quality 5 armour piece
				options = range(24,27)
			for y in stored_armour.size(): # Prevents seeing a spell that's already owned
				if stored_armour[y].id in options:
					options.erase(stored_armour[y].id)
			for y in stock.size(): # Prevents stocking the same spell twice
				if stock[y].obj_name == "armour" and stock[y].id in options:
					options.erase(stock[y].id)
			if options: # If there's still options left, pick one at random and add it to stock
				armour = create_armour(options.pick_random())
				stock.append(armour)
				armour.storage_index = stock.size() - 1
				armour_to_stock -= 1
			else: # If no options left, prevent stocking anymore armour and replace this failed instance with an item
				armour_to_stock = 0
				replacement_items += 1
		# Fill remaining stock space with items
		else: 
			stock_chance = randi() % round(((max_level * max_level ) / level) + 1)
			if level < stock_chance: # Select an early-game item
				selected = randi_range(1,4)
			else: # Select a late-game item
				selected = randi_range(5,10)
			item = create_item(selected)
			stock.append(item)
			item.storage_index = stock.size() - 1
	# Add an additional item for each duplicate removed
	for x in replacement_items: 
		stock_chance = randi() % round(((max_level * max_level ) / level) + 1)
		if level < stock_chance: # Select an early-game item
			selected = randi_range(1,4)
		else: # Select a late-game item
			selected = randi_range(5,10)
		item = create_item(selected)
		stock.append(item)
		item.storage_index = stock.size() - 1
	return stock

func clear_storage() -> void:
	# Clear weapons
	for weapon in stored_weapons:
		if is_instance_valid(weapon):
			weapon.free()
	stored_weapons.clear()
	# Clear items
	for item in stored_items:
		if is_instance_valid(item):
			item.free()
	stored_items.clear()
	# Clear magic
	for spell in stored_magic:
		if is_instance_valid(spell):
			spell.free()
	stored_magic.clear()
	# Clear armour
	for armour in stored_armour:
		if is_instance_valid(armour):
			armour.free()
	stored_armour.clear()
	# Clear relics
	for relic in stored_relics:
		if is_instance_valid(relic):
			relic.free()
	stored_relics.clear()

func refresh_storage() -> void:
	# A cleanup function that can be used at the end of a scene to remove null instances
	var clear_list: Array = []
	# Cleanup stored items
	for x in stored_items.size():
		if not is_instance_valid(stored_items[x]):
			clear_list.push_front(x)
	for x in clear_list:
		stored_items.remove_at(x)
	clear_list.clear()
	for x in stored_items.size():
		stored_items[x].storage_index = x
	# Cleanup stored magic
	for x in stored_magic.size():
		if not is_instance_valid(stored_magic[x]):
			clear_list.push_front(x)
	for x in clear_list:
		stored_magic.remove_at(x)
	clear_list.clear()
	for x in stored_magic.size():
		stored_magic[x].storage_index = x
	# Cleanup stored weapons
	for x in stored_weapons.size():
		if not is_instance_valid(stored_weapons[x]):
			clear_list.push_front(x)
	for x in clear_list:
		stored_weapons.remove_at(x)
	clear_list.clear()
	for x in stored_weapons.size():
		stored_weapons[x].storage_index = x
	# Cleanup stored armour
	for x in stored_armour.size():
		if not is_instance_valid(stored_armour[x]):
			clear_list.push_front(x)
	for x in clear_list:
		stored_armour.remove_at(x)
	clear_list.clear()
	for x in stored_armour.size():
		stored_armour[x].storage_index = x
	# Cleanup stored relics
	for x in stored_relics.size():
		if not is_instance_valid(stored_relics[x]):
			clear_list.push_front(x)
	for x in clear_list:
		stored_relics.remove_at(x)
	clear_list.clear()
	for x in stored_relics.size():
		stored_relics[x].storage_index = x

func refresh_equipped() -> void:
	# Cleanup equipped gear
	if not is_instance_valid(player_weapon):
		player_weapon = null
	if not is_instance_valid(player_relic):
		player_relic = null
	if not is_instance_valid(player_head):
		player_head = null
	if not is_instance_valid(player_chest):
		player_chest = null
	if not is_instance_valid(player_arms):
		player_arms = null
	if not is_instance_valid(player_legs):
		player_legs = null

func save_checkpoint() -> void:
	# Save globals
	checkpoint.player_max_HP = player_max_HP
	checkpoint.player_HP = player_HP
	checkpoint.player_HP_regen = player_HP_regen
	checkpoint.player_max_MP = player_max_MP
	checkpoint.player_MP = player_MP
	checkpoint.player_MP_regen = player_MP_regen
	checkpoint.player_defence = player_defence
	checkpoint.player_attack_power = player_attack_power
	checkpoint.player_spellpower = player_spellpower
	checkpoint.player_accuracy = player_accuracy
	checkpoint.player_speed = player_speed
	checkpoint.lyra_obtained = lyra_obtained
	checkpoint.vandar_obtained = vandar_obtained
	checkpoint.amarok_obtained = amarok_obtained
	checkpoint.relics_collected = relics_collected
	checkpoint.rascal_obtained = rascal_obtained
	checkpoint.enemy_HP_multiplier = enemy_HP_multiplier
	checkpoint.enemy_attack_multiplier = enemy_attack_multiplier
	checkpoint.enemy_spell_multiplier = enemy_spell_multiplier
	checkpoint.enemy_HP_scaling = enemy_HP_scaling
	checkpoint.enemy_attack_scaling = enemy_attack_scaling
	checkpoint.enemy_spell_scaling = enemy_spell_scaling
	checkpoint.enemy_id = enemy_id
	checkpoint.level = level
	checkpoint.coins = coins
	checkpoint.shop_chance = shop_chance
	checkpoint.event_chance = event_chance
	checkpoint.event_recent = event_recent
	checkpoint.ambush_seen = ambush_seen
	checkpoint.gamble_seen = gamble_seen
	checkpoint.grove_seen = grove_seen
	# Save node data
	save_weapons()
	save_items()
	save_magic()
	save_armour()
	save_relics()
	# Enable use of checkpoint
	checkpoint_available = true

func save_weapons() -> void:
	# Clear any previous checkpoint weapons
	checkpoint.stored_weapons.clear()
	# Save weapon data
	for weapon in stored_weapons:
		checkpoint.stored_weapons.append(weapon.get_data())

func save_items() -> void:
	# Clear any previous checkpoint items
	checkpoint.stored_items.clear()
	# Save item data
	for item in stored_items:
		checkpoint.stored_items.append(item.get_data())

func save_magic() -> void:
	# Clear any previous checkpoint magic
	checkpoint.stored_magic.clear()
	# Save magic data
	for magic in stored_magic:
		checkpoint.stored_magic.append(magic.get_data())

func save_armour() -> void:
	# Clear any previous checkpoint armour
	checkpoint.stored_armour.clear()
	# Save armour data
	for armour in stored_armour:
		checkpoint.stored_armour.append(armour.get_data())

func save_relics() -> void:
	# Clear any previous checkpoint relics
	checkpoint.stored_relics.clear()
	# Save relic data
	for relic in stored_relics:
		checkpoint.stored_relics.append(relic.get_data())

func load_checkpoint() -> void:
	# Clean up previous loaded data
	clear_storage()
	refresh_equipped()
	# Load globals
	best_stage = checkpoint.best_stage
	player_max_HP = checkpoint.player_max_HP
	player_HP = checkpoint.player_HP
	player_HP_regen = checkpoint.player_HP_regen
	player_max_MP = checkpoint.player_max_MP
	player_MP = checkpoint.player_MP
	player_MP_regen = checkpoint.player_MP_regen
	player_defence = checkpoint.player_defence
	player_attack_power = checkpoint.player_attack_power
	player_spellpower = checkpoint.player_spellpower
	player_accuracy = checkpoint.player_accuracy
	player_speed = checkpoint.player_speed
	lyra_obtained = checkpoint.lyra_obtained
	vandar_obtained = checkpoint.vandar_obtained
	amarok_obtained = checkpoint.amarok_obtained
	relics_collected = checkpoint.relics_collected
	rascal_obtained = checkpoint.rascal_obtained
	enemy_HP_multiplier = checkpoint.enemy_HP_multiplier
	enemy_attack_multiplier = checkpoint.enemy_attack_multiplier
	enemy_spell_multiplier = checkpoint.enemy_spell_multiplier
	enemy_HP_scaling = checkpoint.enemy_HP_scaling
	enemy_attack_scaling = checkpoint.enemy_attack_scaling
	enemy_spell_scaling = checkpoint.enemy_spell_scaling
	enemy_id = checkpoint.enemy_id
	level = checkpoint.level
	coins = checkpoint.coins
	shop_chance = checkpoint.shop_chance
	event_chance = checkpoint.event_chance
	event_recent = checkpoint.event_recent
	ambush_seen = checkpoint.ambush_seen
	gamble_seen = checkpoint.gamble_seen
	grove_seen = checkpoint.grove_seen
	# Load nodes
	load_weapons()
	load_items()
	load_magic()
	load_armour()
	load_relics()
	checkpoint_loaded = true

func load_weapons() -> void:
	# Restore weapons and equip
	for data in checkpoint.stored_weapons:
		var skills: Array[Skill] = []
		for skill_data in data.skills:
			var skill: Skill = Skill.new(skill_data.data_name, skill_data.power, skill_data.type, skill_data.duration, skill_data.id, skill_data.icon, skill_data.tooltip)
			skill.display_index = skill_data.display_index
			skills.append(skill)
		var weapon: Weapon = Weapon.new(data.data_name, data.buy_price, data.id, data.quality, skills, data.icon, data.tooltip)
		weapon.is_equipped = data.is_equipped
		weapon.storage_index = data.storage_index
		weapon.display_index = data.display_index
		stored_weapons.append(weapon)
	for weapon in stored_weapons:
		if weapon.is_equipped:
			player_weapon = weapon
			break

func load_items() -> void:
	# Restore items
	for data in checkpoint.stored_items:
		var item: Item = Item.new(data.data_name, data.power, data.type, data.duration, data.uses, data.buy_price, data.id, data.icon, data.tooltip, data.anim)
		item.storage_index = data.storage_index
		item.display_index = data.display_index
		stored_items.append(item)

func load_magic() -> void:
	# Restore magic
	for data in checkpoint.stored_magic:
		var magic: Magic = Magic.new(data.data_name, data.power, data.type, data.duration, data.cost, data.buy_price, data.id, data.icon, data.tooltip)
		magic.storage_index = data.storage_index
		magic.display_index = data.display_index
		stored_magic.append(magic)

func load_armour() -> void:
	# Restore armour and equip
	for data in checkpoint.stored_armour:
		var armour: Armour = Armour.new(data.data_name, data.stats, data.slot, data.id, data.quality, data.buy_price, data.icon, data.tooltip)
		armour.storage_index = data.storage_index
		armour.display_index = data.display_index
		armour.is_equipped = data.is_equipped
		stored_armour.append(armour)
	for armour in stored_armour:
		if armour.is_equipped:
			match armour.slot:
				"head":
					player_head = armour
				"chest":
					player_chest = armour
				"arms":
					player_arms = armour
				"legs":
					player_legs = armour
			if player_head and player_chest and player_arms and player_legs:
				break

func load_relics() -> void:
	# Restore relics and equip
	for data in checkpoint.stored_relics:
		var spell: Magic = Magic.new(
			data.spell.data_name, data.spell.power, data.spell.type, data.spell.duration, data.spell.cost, 
			data.spell.buy_price, data.spell.id, data.spell.icon, data.spell.tooltip
		)
		spell.storage_index = data.spell.storage_index
		spell.display_index = data.spell.display_index
		var relic: Relic = Relic.new(data.data_name, data.stats, data.buy_price, data.quality, data.id, data.icon, data.tooltip, spell)
		relic.storage_index = data.storage_index
		relic.display_index = data.display_index
		relic.is_equipped = data.is_equipped
		stored_relics.append(relic)
	for relic in stored_relics:
		if relic.is_equipped:
			player_relic = relic
			break
