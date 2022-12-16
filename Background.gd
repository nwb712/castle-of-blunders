extends ParallaxBackground


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = get_parent().get_node("Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pos = player.position
	pos.x = (int(pos.x) % 64) / 8
	pos.y = (int(pos.y) % 64) / 8
	scroll_offset = pos
