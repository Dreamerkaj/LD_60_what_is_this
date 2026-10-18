extends Node2D


@export var next_scene: String

@export var map: TileMapLayer
@export var items_areas: TileMapLayer
@export var player: CharacterBody2D

@export var step_left_txt: Label
@export var max_steps = 0
var steps_left = 0

@export var icon_item_1: TextureRect
@export var icon_item_2: TextureRect
@export var fake_item_texture: Dictionary[Vector2i, Texture2D] = {}
@export var right_item_texture: Texture2D

var get_item_1 = false
var get_item_2 = false
var last_item_texture: Texture2D = null
var get_fake_item = false
var current_item = false
var current_item_cell = false
var removed_items: Dictionary = {}


@export var q: TextureRect
@export var hide_message: TextureRect


@export var can_move_tiles: Array[Vector2i] = []

@export var item_1: Array[Vector2i] = []
@export var area_1: Array[Vector2i] = []
@export var fake_items: Array[Vector2i] = []
const area_to_next_scenes = Vector2i(0,1)

var start_position: Vector2


var win = false

func _ready() -> void:
	steps_left = max_steps
	start_position = player.global_position
	update()
	
	if not G.cutscene:
		player.can_move = false
		await G.start_cutscene()
		player.can_move = true
		G.cutscene = true
	await G.end()
	
	
	





func can_move(scene_pos: Vector2) -> bool:
	var cell: Vector2i = map.local_to_map(
		map.to_local(scene_pos)
	)
	if map.get_cell_source_id(cell) == -1:
		return false
		
	var atlas_coords: Vector2i = map.get_cell_atlas_coords(cell)
	
	return atlas_coords in can_move_tiles

func use_step() -> void:
	if steps_left <= 0:
		return
		
	steps_left -= 1
	
	check_items_areas()
	update()
	
	if steps_left <= 0 and not win:
		reset_level()

func check_items_areas() -> void:
	var cell: Vector2i = items_areas.local_to_map(
		items_areas.to_local(player.global_position)
	)
	if items_areas.get_cell_source_id(cell) == -1:
		return
		
	var atlas_coords: Vector2i = items_areas.get_cell_atlas_coords(cell)
	
	if atlas_coords in item_1:
		pickup_item(cell, atlas_coords, false)
		
	elif atlas_coords in fake_items:
		pickup_item(cell, atlas_coords, true)
		
	elif atlas_coords in area_1:
		if get_item_1:
			get_item_1 = false
			get_fake_item = true
			get_item_2 = true
			current_item = false
			last_item_texture = null
	
	elif atlas_coords == area_to_next_scenes:
		if get_item_2:
			win = true
			change_scene()
	


func pickup_item(cell: Vector2i, atlas_coords: Vector2i, fake_item: bool) -> void:
	if current_item and removed_items.has(current_item_cell):
		var data = removed_items[current_item_cell]
		
		items_areas.set_cell(
			current_item_cell,
			data["source_id"],
			data["atlas_coords"],
			data["alternative_tile"]
		)
		
		removed_items.erase(current_item_cell)
		
	removed_items[cell] = {
				"source_id": items_areas.get_cell_source_id(cell),
				"atlas_coords": atlas_coords,
				"alternative_tile": items_areas.get_cell_alternative_tile(cell)
			}
	items_areas.erase_cell(cell)
	
	current_item_cell = cell
	current_item = true
	
	get_item_1 = not fake_item
	get_fake_item = fake_item
	
	if fake_item:
		last_item_texture = fake_item_texture.get(atlas_coords, null)
	else:
		last_item_texture = right_item_texture
	update()

func change_scene() -> void:
	if not win:
		return
		
	player.can_move = false
	
	player.anim.play("win")
	await player.anim.animation_finished 
	
	
	if next_scene.is_empty():
		return
		
	await G.start()
	get_tree().change_scene_to_file.call_deferred(next_scene)

func check_win() -> bool:
	return get_item_2
	
func reset_level() -> void:
	player.can_move = false
	
	player.anim.play("reset")
	await player.anim.animation_finished 
	
	player.global_position = start_position
	
	steps_left = max_steps
	
	get_item_1 = false
	get_item_2 = false
	win = false
	
	get_fake_item = false
	current_item = false
	last_item_texture = null
	
	for cell in removed_items:
		var data = removed_items[cell]
		
		items_areas.set_cell(
			cell,
			data["source_id"],
			data["atlas_coords"],
			data["alternative_tile"],
		)
		
	removed_items.clear()
	update() 
	
	player.anim.play("start")
	await player.anim.animation_finished 
	
	player.anim.play("idle")
	player.can_move = true
	
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_reset"):
		reset_level()



func update() -> void:
	step_left_txt.text = str(steps_left)
	
	icon_item_1.visible = get_item_1 or get_fake_item
	icon_item_1.texture = last_item_texture
	
	icon_item_2.visible = get_item_2
	
	q.visible = not win
	hide_message.visible = win
	
