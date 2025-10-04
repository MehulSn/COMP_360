extends Node3D

@export var noise_res: FastNoiseLite       # drag MyNoise.tres here
@export var grid_size: int = 32            # number of quads per side
@export var scale: height_scale = 5.0             # height scale

func _ready():
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = generate_grid(grid_size, grid_size)
	add_child(mesh_instance)


func generate_grid(rows: int, cols: int) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for x in range(rows):
		for y in range(cols):
			var h0 = noise_res.get_noise_2d(x, y)
			var h1 = noise_res.get_noise_2d(x+1, y)
			var h2 = noise_res.get_noise_2d(x+1, y+1)
			var h3 = noise_res.get_noise_2d(x, y+1)

			# normalize [-1,1] to [0,1]
			h0 = (h0 + 1) * 0.5
			h1 = (h1 + 1) * 0.5
			h2 = (h2 + 1) * 0.5
			h3 = (h3 + 1) * 0.5

			var verts = [
				Vector3(x, h0 * scale, y),
				Vector3(x+1, h1 * scale, y),
				Vector3(x+1, h2 * scale, y+1),
				Vector3(x, h3 * scale, y+1)
			]

			var uvs = [Vector2(0,0), Vector2(1,0), Vector2(1,1), Vector2(0,1)]
			var indices = [0,1,2, 0,2,3]

			for i in indices:
				st.set_uv(uvs[i])
				st.add_vertex(verts[i])

	st.end()
	return st.commit()
