extends Spatial

func _ready():
	var random_color = Color(randf(), randf(), randf())
	var childNode: MeshInstance = $KinematicBody.get_node('Cylinder')
	var newMat = SpatialMaterial.new()
	newMat.albedo_color = random_color
	childNode.set_surface_material(0, newMat)

func add_height_to_mesh_instance(amount: float):
	var childNode: MeshInstance = $KinematicBody.get_node('Cylinder')
	childNode.mesh.height += amount

	pass
	
# IS this needed?
func _exit_tree():
	queue_free()
