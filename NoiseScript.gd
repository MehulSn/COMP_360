extends Node3D

@export var noise_res: FastNoiseLite      # drag MyNoise.tres here
@export var grid_size: int = 32           # quads per side
@export var cell_size: float = 1.0        # horizontal spacing
@export var height_scale: float = 5.0     # vertical exaggeration

func _ready() -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = generate_grid(grid_size, grid_size, cell_size)
	add_child(mi)
	# If your grid appears vertical, rotate the mesh:
	# mi.rotation_degrees = Vector3(-90, 0, 0)

func generate_grid(rows: int, cols: int, step: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for x in range(rows):
		for y in range(cols):
			var x0 := x * step
			var y0 := y * step

			# Sample noise, normalize [-1..1] -> [0..1], then scale height
			var h0 := ((noise_res.get_noise_2d(x0,         y0        ) + 1.0) * 0.5) * height_scale
			var h1 := ((noise_res.get_noise_2d(x0 + step,  y0        ) + 1.0) * 0.5) * height_scale
			var h2 := ((noise_res.get_noise_2d(x0 + step,  y0 + step ) + 1.0) * 0.5) * height_scale
			var h3 := ((noise_res.get_noise_2d(x0,         y0 + step ) + 1.0) * 0.5) * height_scale

			var v0 := Vector3(x0,         h0, y0)
			var v1 := Vector3(x0 + step,  h1, y0)
			var v2 := Vector3(x0 + step,  h2, y0 + step)
			var v3 := Vector3(x0,         h3, y0 + step)

			# UVs so the texture matches the grid
			var uv00 := Vector2(x / float(rows),     y / float(cols))
			var uv10 := Vector2((x+1) / float(rows), y / float(cols))
			var uv11 := Vector2((x+1) / float(rows), (y+1) / float(cols))
			var uv01 := Vector2(x / float(rows),     (y+1) / float(cols))

			# tri 1: v0, v1, v2
			st.set_uv(uv00); st.add_vertex(v0)
			st.set_uv(uv10); st.add_vertex(v1)
			st.set_uv(uv11); st.add_vertex(v2)
			# tri 2: v0, v2, v3
			st.set_uv(uv00); st.add_vertex(v0)
			st.set_uv(uv11); st.add_vertex(v2)
			st.set_uv(uv01); st.add_vertex(v3)

	st.end()
	return st.commit()
