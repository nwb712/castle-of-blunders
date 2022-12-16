extends KinematicBody2D

"""
Member Variables
"""

# Player states
enum States {NEUTRAL, MINING, CLIMBING, DASHING, KNOCKBACK}
var state = States.NEUTRAL

# Movement and Gravity
var terminal_velocity = 50

var gravity = 8
var move_speed = 30

var dash_speed = 150
var dash_drag = 20
var dash_flag = false

var knockback_vector = Vector2(-25, -50)
var knockback_flag = false
var knockback_counter = 0
var knockback_max = 10

var jump_impulse = 100
var movement_vector = Vector2(0, 0)

var last_ground_location = Vector2(0, 0)

# Player Actions
var lock_inputs = false
var can_jump = false
var can_climb = false
var can_dash = false
var can_dig = false

# Animation
onready var _animated_sprite = get_node("AnimatedSprite")
var wait_for_anim = false

# Tile Detection
onready var _tilemap = get_owner().get_node("TileMap")
onready var _facing = get_node("Facing")
var _facing_forward = Vector2(6, 0)
var _facing_backward = Vector2(-6, 0)

# Audio Counter
var step_count = 0
var step_max = 15

var play_landing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	EventManager.connect("rope_entered", self, "_on_rope_entered")
	EventManager.connect("rope_exited", self, "_on_rope_exited")
	EventManager.connect("damaged", self, "_on_damaged")
	
	# Record player ground postion in case they get stuck somewhere
	last_ground_location = Vector2(position.x, position.y)

""""
Loops
"""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == States.NEUTRAL:
		if is_on_floor() and movement_vector.x != 0:
			if not $PlayerWalking.playing and step_count >= step_max:
				$PlayerWalking.play()
				step_count = 0
			step_count += 1


func _physics_process(delta):
	if not lock_inputs:
		get_input()
	update_anim()
	perform_actions()
	
	"""
	for i in get_slide_count() - 1:
		var collision = get_slide_collision(i)
		print(collision.collider.name)
	"""


"""
Input managers
"""


# Retrieve input contextually based on state
func get_input():
	match state:
		States.NEUTRAL:
			# Get movement input
			get_input_movement()
			apply_gravity()
			# State changes
			if Input.is_action_just_pressed("dig") and can_dig:
				"""
				state = States.MINING
				wait_for_anim = true
				"""
			if Input.is_action_pressed("up") and can_climb:
				state = States.CLIMBING
			if Input.is_action_just_pressed("dash") and can_dash:
				state = States.DASHING
				dash_flag = true
				can_dash = false
		States.CLIMBING:
			movement_vector = Vector2.ZERO
			position.x -= int(int(position.x) % 8 - 4)
			if Input.is_action_pressed("up"):
				movement_vector.y = -move_speed
			elif Input.is_action_pressed("down"): 
				movement_vector.y = move_speed * 2
			elif is_on_floor() and movement_vector.y != 0:
				state = States.NEUTRAL
			if Input.is_action_pressed("jump"):
				# movement_vector.y = 0
				apply_jump_impulse()
				apply_gravity()
				state = States.NEUTRAL
		States.MINING:
			movement_vector = Vector2.ZERO
			can_dig = false
		States.DASHING:
			movement_vector.y = 0
			if dash_flag:
				if _facing.cast_to.x > 0:
					movement_vector.x = dash_speed
				else:
					movement_vector.x = -dash_speed
				dash_flag = false
			else:
				if abs(movement_vector.x) > abs(move_speed):
					if movement_vector.x > 0:
						movement_vector.x -= dash_drag
					else:
						movement_vector.x += dash_drag
				else:
					if Input.is_action_pressed("dig") and can_dig:
						state = States.MINING
						wait_for_anim = true
					else:
						state = States.NEUTRAL
		States.KNOCKBACK:
			if knockback_flag:
				$PlayerHurt.play()
				GameManager.invulnerable = true
				if _facing.cast_to.x > 0:
					movement_vector = knockback_vector
				else:
					movement_vector = knockback_vector
					movement_vector.x = -movement_vector.x
				knockback_flag = false
			else:
				if not is_on_floor():
					apply_gravity()
					if is_on_wall():
						# Switch x direction of movement so player doesn't get stuck
						movement_vector.x = -movement_vector.x
						# Update facing vector so subsequent knockback is correct
						_facing.cast_to.x = -_facing.cast_to.x
				else:
					sync_facing_with_sprite()
					knockback_counter = 0
					state = States.NEUTRAL
					GameManager.invulnerable = false
					movement_vector.x = 0


