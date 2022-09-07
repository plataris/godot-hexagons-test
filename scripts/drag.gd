extends Spatial

var scaleFactor = 60
var selected = false
var viewportCenter: Vector2
var hexagonNode
var scene
var lerpWeight = 0

# the block "lerped" 2d position, used to convert between the mouse 2d and the block 3d position
var blockLerpedPosition: Vector2 = Vector2(0, 0)

# temporary "hexa" coordinate of the last click
var lastCoord: Vector3
# flag: can the player create a block in the void?
var isRootHexagon = true

# map of the existing blocks
var hexagonArray = {}

# Hexagon size
var hexSize = 1

# Dicionaries of relative Vector3 for directionals.
const hex_directions = [
	Vector3( 1, -1,  0), Vector3( 1,  0, -1), Vector3( 0,  1, -1),
	Vector3(-1,  1,  0), Vector3(-1,  0,  1), Vector3( 0, -1,  1)
]

var blockNode 


func _ready():
	viewportCenter = Vector2( get_viewport().size.x / 2, get_viewport().size.y / 2)
	blockNode = get_node('Hexagon')
	scene = load("res://scenes/Hexagon.tscn")

func _physics_process(_delta):
	move_block_to_mouse(_delta)

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed == true:
		generate_block()
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed == true:
		remove_block()

func remove_block():
	if not lastCoord in hexagonArray.keys():
		return
	var block = hexagonArray[lastCoord]
	var _checkDeletion = hexagonArray.erase(lastCoord)
	block.queue_free()
	
func setBlockSize(amount: float, neighbors):
	for i in neighbors.size():
		var node = hexagonArray[neighbors[i]]
		node.add_height_to_mesh_instance(amount)
	$Camera.transform.origin.y += amount + amount * 0.8

# NOTE: we will use a scene with a MeshInstance that has a primitive mesh cylinder for the hexagonal blocks
func generate_block():
	var neighbors = check_if_neighbor_exist()
	# check if the last clicked tile is already on the map
	if lastCoord in hexagonArray.keys() and not isRootHexagon:
		return
	# check if there is at least an already existing neighbor to restrain the creation of the blocks
	elif neighbors.size() < 1 and not isRootHexagon:
		return
	elif neighbors.size() == 3:
		setBlockSize(0.5, neighbors)
	# instanciate a new Block
	var node: Spatial = scene.instance()
	
	# convert the Hexa/Cube Coordinates to an intermediate 2d representation
	var cartesianCoordinates = convert_hexa_to_cartesian( lastCoord)
	# Constrain the block to have a y zero coordinate
	var blockInstanceVector = Vector3( cartesianCoordinates.x, 0.0, cartesianCoordinates.y)
	
	# set the block instance coordinate to the clicked places
	node.transform.origin = blockInstanceVector

	add_child(node)
	# save the block instance and index it by its "hexa" coordinates
	hexagonArray[lastCoord] = node
	# Disable the hability to create a block in the void
	isRootHexagon = false


# Check if there is a neighbor around the last clicked "hexa" position
func check_if_neighbor_exist():
	var neighbors = []
	for i in range(hex_directions.size()):
		var check = get_block_neighbor(lastCoord, i)
		if check in hexagonArray.keys():
			neighbors.push_back(check)
	return neighbors

func move_block_to_mouse(_delta):
	var ray_length = 200
	var space_state = get_world().direct_space_state
	var camera = $Camera
	var mousePos: Vector2 = get_viewport().get_mouse_position()
	# delta multiplied by 30 for 1/2 second lerp weight 0 to 1 change speed:
	# depending on 60 frames per second
	lerpWeight = fmod (lerpWeight + _delta * 30, 1.0)
	# lerp the block position to the mouse position for a slight smoother feedback
	var xPos = lerp( blockLerpedPosition.x, (mousePos.x - viewportCenter.x) / scaleFactor, lerpWeight)
	var zPos = lerp( blockLerpedPosition.y, (mousePos.y - viewportCenter.y) / scaleFactor, lerpWeight)
	blockLerpedPosition = Vector2(xPos, zPos)

	var from: Vector3 = camera.project_ray_origin(blockLerpedPosition)
	var to: Vector3 = from + camera.project_ray_normal(mousePos) * ray_length
	var result: Dictionary = space_state.intersect_ray(from, to)
	if not "position" in result.keys():
		#print('no position in result.keys: ', result)
		return
	# juat a temp var to pass a Vector2 to get_hexa_from_2d
	var temp = Vector2 (result.position.x, result.position.z)
	# get the "rounded to integer" Hexagonal coordinate of the block restrained to x and z axis
	var hexa: Vector3 = round_hexa(get_hexa_from_2d(temp))
	lastCoord = hexa
	var cartesianCoordinates = convert_hexa_to_cartesian( hexa)
	# update the reference block 3d coordinates
	# 0.10 is just to have the reference block more emphasized
	blockNode.transform.origin = Vector3( cartesianCoordinates.x, 0.10, cartesianCoordinates.y)


func convert_hexa_to_cartesian(hexa: Vector3):
	var matrixX = Vector2(sqrt(3.0), sqrt (3.0)/2.0)
	var matrixY = Vector2(0.0, 3.0/2.0)
	var hex = Vector2(hexa.x, hexa.y)
	
	var new2dVec = Vector2()
	new2dVec.x = matrixX.dot(hex) * hexSize
	new2dVec.y = matrixY.dot(hex) * hexSize
	return new2dVec

func get_hexa_from_2d(axialPoint: Vector2):
	var matrixX = Vector2(sqrt(3.0)/3.0, -1.0/3.0)
	var matrixY = Vector2(0.0, 2.0/3.0)
	
	var newHexaVec = Vector3()
	newHexaVec.x = matrixX.dot(axialPoint) / hexSize
	newHexaVec.y = matrixY.dot(axialPoint) / hexSize

	newHexaVec.z = -newHexaVec.x - newHexaVec.y
	return newHexaVec
	
func round_hexa(hex):
	var rx = round(hex.x)
	var ry = round(hex.y)
	var rz = round(hex.z)

	var x_diff = abs(rx - hex.x)
	var y_diff = abs(ry - hex.y)
	var z_diff = abs(rz - hex.z)

	if x_diff > y_diff and x_diff > z_diff:
		rx = -ry-rz
	elif y_diff > z_diff:
		ry = -rx-rz
	else:
		rz = -rx-ry
	return Vector3(rx, ry, rz)

func get_block_neighbor(hex, direction):
	return hex + hex_directions[direction]

# IS this needed?
func _exit_tree():
	hexagonArray = {}
	queue_free()

