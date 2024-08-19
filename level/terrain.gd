extends Node2D

const CHUNK_SIZE:= Vector2i(16,16)

const DUNG_PICKUP = preload("res://objects/dung_pickup.tscn")

@export var player: CharacterBody2D
@export var randomize_on_start: bool = false
@export var level_seed: int = hash(0):
	set(value):
		level_seed = value

var player_cell_position: Vector2i
var previous_position: Vector2i

## Chunk variables
@export var render_distance: int = 2
var current_chunk: Vector2i
var previous_chunk_center: Vector2i
var current_chunk_distance: int
var previous_chunk: Vector2i
var chunks_in_view: Array[Vector2i]
var chunks_to_render: Array[Vector2i]
var chunks_to_remove: Array[Vector2i]
var spawn_position := Vector2.ZERO

var world_chunk_data: Dictionary = {}

## New variables for chunk generation
var currently_generating: bool = false
var chunk_queue: Array[Vector2i] = []
var chunk_being_generated: Vector2i
var chunk_generation_completed: bool = false
#var wall_changeset: Dictionary
#var ceiling_changeset: Dictionary
#var wall_changeset_completed: bool = false
#var ceiling_changeset_completed: bool = false
var initial_generation_completed: bool = false

@onready var ground_tiles: TileMapLayer = %GroundTiles
@onready var object_tiles: TileMapLayer = %ObjectTiles
@onready var dung_node: Node = %Dung


func _ready() -> void:
	world_chunk_data = {}
	# Sets random
	if randomize_on_start:
		level_seed = randi()
	print("Seed: ", level_seed)
	
	# Set the spawn position to the center of the first chunk
	current_chunk = Vector2i.ZERO # Reset the current chunk
	spawn_position = ground_tiles.map_to_local(CHUNK_SIZE/2) # Get the world position
	player.position = spawn_position # Move the player
	
	_set_render_area(current_chunk)
	_update_chunks()


func _process(_delta) -> void:
	_apply_terrains()
	
	# Translate the player's position to map coordinates
	player_cell_position = ground_tiles.local_to_map(player.position)
	
	if player_cell_position != previous_position:
		previous_position = player_cell_position
		#PlayerManager.player_cell_pos = player_cell_position
		#player_coord_changed.emit(player_cell_position)
	
	# Set current chunk position
	current_chunk = Vector2i( 
		floor(float(player_cell_position.x) / float(CHUNK_SIZE.x)),
		floor(float(player_cell_position.y) / float(CHUNK_SIZE.y))
	)
	previous_chunk_center = Vector2i(
		(previous_chunk.x * CHUNK_SIZE.x) + floor(float(CHUNK_SIZE.x) / 2.0),
		(previous_chunk.y * CHUNK_SIZE.y) + floor(float(CHUNK_SIZE.y) / 2.0),
	)
	current_chunk_distance = int(Vector2(previous_chunk_center).distance_to(Vector2(player_cell_position)))
	
	# Check to see if the player has moved to a new chunk
	if current_chunk != previous_chunk:
		if current_chunk_distance > CHUNK_SIZE.x:
			previous_chunk = current_chunk
			_set_render_area(current_chunk)
			_update_chunks()
			print("Now in chunk: ", current_chunk)


func _apply_terrains() -> void:
	if not chunk_queue.is_empty(): # If there are chunks in the queue
		chunk_being_generated = chunk_queue.front()
		if not currently_generating:
			# Then begin generation
			currently_generating = true
			generate_chunk(chunk_being_generated)
			#wall_changeset_completed = false
			#ceiling_changeset_completed = false
			
		else: # If currently generating:
			#if BetterTerrain.is_terrain_changeset_ready(wall_changeset):
				#BetterTerrain.apply_terrain_changeset(wall_changeset)
				#wall_changeset_completed = true
			#
			#if BetterTerrain.is_terrain_changeset_ready(ceiling_changeset):
				#BetterTerrain.apply_terrain_changeset(ceiling_changeset)
				#ceiling_changeset_completed = true
			
			#if wall_changeset_completed and ceiling_changeset_completed:
				# Then move on to the next chunk
			currently_generating = false
			#chunk_generated.emit(chunk_being_generated)
			chunk_queue.pop_front()
	else:
		# After initial generation, clear a space around the center of the origin chunk
		if !initial_generation_completed:
			#clear_circle(CHUNK_SIZE/2, 15)
			#exit = EXIT_LADDER.instantiate()
			#add_child(exit)
			#exit.position = spawn_position + Vector2(0, -50)
			initial_generation_completed = true
			print("Initial world generation completed.")
			
			# Re-signal the creation of the origin chunk
			#chunk_generated.emit(Vector2i(0, 0)) 
			#chunk_generated.emit(Vector2i(-1, 0))
			#chunk_generated.emit(Vector2i(1, 0))
			#chunk_generated.emit(Vector2i(0, -1))
			#chunk_generated.emit(Vector2i(0, 1))
			#chunk_generated.emit(Vector2i(-1, -1))
			#chunk_generated.emit(Vector2i(-1, 1))
			#chunk_generated.emit(Vector2i(1, 1))
			#chunk_generated.emit(Vector2i(1, -1))
	
	if not chunks_to_remove.is_empty() and not currently_generating:
		var removal_buffer_size = chunks_to_remove.size()
		var chunk_to_remove: Vector2i
		for chunk in removal_buffer_size:
			chunk_to_remove = chunks_to_remove.pop_front()
			save_chunk(chunk_to_remove)
			unload_chunk(chunk_to_remove)


