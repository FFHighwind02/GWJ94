extends Node3D

# camMove.gd handles the orthographic camera's movement relative to the moves made by the player.
# Planned to function similar to a diorama style camera common in 3D isometric strategy games.
# Author: @ffhighwind, Version 06/15/26


@export var travelSpeed: float = 5.0
@export var zoomSpeed: float = 2.0
@export var zoomMax: float = 30.0
@export var zoomMin: float = 5.0

# degrees per second
@export var spinSpeed: float = 90.0

@onready var cam: Camera3D = $CameraPivot/Camera3D

var defaultZoom: float = 20.0



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func handlePlayerMove():
	pass
	
	
func handleSpin():
	pass
	
	
func handleReset():
	pass
