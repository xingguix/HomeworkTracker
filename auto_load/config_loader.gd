extends Node

var config_file: FileAccess

func _ready():
	config_file = FileAccess.open("user://config.json", FileAccess.WRITE_READ)

func read_config() -> Dictionary:
	var config = JSON.parse_string(config_file.get_as_text())
	if not config is Dictionary and config:
		return {}
	return config

func save_config(config: Dictionary):
	config_file.store_string(JSON.stringify(config))
