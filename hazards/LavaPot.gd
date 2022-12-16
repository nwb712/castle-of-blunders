extends Area2D

const lava_sprite = preload("res://hazards/LavaSprite.tscn")


const TILE_SIZE = 8

export var period: float = 2.0
export var num_delay_periods: int = 0
export var num_lava_tiles = 1
export var active = true

var anim_finished = false
var player_colliding = false


# Called when the node enters the scene tree for the first time.
func _ready():
	
	update_collision()
	update_lava()
	
	if active:
		$AnimatedSprite.frame = 4
	else:
		$LavaTiles.visible = false
	
	$Timer.wait_time = abs(period)
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func update_lava():
	var done = false
	var tiles = 0
	while (tiles < num_lava_tiles):
		if $LavaTiles.get_child_count() < num_lava_tiles:
			var lava = lava_sprite.instance()
			lava.position = Vector2($LavaTiles.position.x, TILE_SIZE * tiles)
			$LavaTiles.add_child(lava)
		tiles += 1


func update_collision():
	var collision_shape = $CollisionShape2D
	var shape = RectangleShape2D.new()
	shape.extents.x = TILE_SIZE / 2
	shape.extents.y = int((num_lava_tiles * TILE_SIZE) / 2)
	collision_shape.shape = shape
	collision_shape.position.y = shape.extents.y + TILE_SIZE


func _on_Timer_timeout():
	if num_delay_periods == 0:
		active = not active
		$AnimatedSprite.play("default", (not active))
		$Timer.wait_time = abs(period)
	else:
		num_delay_periods -= 1


func _on_LavaPot_body_entered(body):
	if body.name == "Player" and active and anim_finished:
		EventManager.emit_signal("damaged")
	elif body.name == "Player":
		player_colliding = true


func check_player_colliding():
	if player_colliding:
		EventManager.emit_signal("damaged")


func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.frame == 4:
		$LavaTiles.visible = true
		anim_finished = true
		check_player_colliding()
		if GameManager.in_camera_bounds($CollisionShape2D.global_position):
			if not $LavaSound.playing:
				$LavaSound.play()
	else:
		$LavaTiles.visible = false
		anim_finished = false


func _on_LavaPot_body_exited(body):
	if body.name == "Player":
		player_colliding = false
