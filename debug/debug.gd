class_name Debug

static func debug_print(arg1 = "", arg2 = "", arg3 = "", arg4 = "", arg5 = "", arg6 = "", arg7 = "", arg8 = ""):
	if OS.is_debug_build():
		print(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
