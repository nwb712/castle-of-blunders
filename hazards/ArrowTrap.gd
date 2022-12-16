extends Area2D


const arrow = preload("res://hazards/projectiles/Arrow.tscn")

const OFFSET_X_LEFT = -10
const OFFSET_X_RIGHT = 4
const OFFSET_Y = -1

# False for right true for left
export var magnitude: float = 1.0
export var period: float = 1.0

var spawn_positions = {
	"LEFT": Vector2(OFFSET_X_LEFT, OFFSET_Y),
	"RIGHT": Vector2(OFFSET_X_RIGHT, OFFSET_Y),
}


# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = abs(period)


func _init():
	pass


func spawn_arrow():
	var new_arrow = arrow.instance()
	new_arrow.move = magnitude
	# Choose spawn position
	if magnitude > 0:
		new_arrow.position = spawn_positions["RIGHT"]
	else:
		new_arrow.position = spawn_positions["LEFT"]
	self.add_child(new_arrow)


func _on_Timer_timeout():
	spawn_arrow()
