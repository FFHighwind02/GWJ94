class_name GameGrid
extends Node

# Author: @ffhighwind, Version 06/17/26



@export var CELL_SIZE: float = 1.0
@export var width: int = 10
@export var depth: int = 10
@export var origin_y: float = 0.0

var isOccupied: Dictionary = {}



# Cell coordinate to world space conversion helpers
func cell_to_world(cell: Vector2i):
	return Vector3(cell.x * CELL_SIZE, origin_y, cell.y * CELL_SIZE)
	
	
func world_to_cell(world: Vector3) -> Vector2i:
	return Vector2i(roundi(world.x / CELL_SIZE), roundi(world.z / CELL_SIZE))
	

# Verify the player is still in bounds of the board
func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < width and cell.y >= 0 and cell.y < depth


# Ensure empty cell before movement
func is_cell_free(cell: Vector2i) -> bool:
	return in_bounds(cell) and not isOccupied.has(cell)


func occupant_at(cell: Vector2i) -> Node:
	return isOccupied.get(cell, null)
 
 


func set_occupant(cell: Vector2i, who: Node) -> void:
	isOccupied[cell] = who
 
 
func clear_cell(cell: Vector2i) -> void:
	isOccupied.erase(cell)
 
 
func move_occupant(from: Vector2i, to: Vector2i, who: Node) -> void:
	if isOccupied.get(from) == who:
		isOccupied.erase(from)
	isOccupied[to] = who
	
	
	
func cell_distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)
 
 

func reachable_cells(from: Vector2i, range_tiles: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for dx in range(-range_tiles, range_tiles + 1):
		for dy in range(-range_tiles, range_tiles + 1):
			var c := from + Vector2i(dx, dy)
			if c != from and cell_distance(from, c) <= range_tiles and is_cell_free(c):
				out.append(c)
	return out
	
	
	
	
	
	
	
	
