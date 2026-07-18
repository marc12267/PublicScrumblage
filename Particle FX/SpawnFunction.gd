###Dynamic particle spawner
extends Node

func _spawn_particle_effect(particle_effect:PackedScene, pos:Vector2, dir = Vector2.RIGHT, color = Color("ffffff")):
	
	var obj = particle_effect.instantiate()
	add_child(obj)
	
	for child in obj.get_children():
		if child is CPUParticles2D:
			child.z_as_relative = false
			if "C" in child.name:
				child.modulate = color
			
	var facing = - 1 if dir.x < 0 else 1
	obj.global_position = pos
	if facing < 0:
		obj.rotation = (dir * Vector2( - 1, - 1)).angle()
	else :
		obj.rotation = dir.angle()
	obj.scale.x = facing
	return obj
