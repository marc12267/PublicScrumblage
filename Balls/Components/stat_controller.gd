## VERY IMPORTANT NODE FOR MANAGING PROPERTIES AND ALLOWING BALLS
## TO INTERACT WITH STATUSES AND EFFECTS CONSISTENTLY
## CHECK DOC FOR MORE INFO ON HOW TO USE

extends Node
class_name StatController

## Signal emitted when a stat is updated
## Connect to this to update your own stats
signal stat_changed(stat_name, value)

## Base stats stored here
var base_stats := {}

## Modifiers stores here
var modifiers := {}

## Final stats after calculations stored here
var final_stats := {}

## Aliases stored here
## If there are multiple instances of objects using statcontroller,
## we use aliases to make them all get affected by modifiers equally, while still
## being distinct
var stat_aliases := {} 

## Types of ways modifiers affect stuff
enum ModType { ADD, MUL, OVERRIDE }

class Modifier:
	var type : int
	var value
	var id : String
	var priority : int

	func _init(_type, _value, _id, _priority):
		type = _type
		value = _value
		id = _id
		priority = _priority

## Add alias for certain stats so that the stat modifier can share between them
func add_alias(stat: String, alias: String):
	if not stat_aliases.has(stat):
		stat_aliases[stat] = []
	
	if alias not in stat_aliases[stat]:
		stat_aliases[stat].append(alias)

## Adds a modifier
func add_modifier(stat: String, type: int, value, id: String, priority: int = 1):
	_apply_modifier(stat, type, value, id, priority)

	##Apply to aliased stats
	for s in base_stats.keys():
		if stat_aliases.has(s) and stat in stat_aliases[s]:
			_apply_modifier(s, type, value, id, priority)

func _apply_modifier(stat: String, type: int, value, id: String, priority):
	if not modifiers.has(stat):
		modifiers[stat] = []

	modifiers[stat].append(Modifier.new(type, value, id, priority))
	recalculate(stat)

## Removes a modifier
func remove_modifier(id: String):
	for stat in modifiers.keys():
		var arr = modifiers[stat]
		for i in range(arr.size() - 1, -1, -1):
			if arr[i].id == id:
				arr.remove_at(i)
		recalculate(stat)

## Calculates base stats against modifiers
func recalculate(stat: String):
	var base = base_stats.get(stat, null)
	if base == null:
		return
	
	var add = 0.0
	var mul = 1.0
	if typeof(base) == TYPE_VECTOR2:
		add = Vector2(0, 0)
		mul = Vector2(1, 1)
	
	if typeof(base) == TYPE_INT or typeof(base) == TYPE_FLOAT or typeof(base) == TYPE_VECTOR2:
		var mods = modifiers.get(stat, [])
		
		mods.sort_custom(func(a, b):
			if a.priority != b.priority:
				return a.priority < b.priority
			if a.type != ModType.OVERRIDE and b.type == ModType.OVERRIDE:
				return true
			return false
		)
		
		for mod in mods:
			match mod.type:
				ModType.ADD:
					add += mod.value
				ModType.MUL:
					mul *= mod.value
				ModType.OVERRIDE:
					add = 0.0 if typeof(base) != TYPE_VECTOR2 else Vector2.ZERO
					mul = mod.value
		
		var final_value = (base + add) * mul
		if typeof(base) == TYPE_INT:
			final_value = int(final_value)
		final_stats[stat] = final_value
		stat_changed.emit(stat, final_value)
	
	elif typeof(base) == TYPE_BOOL:
		var mods = modifiers.get(stat, [])
		
		mods.sort_custom(func(a, b): return a.priority < b.priority)
		
		var final_value = base
		for mod in mods:
			final_value = mod.value
		final_stats[stat] = final_value
		stat_changed.emit(stat, final_value)

## Sets base stat
## Use this instead of updating variables directly inscript
func set_base_stat(stat, value):
	var is_new = not base_stats.has(stat)
	base_stats[stat] = value
	
	recalculate(stat)

## Get calculated version of stat
func get_stat(stat: String):
	return final_stats.get(stat, base_stats.get(stat))
