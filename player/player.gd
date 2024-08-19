extends CharacterBody2D
class_name Player

@export var move_speed: float = 100.0
@export var starting_size: int = 4

var size: int:
	set(value):
		if !is_node_ready():
			await ready
		size = value
		set_ball_size()
var last_direction: Vector2 = Vector2(0, -1)
var marker_pos_x: float = -(0.325 * size + 1.75)
var mass: int

var zoom: Vector2 = Vector2(8, 8)

@onready var camera_2d: Camera2D = $Camera2D
@onready var ball_mesh: MeshInstance3D = %BallMesh
@onready var beetle: Sprite2D = $Beetle
@onready var center_pivot: Node2D = $CenterPivot
@onready var beetle_marker: Marker2D = $CenterPivot/BeetleMarker
@onready var sub_viewport: SubViewport = $SubViewport
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


@onready var debug_label_1: Label = %DebugLabel1

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	size = starting_size

func _process(_delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move left", "move right", "move up", "move down")
	if direction != Vector2.ZERO:
		last_direction = direction
	
	velocity = direction * move_speed
	move_and_slide()
	
	ball_mesh.rotate_x(direction.y * 0.1)
	ball_mesh.rotate_z(-direction.x * 0.1)
	
	
	center_pivot.rotation = last_direction.angle()
	#var new_angle_distance = -0.25 * sin(abs(center_pivot.rotation)) + 1
	#new_angle_distance = snappedf(new_angle_distance, 0.01)
	beetle_marker.position.x = marker_pos_x #* new_angle_distance
	#print(center_pivot.rotation_degrees, " new: ", new_angle_distance)
	#print("sin: ", sin(center_pivot.rotation))
	
	beetle.global_position = beetle_marker.global_position
	
	if last_direction.y > 0:
		beetle.z_index = 0
	else:
		beetle.z_index = 2
	
	debug_label_1.text = str(direction)


func set_ball_size() -> void:
	sub_viewport.size = Vector2(size, size)
	marker_pos_x = -(0.385 * size + 1)
	collision_shape_2d.shape.radius = 0.385 * size - 0.54
	print(collision_shape_2d.shape.radius)
	beetle_marker.position.x = marker_pos_x
	if size > 50 and zoom > Vector2(4, 4):
		var tween: Tween = get_tree().create_tween()
		zoom = Vector2(4, 4)
		tween.tween_property(camera_2d, "zoom", zoom, 1.0)
	elif size > 100 and zoom > Vector2(2, 2):
		var tween: Tween = get_tree().create_tween()
		zoom = Vector2(2, 2)
		tween.tween_property(camera_2d, "zoom", zoom, 1.0)


func _on_score_changed(score: int) -> void:
	#var increase: int = (score + 10) - size
	#camera_2d.zoom *= 1 - (increase * 0.01)
	size = score + starting_size
	print("New size: ", size)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom in"):
		camera_2d.zoom *= 2
	elif event.is_action_pressed("zoom out"):
		camera_2d.zoom *= 0.5
