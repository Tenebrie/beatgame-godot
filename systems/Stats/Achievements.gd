extends Node

func SaveValue(key: String, value: Variant) -> void:
	var config := ConfigFile.new()
	config.load("user://save.cfg")  # OK if file doesn't exist yet
	config.set_value("save", key, value)
	config.save("user://save.cfg")

func LoadValue(key: String, default_value: Variant = null) -> Variant:
	var config := ConfigFile.new()
	if config.load("user://save.cfg") != OK:
		return default_value
	return config.get_value("save", key, default_value)
