@tool
extends Area2D
class_name Dung

@export var value: int = 1
@export var randomize_variant: bool = true
@export_range(0, 9) var variant: int = 0:
	set(value):
		variant = value
		update_settings()
@export var size: int = 3:
	set(value):
		size = value
		update_settings()
@export var color: Color = Color("5b3527"):
	set(value):
		color = value
		update_settings()
@export var pickup_sound: SoundResource

var rng = RandomNumberGenerator.new()
var weights: PackedFloat32Array = [20, 8, 4, 2, 1.5, 1, 0.5, 0.3, 0.1]

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	if randomize_variant:
		variant = rng.rand_weighted(weights)
	else:
		update_settings()
	


func update_settings() -> void:
	if !is_node_ready():
		await ready
	collision_shape_2d.shape.radius = size
	sprite_2d.modulate = color
	sprite_2d.region_rect = Rect2(variant * 16, 0, 16, 16)
	value += variant



func _on_body_entered(_body: Node2D) -> void:
	GameManager.score += value
	pickup_sound.play_managed()
	queue_free()
