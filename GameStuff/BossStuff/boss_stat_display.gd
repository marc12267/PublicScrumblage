extends BStatDisplay
## Put boss music here, drag it directly into export
@export var custom_music_override:Resource
## The ending stab is a string path instead of a loaded resource, deal with it
@export var custom_music_override_ender:String

# Called when the node enters the scene tree for the first time.
func group_add():
	add_to_group("BossStat")
