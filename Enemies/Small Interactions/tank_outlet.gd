extends Area3D

var pulled: bool = false:
	set(value):
		print("[TankOutlet] pulled SET to: ", value)
		pulled = value

var connected = null
var battery: float = 0.0
var batteryMax: float = 1.0
var outlet_light: Node3D = Node3D.new()
