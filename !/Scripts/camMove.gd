extends Node3D

# camMove.gd handles the orthographic camera's movement relative to the moves made by the player.
# Planned to function similar to a diorama style camera common in 3D isometric strategy games.

# Notice: Attach this script to the camRig component of the OrthoCam scene.
# Author: @ffhighwind, Version 06/16/26

# Cam movement vars
@export var travelSpeed: float = 5.0
@export var followTarget: Node3D

# Zoom handler variables
@export var defaultZoom: float = 12.0
@export var zoomSpeed: float = 8.0
@export var zoomMax: float = 30.0
@export var zoomMin: float = 5.0

# degrees per second
@export var spinSpeed: float = 8.0
@export var spinIncrement: float = 90.0
@onready var cam: Camera3D = $CamPivot/Camera3D

var _targetZoom: float
var _targetYaw: float



func _ready() -> void:
	
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = defaultZoom
	
	
	_targetZoom = defaultZoom
	_targetYaw = rotation_degrees.y



func _process(delta: float) -> void:
	# If the target to follow is present in a new location, linear travel to the pos
	if followTarget:
		global_position = global_position.lerp(
			followTarget.global_position, travelSpeed * delta
		)
		
	# Adjust zoom & rotation with reset
	cam.size = lerp(
		cam.size, _targetZoom, zoomSpeed * delta
	)
	
	rotation_degrees.y = lerp(
		rotation_degrees.y, _targetYaw, spinSpeed * delta
	)
	
	


func _unhandled_input(event: InputEvent) -> void:
	# If spin buttons are clicked spin the diorama
	if event.is_action_pressed("rotate_clockwise"):
		_targetYaw -= spinIncrement
	elif event.is_action_pressed("rotate_counter"):
		_targetYaw += spinIncrement
		
	# Zoom is controlled using the mouse scroll wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_targetZoom = clampf(_targetZoom - 1.0, zoomMin, zoomMax)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_targetZoom = clampf(_targetZoom + 1.0, zoomMin, zoomMax)
	
	
	

	
