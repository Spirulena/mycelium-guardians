extends Object
class_name Utils

static func get_plus_sign_string(x: Variant) -> String:
	var s = sign(x)
	if s == 1:
		return "+"
	elif s == -1:
		return ""
	else:
		return ""

static func get_plus_minus_sign_string(x: Variant) -> String:
	var s = sign(x)
	if s == 1:
		return "+"
	elif s == -1:
		return "-"
	else:
		return ""

static func print_debug_time(text = "Default"):
	print_debug("%s: %s - %s" % [text, Time.get_ticks_msec(), Time.get_ticks_msec()/1000.0])
