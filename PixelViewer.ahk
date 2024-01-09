#SingleInstance force

SetDefaultMouseSpeed, 0

CoordMode, Pixel, Client
CoordMode, Mouse, Client

minecraft_window := WinExist("Minecraft")

getClientSize(minecraft_window, width, height)

global pixel_size := 2
global char_color := 0xAAAAAA
global x_ench_digit := (width + 132 * pixel_size) // 2 ; 644
global y_ench_digit := (height - 44 * pixel_size) // 2 ; 246
global digit_color := 0x80FF20

F9::
x := 240
y := 496
MouseMove, x, y
Sleep, 1000

; 428
PixelGetColor, color, x, y
enchantment := getEnchantment(428, 262)
level := getNumberLevel(516, 262)
number := getNumber()
MsgBox, %color%

getNumber() {
	return 10 * getDigit(x_ench_digit, y_ench_digit) + getDigit(x_ench_digit + 6 * pixel_size, y_ench_digit)
}

getDigit(x_pos, y_pos) {
	PixelGetColor, pixel_a, x_pos, y_pos, RGB
	PixelGetColor, pixel_b, x_pos + pixel_size, y_pos, RGB
	PixelGetColor, pixel_c, x_pos, y_pos + 2 * pixel_size, RGB
	PixelGetColor, pixel_d, x_pos + pixel_size, y_pos + 4 * pixel_size, RGB
	PixelGetColor, pixel_e, x_pos + 3 * pixel_size, y_pos + 6 * pixel_size, RGB

	; MsgBox, %x_pos% %y_pos%

	if (pixel_b == digit_color) {
		if (pixel_c == digit_color) {
			if (pixel_a == digit_color) {
				return 5
			} else {
				if (pixel_d == digit_color) {
					return 0
				} else {
					if (pixel_e == digit_color) {
						return 8
					} else {
						return 9
					}
				}
			}
		} else {
			if (pixel_a == digit_color) {
				return 7
			} else {
				if (pixel_d == digit_color) {
					return 2
				} else {
					return 3
				}
			}
		}
	} else {
		if (pixel_e == digit_color) {
			if (pixel_c == digit_color) {
				return 6
			} else {
				return 1
			}
		} else {
			if (pixel_d == digit_color) {
				return 4
			} else {
				return 0
			}
		}
	}
}

getEnchantment(x_pos, y_pos) {
	PixelGetColor, pixel_a, x_pos + 8 * pixel_size, y_pos, RGB
	PixelGetColor, pixel_b, x_pos + 4 * pixel_size, y_pos + 3 * pixel_size, RGB

	if (pixel_a == char_color) {
		if (pixel_b == char_color) {
			return "Silk Touch"
		} else {
			return "Efficiency"
		}
	} else {
		if (pixel_b == char_color) {
			return "Unbreaking"
		} else {
			return "Fortune"
		}
	}
}

getNumberLevel(x_pos, y_pos) {
	PixelGetColor, pixel_a, x_pos + 5 * pixel_size, y_pos, RGB
	PixelGetColor, pixel_b, x_pos + 8 * pixel_size, y_pos, RGB
	;MsgBox %pixel_a% %pixel_b%

	if (pixel_a == char_color) {
		if (pixel_b == char_color) {
			return 3
		} else {
			return 2
		}
	} else {
		if (pixel_b == char_color) {
			return 4
		} else {
			return 5
		}
	}
}

getClientSize(window, ByRef width := "", ByRef height := "") {
	VarSetCapacity(rect, 16)
	DllCall("GetClientRect", "ptr", window, "ptr", &rect)
	width := NumGet(rect, 8, "int")
	height := NumGet(rect, 12, "int")
}