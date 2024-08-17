extends CharacterBody2D

@export var move_speed: float = 100.0

func _process(_delta: float) -> void:
	var direction = Input.get_vector("move left", "move right", "move up", "move down")
	velocity = direction * move_speed
	move_and_slide()
