extends Node

var default_settings: Dictionary = {
	"服务器IP": "http://110.249.126.93:54793",
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
	if not config_file.get_as_text():
		return init()
	config = JSON.parse_string(config_file.get_as_text())
	return config

func read_config() -> Dictionary:
	var original_config := read_original_config()
	var config: Dictionary = original_config.duplicate()
	
	var no_empty_config := original_config.duplicate()
	for i in original_config.keys():
		if not original_config[i] and default_settings[i]:
				no_empty_config[i] = default_settings[i]
	save_config(no_empty_config)
	original_config = no_empty_config
				
	for i in original_config.keys():
		if i in default_settings.keys(): # 如果i属于默认就有的 那就显示
			config[i] = original_config[i]
	return config

func save_config(config: Dictionary):
	var config_file := FileAccess.open(config_file_path, FileAccess.WRITE)
	config_file.store_string(JSON.stringify(config))