func save_chunk(chunk: Vector2i) -> void:
	var chunk_data: Dictionary = {}
	# Save the chunk data into the world_chunk_data dictionary
	for x in CHUNK_SIZE.x:
		for y in CHUNK_SIZE.y:
			var tile_pos := Vector2i((chunk.x * CHUNK_SIZE.x) + x, (chunk.y * CHUNK_SIZE.y) + y)
			var chunk_cell_data: Dictionary = {}
			
			chunk_cell_data["Ground Atlas"] = ground_tiles.get_cell_atlas_coords(tile_pos)
			chunk_cell_data["Ground Source"] = ground_tiles.get_cell_source_id(tile_pos)
			#chunk_cell_data["Wall Atlas"] = wall_tile_map.get_cell_atlas_coords(0, tile_pos)
			#chunk_cell_data["Wall Source"] = wall_tile_map.get_cell_source_id(0, tile_pos)
			#chunk_cell_data["Ceiling Atlas"] = ceiling_tile_map.get_cell_atlas_coords(0, tile_pos)
			#chunk_cell_data["Ceiling Source"] = ceiling_tile_map.get_cell_source_id(0, tile_pos)
			
			chunk_data[Vector2i((chunk.x * CHUNK_SIZE.x) + x, (chunk.y * CHUNK_SIZE.y) + y)] = chunk_cell_data
			
	world_chunk_data[chunk] = chunk_data


func unload_chunk(chunk: Vector2i) -> void:
	# Unload chunks behind player
	for x in CHUNK_SIZE.x:
		for y in CHUNK_SIZE.y:
			var tile_pos := Vector2i((chunk.x * CHUNK_SIZE.x) + x, (chunk.y * CHUNK_SIZE.y) + y)
			ground_tiles.set_cell(tile_pos, 0, Vector2i(-1, -1))
			#wall_tile_map.set_cell(0, tile_pos, 0, Vector2i(-1, -1))
			#ceiling_tile_map.set_cell(0, tile_pos, 0, Vector2i(-1, -1))


func generate_chunk(chunk: Vector2i) -> void:
	#chunk_wall_changes.clear()
	#chunk_ceiling_changes.clear()
	var chunk_pos := Vector2i((chunk.x * CHUNK_SIZE.x) - 1, (chunk.y * CHUNK_SIZE.y) - 1)
	_generate_ground(chunk_pos)
	_generate_objects(chunk_pos)
	_generate_dung(chunk_pos)
	#_generate_from_noise(chunk_pos)
	#_generate_dungeon(chunk_pos)
	
	#_generate_falloff(chunk_pos)
	#_generate_from_noise(chunk_pos)
	
	#wall_changeset = BetterTerrain.create_terrain_changeset(wall_tile_map, 0, chunk_wall_changes)
	#ceiling_changeset = BetterTerrain.create_terrain_changeset(ceiling_tile_map, 0, chunk_ceiling_changes)
	
	#print("Generated chunk: ", chunk)


