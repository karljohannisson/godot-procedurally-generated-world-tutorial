extends Node

const GENERATION_BOUND_DISTANCE = 64
const VERTICAL_AMPLITUDE = 10

var noise = FastNoiseLite.new()
#var player_position: Vector3
var player: Node
var generated_cubes

func _ready():
	generated_cubes={}
	#player_position = Vector3(0,0,0)
	player=get_node("../Player")
	generate_new_cubes_from_position(player.position)

func generate_new_cubes_from_position(player_position):
	for x in range(GENERATION_BOUND_DISTANCE*2):
		x += (player_position.x - GENERATION_BOUND_DISTANCE)
		for z in range(GENERATION_BOUND_DISTANCE*2):
			z += (player_position.z - GENERATION_BOUND_DISTANCE)
			generate_cube_if_new(x,z)

func generate_cube_if_new(x,z):
	if !has_cube_been_generated(x,z):
		var generated_noise = noise.get_noise_2d(x,z)
		create_cube(Vector3(x,generated_noise*VERTICAL_AMPLITUDE,z), get_color_from_noise(generated_noise))
		register_cube_generation_at_coordinate(x,z)

func has_cube_been_generated(x,z):
	if x in generated_cubes and z in generated_cubes[x] and generated_cubes[x][z] == true:
		return true
	else:
		return false
			
func register_cube_generation_at_coordinate(x,z):
	if x in generated_cubes:
		generated_cubes[x][z] = true
	else:
		generated_cubes[x] = {z: true}
			

func _process(delta):
	generate_new_cubes_from_position(player.position)
	
func create_cube(position, color):
	var box_size = Vector3(1,1,1)
	
	var static_body = StaticBody3D.new()
	
	var collision_shape_3d = CollisionShape3D.new()
	collision_shape_3d.position = position
	collision_shape_3d.shape = BoxShape3D.new()
	collision_shape_3d.shape.size = box_size
	
	var mesh = MeshInstance3D.new()
	
	var boxmesh = BoxMesh.new()
	boxmesh.size = box_size
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	
	boxmesh.material = material
	
	mesh.set_mesh(boxmesh)
	mesh.set_position(position)
	
	static_body.add_child(mesh)
	static_body.add_child(collision_shape_3d)
	
	add_child(static_body)

func get_color_from_noise(noise_value):
	if noise_value <= -.4:
		return Color(1,0,0,1)
	elif noise_value <= -.2:
		return Color(0,1,0,1)
	elif noise_value <= 0:
		return Color(0,0,1,1)
	elif noise_value <= .2:
		return Color(.5,.5,.5,1)
	elif noise_value > .2:
		return Color(.3,.8,.5,1)
	
