extends Node

# probably super messy, but hopefully it's less time consuming then before? - luggi
# with how its coded atm team names can be either all lower case or upper case
# this should probably become a global class so people can append to it like a custom status


var ballInfo = {
	"res://Balls/Fighters/Axom/ball_axom.tscn" : "AXOM",
	"res://Balls/Fighters/Hong/ball_hong.tscn" : "HONG",
	"res://Balls/Fighters/Kordell/ball_kordell.tscn" : "KORDELL",
	"res://Balls/Fighters/Okina/ball_okina.tscn" : "OKINA",
	"res://Balls/Fighters/Jane/ball_jane.tscn" : "JANE",
	"res://Balls/Fighters/Somnia/ball_somnia.tscn" : "SOMNIA",
	"res://Balls/Fighters/Thong/ball_thong.tscn" : "THONG",
	"res://Balls/Fighters/Vee/ball_vee.tscn" : "VEE",
	"res://Balls/Fighters/Hiro/ball_hiro.tscn" : "HIRO",
	"res://Balls/Fighters/Beta/ball_beta.tscn" : "BETA",
	"res://Balls/Fighters/T7/ball_t7.tscn" : "T7",
	"res://Balls/Fighters/Phil/ball_phil.tscn" : "PHIL",
	"res://Balls/Fighters/Katie/ball_katie.tscn" : "KATIE",
	"res://Balls/Fighters/Pootis/ball_pootis.tscn" : "MR.POOTIS",
	"res://Balls/Fighters/HC8/ball_hc8.tscn" : "HC8",
	"res://Balls/Fighters/01/ball_01.tscn":"01",
	"res://Balls/Fighters/Hyla/ball_hyla.tscn":"HYLA",
	"res://Balls/Fighters/Paprika/ball_paprika.tscn":"PAPRIKA",
	"res://Balls/Fighters/Mandalyn/ball_mandalyn.tscn":"MANDALYN",
	"res://Balls/Fighters/Hanate/ball_hanate.tscn":"HANATE",
	"res://Balls/Fighters/Hones/ball_hones.tscn":"HONES"
	
	
}

var colorInfo = {
	
	"white": Color("e3e3e3ff"),
	"HANATE":Color("3aa8ff"),
	"AXOM":Color("a65253"),
	"HONG":Color("c82633ff"),
	"KORDELL":Color("0261e7"),
	"OKINA":Color("6ed59eff"),
	"JANE":Color("b6725b"),
	"SOMNIA":Color("7aaeff"),
	"THONG":Color("97e3f6"),
	"VEE":Color("ab679b"),
	"HIRO":Color("cc2f49ff"),
	"BETA":Color("619153"),
	"T7":Color("75ff99"),
	"MR.POOTIS":Color("980e1aff"),
	"HC8":Color("878787"),
	"01":Color("6e967d"),
	"HYLA":Color("75ee84ff"),
	"PAPRIKA":Color("9a76bc"),
	"MANDALYN":Color("8f28c7"),
	"HONES":Color("009971"),
	"PHIL":Color("eac0f8"),
	"SHIRT":Color("8339bd"),
	"KATIE":Color("7ce6c1")
}

func get_team_data(b1_name,b2_name):
	var pair:Array = [b1_name,b2_name]
	pair.sort()
	
	for i in TeamDictionary.teamData.keys():
		var dup_sort=i.duplicate()
		dup_sort.sort()
		if dup_sort[0]==pair[0] and dup_sort[1]==pair[1]:
			return teamData[i]
	return null