func _generate_ground(pos: Vector2i) -> void:
	var ground_variation := 0.05
	for x in range(CHUNK_SIZE.x):
		for y in range(CHUNK_SIZE.y):
			#var wall = wall_noise.get_noise_2d(pos.x + x, pos.y + y)
			var pos_in_chunk = Vector2i(pos.x + x, pos.y + y)
			
			# Set ground layer
			if ground_variation >= randf():
				# Set some of the ground tiles to a variation
				#ground_tiles.set_cell(pos_in_chunk, 0, Vector2i(randi() % 5, randi() % 2))
				ground_tiles.set_cell(pos_in_chunk, 1, Vector2i(randi_range(3, 10), 4))
			else:
				# Set ground layer to the base color
				ground_tiles.set_cell(pos_in_chunk, 0, Vector2i(1,1))


func _generate_objects(pos: Vector2i) -> void:
	var spawn_chance := 0.02
	for x in range(CHUNK_SIZE.x):
		for y in range(CHUNK_SIZE.y):
			#var wall = wall_noise.get_noise_2d(pos.x + x, pos.y + y)
			var pos_in_chunk = Vector2i(pos.x + x, pos.y + y)
			
			# Set ground layer
			if spawn_chance >= randf():
				# Set some of the ground tiles to a variation
				#ground_tiles.set_cell(pos_in_chunk, 0, Vector2i(randi() % 5, randi() % 2))
				object_tiles.set_cell(pos_in_chunk, 0, Vector2i(randi_range(3, 12), 3))
			#else:
				## Set ground layer to the base color
				#object_tiles.set_cell(pos_in_chunk, 0, Vector2i(1,1))


func _generate_dung(pos: Vector2i) -> void:
	var spawn_chance := 0.05
	for x in range(CHUNK_SIZE.x):
		for y in range(CHUNK_SIZE.y):
			#var wall = wall_noise.get_noise_2d(pos.x + x, pos.y + y)
			var pos_in_chunk = Vector2i(pos.x + x, pos.y + y)
			var world_pos = object_tiles.map_to_local(pos_in_chunk)
			
			# Set ground layer
			if spawn_chance >= randf():
				# Set some of the ground tiles to a variation
				#ground_tiles.set_cell(pos_in_chunk, 0, Vector2i(randi() % 5, randi() % 2))
				#object_tiles.set_cell(pos_in_chunk, 0, Vector2i(randi_range(3, 12), 3))
				var dung = DUNG_PICKUP.instantiate()
				dung.position = world_pos
				dung_node.add_child(dung)
				
			#else:
				## Set ground layer to the base color
				#object_tiles.set_cell(pos_in_chunk, 0, Vector2i(1,1))


func _set_render_area(origin: Vector2i) -> void:
	chunks_to_remove = chunks_in_view.duplicate()
	chunks_in_view.clear()
	for x in (render_distance * 2) + 1:
		for y in (render_distance * 2) + 1:
			chunks_in_view.append(Vector2i(x - render_distance + origin.x, y - render_distance + origin.y))
	chunks_to_render = chunks_in_view.duplicate()
	for chunk in chunks_to_remove: # 		Target the new tiles to render
		chunks_to_render.erase(chunk) # 	by removing the tiles around our previous position.
	for chunk in chunks_in_view: #			Target the tiles to remove
		chunks_to_remove.erase(chunk) #		by removing the tiles that are in view.


func _update_chunks() -> void:
	for chunk in chunks_to_render:
		# Check if the chunks exist in the WorldData
		if not world_chunk_data.has(chunk):
			chunk_queue.append(chunk)
		else:
			load_chunk(chunk)


func load_chunk(chunk: Vector2i) -> void:
	# Load chunks in front of player
	if not world_chunk_data.has(chunk):
		print("Chunk does not exist in world data. Chunk: ", chunk)
		return
		
	for x in CHUNK_SIZE.x:
		for y in CHUNK_SIZE.y:
			var tile_pos := Vector2i((chunk.x * CHUNK_SIZE.x) + x, (chunk.y * CHUNK_SIZE.y) + y)
			ground_tiles.set_cell(tile_pos, world_chunk_data[chunk][tile_pos]["Ground Source"], world_chunk_data[chunk][tile_pos]["Ground Atlas"])
			#wall_tile_map.set_cell(0, tile_pos, world_chunk_data[chunk][tile_pos]["Wall Source"], world_chunk_data[chunk][tile_pos]["Wall Atlas"])
			#ceiling_tile_map.set_cell(0, tile_pos, world_chunk_data[chunk][tile_pos]["Ceiling Source"], world_chunk_data[chunk][tile_pos]["Ceiling Atlas"])
	#print("Loaded chunk: ", chunk)
