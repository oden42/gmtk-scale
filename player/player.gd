extends CharacterBody2D
class_name Player

@export var move_speed: float = 100.0
@export var size: int = 10:
	set(value):
		size = value
		set_ball_size()

var last_direction: Vector2 = Vector2(0, -1)

@onready var camera_2d: Camera2D = $Camera2D
@onready var ball_mesh: MeshInstance3D = %BallMesh
@onready var beetle: Sprite2D = $Beetle
@onready var center_pivot: Node2D = $CenterPivot
@onready var beetle_marker: Marker2D = $CenterPivot/BeetleMarker
@onready var sub_viewport: SubViewport = $SubViewport

@onready var debug_label_1: Label = %DebugLabel1

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)


func _process(_delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move left", "move right", "move up", "move down")
	if direction != Vector2.ZERO:
		last_direction = direction
	
	velocity = direction * move_speed
	move_and_slide()
	
	ball_mesh.rotate_x(direction.y * 0.1)
	ball_mesh.rotate_z(-direction.x * 0.1)
	
	center_pivot.rotation = last_direction.angle()
	beetle.global_position = beetle_marker.global_position
	
	if last_direction.y > 0:
		beetle.z_index = 0
	else:
		beetle.z_index = 2
	
	debug_label_1.text = str(direction)


func set_ball_size() -> void:
	sub_viewport.size = Vector2(size, size)


func _on_score_changed(score: int) -> void:
	#var increase: int = (score + 10) - size
	#camera_2d.zoom *= 1 - (increase * 0.01)
	size = score + 10
	print("New size: ", size)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom in"):
		camera_2d.zoom *= 2
	elif event.is_action_pressed("zoom out"):
		camera_2d.zoom *= 0.5
