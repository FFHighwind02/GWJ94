extends Node3D

# Author: @ffhighwind, Version 06/17/26

@export var grid: GameGrid
@export var player: PlayerController
 
#debug line v isuals
@export_group("Appearance")
@export var line_color: Color = Color(1, 1, 1, 0.20)
@export var reachable_color: Color = Color(0.2, 0.75, 1.0, 0.22)
@export var hover_color: Color = Color(1.0, 1.0, 0.0, 0.45)
@export var lift: float = 0.018  
 

var _lines: MeshInstance3D
var _reach: MultiMeshInstance3D
var _hover: MeshInstance3D
var _last_cell := Vector2i(2147483647, 2147483647)   # force first rebuild
 
 
func _ready() -> void:
	if grid == null or player == null:
		push_warning("GridDebug: assign both Grid and Player.")
		set_process(false)
		return
	_build_lines()
	_build_reach()
	_build_hover()
 
 
func _process(_delta: float) -> void:
	# Rebuild the reachable set only when the player actually changes tile.
	if player.cell != _last_cell:
		_last_cell = player.cell
		_update_reach(grid.reachable_cells(player.cell, player.moveRange))
	_update_hover()
 
 

func _build_lines() -> void:
	var cs := grid.CELL_SIZE
	var y := grid.origin_y + lift * 2.0
	var im := ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_LINES, _make_material(line_color))
	
	for x in range(grid.width + 1):
		var wx := (x - 0.5) * cs
		im.surface_add_vertex(Vector3(wx, y, -0.5 * cs))
		im.surface_add_vertex(Vector3(wx, y, (grid.depth - 0.5) * cs))
	for z in range(grid.depth + 1):
		var wz := (z - 0.5) * cs
		im.surface_add_vertex(Vector3(-0.5 * cs, y, wz))
		im.surface_add_vertex(Vector3((grid.width - 0.5) * cs, y, wz))
	im.surface_end()
 
	_lines = MeshInstance3D.new()
	_lines.mesh = im
	_lines.top_level = true   
	add_child(_lines)
 

 
func _build_reach() -> void:
	var quad := PlaneMesh.new()
	quad.size = Vector2(grid.CELL_SIZE * 0.9, grid.CELL_SIZE * 0.9)  # gap shows lines
	quad.material = _make_material(reachable_color)
 
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = quad
	mm.instance_count = 0
 
	_reach = MultiMeshInstance3D.new()
	_reach.multimesh = mm
	_reach.top_level = true
	add_child(_reach)
 
 
func _build_hover() -> void:
	var quad := PlaneMesh.new()
	quad.size = Vector2(grid.CELL_SIZE * 0.95, grid.CELL_SIZE * 0.95)
	quad.material = _make_material(hover_color)
 
	_hover = MeshInstance3D.new()
	_hover.mesh = quad
	_hover.top_level = true
	_hover.visible = false
	add_child(_hover)
 

func _update_reach(cells: Array[Vector2i]) -> void:
	var mm := _reach.multimesh
	mm.instance_count = cells.size()
	var y := grid.origin_y + lift
	for i in cells.size():
		var w: Vector3 = grid.cell_to_world(cells[i])
		mm.set_instance_transform(i, Transform3D(Basis(), Vector3(w.x, y, w.z)))
 
 

func _update_hover() -> void:
	var c = _cell_under_mouse()
	if c == null:
		_hover.visible = false
		return
	var cell: Vector2i = c
	var reachable: bool = cell != player.cell \
		and grid.cell_distance(player.cell, cell) <= player.moveRange \
		and grid.is_cell_free(cell)
	if reachable:
		var w :Vector3 = grid.cell_to_world(cell)
		_hover.global_position = Vector3(w.x, grid.origin_y + lift * 3.0, w.z)
		_hover.visible = true
	else:
		_hover.visible = false
 
 

func _cell_under_mouse():
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return null
	var mouse := get_viewport().get_mouse_position()
	var from := cam.project_ray_origin(mouse)
	var to := from + cam.project_ray_normal(mouse) * 1000.0
	var q := PhysicsRayQueryParameters3D.create(from, to)
	q.collide_with_bodies = true
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty():
		return null
	return grid.world_to_cell(hit.position)
 
 


func _make_material(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.albedo_color = c
	return m