var teamData = {
	["HANATE","HIRO"]: {
		"team_name" : "STARFURY",
		"team_audio" : "res://Balls/Teams/starfury_teamname.wav",
		"lines": [
			{
				"line": "\"Can't beat the mage and warrior duo!\"",
				"color": "HIRO"
			},
			{
				"line": "\"It IS tried and true for a reason!\"",
				"color": "HANATE"
			},
		]
	},
	["HONES","JANE"]: {
		"team_name" : "CLOAK&DAGGER",
		"team_audio" : "res://Balls/Teams/cloak&dagger_teamname.wav",
		"lines": [
			{
				"line": "\"Mind letting me take a look at that watch?\"",
				"color": "HONES"
			},
			{
				"line": "\"Careful Sweetie!\"",
				"color": "JANE"
			},
			{
				"line": "\"It's a bit more delicate than that tooth of yours.\"",
				"color": "JANE"
			},
			{
				"line": "\"Surely 'modern' technology isn't that fragile...\"",
				"color": "HONES"
			}
		]
	},
	["SOMNIA","JANE"]: {
		"team_name" : "MS.SANDMEN",
		"team_audio" : "res://Balls/Teams/mssandmen_teamname.wav",
		"lines": [
			{
				"line": "\"Ya know, I could always use another merc for hire <3\"",
				"color": "SOMNIA"
			},
			{
				"line": "\"If you keep making my job this easy, I’m all yours.\"",
				"color": "JANE"
			},
		]
	},
	["KORDELL","OKINA"]: {
		"team_name" : "PARTICLEACCELERATOR",
		"team_audio" : "res://Balls/Teams/particleaccelerator_teamname.wav",
		"lines": [
			{
				"line": "\"Surprised you could keep up\"",
				"color": "OKINA"
			},
			{
				"line": "\"Now where's the fun in slowing down?\"",
				"color": "KORDELL"
			},
		]
	},
	["AXOM","HONG"]: {
		"team_name" : "BAYWATCH",
		"team_audio" : "res://Balls/Teams/baywatch_teamname.wav",
		"lines": [
			{
				"line": "\"Nice weapon.. can I use it as a fork for the BBQ?\"",
				"color": "AXOM"
			},
			{
				"line": "\"Watch it! Do NOT interrupt the grill master!\"",
				"color": "HONG"
			},
		]
	},
	["KORDELL","JANE"]: {
		"team_name" : "BIGEARNERS",
		"team_audio" : "res://Balls/Teams/bigearners_teamname.wav",
		"lines": [
			{
				"line": "\"HAHA cant catch watcha can't see! Right Jane?\"",
				"color": "KORDELL"
			},
			{
				"line": "\"There's no changing that, Blue bolt~\"",
				"color": "JANE"
			},
		]
	},
	["PAPRIKA","AXOM"]: {
		"team_name" : "FEEDINGGROUNDS",
		"team_audio" : "res://Balls/Teams/feedinggrounds_teamname.wav",
		"lines": [
			{
				"line": "\"Good work glubby!  Have some fish flakes.\"",
				"color": "PAPRIKA"
			},
			{
				"line": "\"OM NOM NOM-.\"",
				"color": "AXOM"
			},
		]
	},
	["MANDALYN","VEE"]: {
		"team_name" : "FISTERSISTERS",
		"team_audio" : "res://Balls/Teams/fistersisters_teamname.wav",

		"lines": [
			{
				"line": "\"Nice fighting lefty.\"",
				"color": "MANDALYN"
			},
			{
				"line": "\"...I'll pull your hair out.\"",
				"color": "VEE"
			},
		]
	},
	["T7","BETA"]: {
		"team_name" : "FISTSOFSTEEL",
		"team_audio" : "res://Balls/Teams/fistsofsteel_teamname.wav",
		"lines": [
			{
				"line": "\"Dude, how did you get so huge?\"",
				"color": "T7"
			},
			{
				"line": "\"I learned that to beat a bear, is to become bigger than them.\"",
				"color": "BETA"
			},
		]
	},
	["VEE","MR.POOTIS"]: {
		"team_name" : "HEAVENLYBUSTERS",
		"team_audio" : "res://Balls/Teams/heavenlybusters_teamname.wav",
		"lines": [
			{
				"line": "\"VEE!\"",
				"color": "VEE"
			},
			{
				"line": "\"POOTIS!\"",
				"color": "MR.POOTIS"
			},
			{
				"line": "\"BUSTER!!\"",
				"color": "white"
			},
		]
	},
	["HONG","THONG"]: {
		"team_name" : "HONGTHONG",
		"team_audio" : "res://Balls/Teams/hongthong_teamname.wav",
		"lines": [
			{
				"line": "\"Wooow, love how big your sword is!\" ❤️",
				"color": "THONG"
			},
			{
				"line": "\"Dude im so hard rn.\"",
				"color": "HONG"
			},
			{
				"line": "\"What?\"",
				"color": "THONG"
			},
			{
				"line": "\"What?\"",
				"color": "HONG"
			},
		]
	},
	["PAPRIKA","HIRO"]: {
		"team_name" : "PAPIRO",
		"team_audio" : "res://Balls/Teams/papiro_teamname.wav",
		"lines": [
			{
				"line": "\"It's hard not hitting your little... 'yous' with my sword!\"",
				"color": "HIRO"
			},
			{
				"line": "\"It won't get easier anytime soon!\"",
				"color": "PAPRIKA"
			},
		]
	},
	["HYLA","KORDELL"]: {
		"team_name" : "QUICKYBOUNCIES",
		"team_audio" : "res://Balls/Teams/quickbouncies_teamname.wav",
		"lines": [
			{
				"line": "\"Boom chicka boom boom!\"",
				"color": "HYLA"
			},
			{
				"line": "\"What she said!\"",
				"color": "KORDELL"
			},
		]
	},
	["HC8","01"]: {
		"team_name" : "SEVEREDWIRES",
		"team_audio" : "res://Balls/Teams/severedwires_teamname.wav",
		"lines": [
			{
				"line": "\"Your laser's energy output is impressive.\"",
				"color": "HC8"
			},
			{
				"line": "\"Thanks, it hurts to do.\"",
				"color": "01"
			},
			{
				"line": "\"I must surpass it. Shoot me.\"",
				"color": "HC8"
			},
		]
	},
	["SOMNIA","THONG"]: {
		"team_name" : "SOMNOPHILIA",
		"team_audio" : "res://Balls/Teams/somnophilia_teamname.wav",
		"lines": [
			{
				"line": "\"That was exhausting! I sure could use a nap right now~\"",
				"color": "THONG"
			},
			{
				"line": "\"Quit batting your eyes at me!\"",
				"color": "SOMNIA"
			},
		]
	},
	
	
	
	
	["PHIL","KATIE"]: {
		"team_name" : "WASHINGMACHINE",
		"team_audio" : "res://Balls/Teams/washingmachine_teamname.wav",
		"lines": [
			{
				"line": "\"Would you like a tangerine.\"",
				"color": "KATIE"
			},
			{
				"line": "\"I'll take the tangerine, as long as you take my fashion advice once this is all over.\"",
				"color": "PHIL"
			},
			{
				"line": "\"PLEASE don't listen to him...\"",
				"color": "SHIRT"
			},
		]
	},
	["BETA","HIRO"]: {
		"team_name" : "SWORD&STONE",
		"team_audio" : "res://Balls/Teams/swordnstone_teamname.wav",
		"lines": [
			{
				"line": "\"Apologies if I was too harsh with my punching...\"",
				"color": "BETA"
			},
			{
				"line": "\"No, Beta! You're supposed to pose after winning!\"",
				"color": "HIRO"
			},
		]
	},
	["T7","VEE"]: {
		"team_name" : "VEE-7",
		"team_audio" : "res://Balls/Teams/vee7_teamname.wav",
		"lines": [
			{
				"line": "\"I'm surprised you could keep up!\"",
				"color": "T7"
			},
			{
				"line": "\"I'm as surprised as you are.\"",
				"color": "VEE"
			},
		]
	},
	
}

## TEMPLATES ##
# for anything more than 3 lines you can just add onto it and change line_amount to the appropiate amount
	#"2LINETEAM": {
	#"p1_text_color": Color("000000ff"), # CHAR 1
	#"p2_text_color": Color("000000ff"), # CHAR 2
		#"line_amount": 2, 
		#"lines": [
			#{
				#"line": "\"TEXT\"",
				#"color": "p1_text_color"
			#},
			#{
				#"line": "\"TEXT\"",
				#"color": "p2_text_color"
			#},
		#]
	#},
#"3LINETEAM": {
	#"p1_text_color": Color("000000ff"), # CHAR 1
	#"p2_text_color": Color("000000ff"), # CHAR 2
		#"line_amount": 3, 
		#"lines": [
			#{
				#"line": "\"TEXT\"",
				#"color": "p1_text_color"
			#},
			#{
				#"line": "\"TEXT\"",
				#"color": "p2_text_color"
			#},
			#{
				#"line": "\"TEXT\"",
				#"color": "p1_text_color"
			#},
		#]
	#},
