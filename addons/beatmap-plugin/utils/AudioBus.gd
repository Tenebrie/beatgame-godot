class_name AudioBus extends Node

var guid: String = UUID.v4()
var busName: StringName

func _ready() -> void:
	var newBusIndex := AudioServer.bus_count
	AudioServer.add_bus(newBusIndex)
	busName = "BeatmapEditor-%s"%[guid]
	AudioServer.set_bus_name(newBusIndex, busName)
	forceRefresh()

func _exit_tree() -> void:
	AudioServer.remove_bus(getBusIndex())
	ResourceSaver.save(AudioServer.generate_bus_layout(), "res://default_bus_layout.tres")

func forceRefresh() -> void:
	var busCount := AudioServer.bus_count
	AudioServer.add_bus()
	AudioServer.remove_bus(busCount)

func getBusIndex() -> int:
	for i in range(AudioServer.bus_count):
		var otherName := AudioServer.get_bus_name(i)
		if busName == otherName:
			return i
	return -1

func getName() -> StringName:
	return busName

func addEffect(effect: AudioEffect) -> void:
	AudioServer.add_bus_effect(getBusIndex(), effect)
	forceRefresh()
