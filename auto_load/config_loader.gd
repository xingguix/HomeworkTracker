extends Node

var default_settings: Dictionary = {
	"服务器IP": "http://xinggui.vip",
	"密钥": ""
}

const config_file_path := "user://config.json"

func init() -> Dictionary:
	save_config(default_settings)
	return default_settings

func read_original_config() -> Dictionary:
	var config: Dictionary
	if not FileAccess.file_exists(config_file_path):
		return init()
	var config_file := FileAccess.open(config_file_path, FileAccess.READ)
	config = JSON.parse_string(config_file.get_as_text())
	return config

func read_config() -> Dictionary:
	var original_config := read_original_config()
	var config: Dictionary = original_config.duplicate()
	for i in original_config.keys():
		if i in default_settings.keys(): # 如果i属于默认就有的
			config[i] = original_config[i]
	return config

func save_config(config: Dictionary):
	var config_file := FileAccess.open(config_file_path, FileAccess.WRITE)
	config_file.store_string(JSON.stringify(config))
