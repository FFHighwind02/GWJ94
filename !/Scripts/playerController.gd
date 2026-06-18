class_name PlayerController
extends CharacterBody3D
# playerController.gd handles the movement of the player turtle.
# The player must only act during it's turn and range.
# Author: @ffhighwind, Version 06/18/26

@export var grid: GameGrid
@export var moveRange: int = 3
@export var moveAnimTime: float = 0.15   # player anim as small hop, think moving game piece


var cell: Vector2i
var _busy: bool = false # do not allow moves when in movement anim


func _ready() -> void:
	cell = grid.world_to_cell(global_position)
	global_position = grid.cell_to_world(cell)
	grid.set_occupant(cell, self)
	
	
	
func _unhandled_input(event: InputEvent) -> void:
	if _busy:
		return
	if event is InputEventMouseButton and event.pressed \
		and event.button_index == MOUSE_BUTTON_RIGHT:
		var target = _pick_cell(event.position)
		if target != null:
			_try_move(target)
			
			
			
# Handle whether the attempted grid is a valid move for the player based on
# their specific stats and whether the targeted cell is occupied by and enemy or obj
func _try_move(target: Vector2i) -> void:
	if target == cell:
		return
	if grid.cell_distance(cell, target) >= moveRange:
		return
	if not grid.is_cell_free(target):
		return
		
	grid.move_occupant(cell, target, self)
	cell = target
	
	var tween := create_tween()
	tween.tween_property(self, "global_position", grid.cell_to_world(target), moveAnimTime)
	await tween.finished
	_busy = false
	
	
	
	
func _pick_cell(pos: Vector2):
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return null
		
	var from := cam.project_ray_origin(pos)
	var to := from + cam.project_ray_normal(pos) * 1000.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	
	query.collide_with_bodies = true
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null
		
	return grid.world_to_cell(hit.position)
	
	
