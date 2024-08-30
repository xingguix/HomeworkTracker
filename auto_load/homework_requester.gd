extends HTTPRequest

var url:String
var version: float = float(ProjectSettings.get_setting("application/config/version"))
var key: String
var request_type: String
var default_custom_headers = ["Version: " + str(version), "Key: " + str(key)]
var json_headers = default_custom_headers + ["Content-Type: application/json"]

signal get_result(result)
signal get_error(error)

func check_type(obj: Object, type: int):
	if not typeof(obj) == type:
		var text: String = "返回类型错误,应为"+type_string(type)+"，实则为" + type_string(typeof(obj))
		emit_signal("get_error", text)
		printerr(text)
		return false
	return true

func get_type_default_value(type: int):
	match type:
			TYPE_ARRAY:
				return []
			TYPE_STRING:
				return ""
			TYPE_INT:
				return 0
			TYPE_FLOAT:
				return 0.0
			TYPE_BOOL:
				return false
	printerr("未找到默认值:"+type_string(type))
	return null

func homework_request(
	path: String,
	now_request_type: String,
	method: HTTPClient.Method,
	type: int = -1,
	custom_headers: Array = default_custom_headers,
	data:String = "",
	):
	cancel_request()
	request_type = now_request_type
	var error = request(url + path, custom_headers, method, data)
	if error != OK:
		emit_signal("get_error", request_type + "请求发送失败:" + str(error) + "\n请检查你是否填入了正确的服务器地址！")
		printerr(request_type + "请求发送失败:" + str(error))
	var result = await get_result
	var result_type: int = typeof(result)
	if type != -1 and result_type != type:
		printerr(request_type+"的返回类型错误，应为"+type_string(type)+"，实则为"+type_string(result_type))
		return get_type_default_value(type)
	return result
	
	
func update_homework(data):
	await homework_request("/update_homework", "UPDATE_HOMEWORK", HTTPClient.METHOD_PUT, -1, json_headers, data)


func get_homework():
	var homework: Array = await homework_request("/get_homework", "GET_HOMEWORK", HTTPClient.METHOD_GET, TYPE_ARRAY)
	return homework


func check_OP(user_key: int) -> bool:
	var result: bool = await homework_request("/check_OP", "CHECK_OP", HTTPClient.METHOD_POST, TYPE_BOOL, json_headers, JSON.stringify(user_key))
	return result
	
func get_OPs() -> Array:
	var result: Array = await homework_request("/get_all_OPs", "GET_OPS", HTTPClient.METHOD_GET, TYPE_ARRAY)
	return result

func add_key(data):
	homework_request("/add_key", "ADD_KEY", HTTPClient.METHOD_POST, -1)

func _on_request_completed(result, response_code, headers, body):
	var server_return = JSON.parse_string(body.get_string_from_utf8())
	if response_code != 200:
		emit_signal("get_error", server_return)
		#print(str(response_code) + "  返回:" + server_return)
	emit_signal("get_result", server_return)

func _ready():
	request_completed.connect(Callable(self, "_on_request_completed"))

func _process(delta):
	default_custom_headers = ["Version: " + str(version), "Key: " + str(key)]
	var config := ConfigLoader.read_config()
	url = config["服务器IP"]
	key = config["密钥"]