func get_input_movement():
	# Horizontal Movement
	if Input.is_action_pressed("left"):
		movement_vector.x = -move_speed
	elif Input.is_action_pressed("right"):
		movement_vector.x = move_speed
	else:
		movement_vector.x = 0
	# Vertical Movement
	if Input.is_action_just_pressed("jump") and can_jump:
		apply_jump_impulse()
		can_jump = false
		# play_landing = true


func apply_gravity():
	# Gravity clamped by terminal velocity
	if movement_vector.y < terminal_velocity:
		movement_vector.y += gravity
		movement_vector.y = clamp(movement_vector.y, -terminal_velocity * 4, terminal_velocity)


func apply_jump_impulse():
	movement_vector.y = -jump_impulse


"""
Detection
"""


func update_detection():
	update_facing()
	update_jump()


func update_facing():
	if movement_vector.x < 0:
		_facing.cast_to.x = _facing_backward.x
	if movement_vector.x > 0:
		_facing.cast_to.x = _facing_forward.x


func sync_facing_with_sprite():
	if $AnimatedSprite.flip_h:
		_facing.cast_to.x = -abs(_facing.cast_to.x)
	else:
		_facing.cast_to.x = abs(_facing.cast_to.x)


func update_jump():
	if is_on_floor():
		can_jump = true
		can_dash = true
		can_dig = true
		if play_landing:
			$PlayerLanding.play()
			play_landing = false
		if state == States.CLIMBING:
			state = States.NEUTRAL
		elif state == States.NEUTRAL:
			last_ground_location = Vector2(int(position.x / 8 * 8), int(position.y / 8 * 8))
	else:
		play_landing = true


func get_facing_tile_pos():
	var hit_collider = _facing.get_collider()
	if hit_collider is TileMap:
		var hit_pos = _facing.get_collision_point()
		if _facing.cast_to.x < 0:
			hit_pos.x -= 1
		return _tilemap.world_to_map(hit_pos)
	return 


"""
Actions
"""


func return_to_last_ground_pos():
	position = last_ground_location


func perform_actions():
	move_and_slide(movement_vector, Vector2.UP)
	match state:
		States.NEUTRAL:
			update_detection()
		States.CLIMBING:
			update_jump()
		States.MINING:
			if not wait_for_anim:
				dig()
				state = States.NEUTRAL


func dig():
	var collider = _facing.get_collider()
	if collider and collider.is_in_group("destructable"):
		collider.emit_signal("destroy")
	# Keeping this for now as it worked well to detech tileset
	"""
	var tile_pos = get_facing_tile_pos()
	if tile_pos is Vector2:
		print("Position exists: x: %s y: %s" % [tile_pos.x, tile_pos.y])
		_tilemap.set_cellv(tile_pos, -1)
		_tilemap.update_bitmask_region()
	"""


"""
Animation
"""


func update_anim():
	match state:
		States.NEUTRAL:
			if movement_vector.x < 0:
				_animated_sprite.flip_h = true
				if is_on_floor():
					_animated_sprite.play("moving")
				else:
					_animated_sprite.play("jumping")
			elif movement_vector.x > 0:
				_animated_sprite.flip_h = false
				if is_on_floor():
					_animated_sprite.play("moving")
				else:
					_animated_sprite.play("jumping")
			elif movement_vector.x == 0:
				_animated_sprite.play("idle")
		States.CLIMBING:
			_animated_sprite.play("climbing")
		States.MINING:
			_animated_sprite.play("digging")
		States.KNOCKBACK:
			pass
	if GameManager.invulnerable:
		var toggle = $AnimatedSprite.material.get_shader_param("active")
		$AnimatedSprite.material.set_shader_param("active", (not toggle))
	else:
		$AnimatedSprite.material.set_shader_param("active", false)


"""
Signal Listeners
"""


func _on_AnimatedSprite_animation_finished():
	if wait_for_anim:
		wait_for_anim = false


func _on_damaged():
		state = States.KNOCKBACK
		knockback_flag = true
		knockback_counter += 1
		if knockback_counter >= knockback_max:
			state = States.NEUTRAL
			GameManager.invulnerable = false
			return_to_last_ground_pos()
			knockback_counter = 0


func _on_rope_entered():
	can_climb = true


func _on_rope_exited():
	can_climb = false
	if state == States.CLIMBING:
		state = States.NEUTRAL
