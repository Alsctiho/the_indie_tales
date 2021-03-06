extends Node2D


enum {
	Nothing,
	Blue,
	Red,
	Yellow,
}

var state: int = Nothing
var building_phase = 0
var turret_instance = null

var turret_cost = 10

const turret_node_path = "res://Scenes/Turrets/FakeTurret.tscn"
const texture_path = ["res://Assets/Turrets/TurretTest.png", "res://Assets/Turrets/Turret.png"]
#const BuildSound = preload("res://Assets/Sounds/build.wav")

var playerNode = null

func _ready():
	playerNode = get_node("/root/World/Player")
	
func _process(_delta):		
	if state != Nothing:
		building_turret()

func get_mouse_rotation() -> float:
	var normalized_vector = (get_global_mouse_position() - turret_instance.position).normalized()
	if normalized_vector.y < 0:
		return asin(Vector2.UP.cross(normalized_vector))
	else:
		return PI - asin(Vector2.UP.cross(normalized_vector))

func building_turret() -> void:
	# The first phase: position
	if building_phase == 1:
		turret_instance.position = get_global_mouse_position()
		if turret_instance.get_overlapping_bodies().size() == 0:
			turret_instance.get_node("TurretSprite").modulate = Color(1.0, 1.0, 1.0, 1.0)
			if Input.is_action_just_pressed("ui_left_click"):
				building_phase += 1
		else:
			turret_instance.get_node("TurretSprite").modulate = Color(0.8, 0.0, 0.0, 1.0)

	# The second phase: rotation
	elif building_phase == 2:
		turret_instance.rotation = get_mouse_rotation()
		if Input.is_action_just_pressed("ui_left_click"):
			building_phase += 1

	# The third phase: building
	elif building_phase == 3:
		self.remove_child(turret_instance)
		print(get_node("/root/World/Turrets"))
		get_node("/root/World/Turrets").build_turret(turret_instance.position, turret_instance.rotation, state)
		if !$AudioStreamPlayer.is_playing():
			$AudioStreamPlayer.volume_db = -5
			$AudioStreamPlayer.play()

		# If building success, doing clean up
		turret_instance = null
		building_phase = 0
		state = Nothing

func instance_turret() -> void:
	turret_instance = load(turret_node_path).instance()
	turret_instance.get_node("TurretSprite").texture = load(texture_path[state])
	self.add_child(turret_instance)

func _on_TurretBlue_pressed() -> void:
	state = Blue
#	print("pressed!", building_phase)
	# The zero-th phase: preperation
	if building_phase == 0 && playerNode.use_money(turret_cost):
		instance_turret()
		building_phase += 1
		turret_cost += 5
