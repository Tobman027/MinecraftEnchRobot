#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
Process, Priority, , H
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, 1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
#SingleInstance force

CoordMode, Pixel, Client
CoordMode, Mouse, Client

; Global variables
global enchanting_material := "Stone"
global clock := 1
global lag := 60
global error := false
global finished := false
global order_for_backup := false
global backup_requirements := {"Efficiency": 5, "Unbreaking": 3, "Fortune": 3, "Silk Touch": 1}
global order_for_finish := true
global finish_requirements := {"Efficiency": 5, "Unbreaking": 3, "Fortune": 3, "Silk Touch": 1}
global actual_enchantments := []
global actual_levels := []
global world_folder := ""
global backup_folder := ""
global world_name := getWorldName()
global minecraft_window := WinExist("Minecraft")

; Pixels stuff
global pixel_size := 3
global height := 0
global width := 0
getClientSize(minecraft_window, width, height)
global x_center := width // 2
global y_center := height // 2

; searchEnchantmentRobot constants
global x_to_menu := floor(width - 109.3 * pixel_size) // 2
global y_to_menu := floor(height + 137.7 * pixel_size) // 2
global x_singleplayer := floor(width - 69.3 * pixel_size) // 2
global y_singleplayer := floor(height - 33.7 * pixel_size) // 2
global x_worlds := floor(width - 65.3 * pixel_size) // 2
global y_worlds := floor(height - 16.3 * pixel_size) // 2
global x_enter_world := floor(width - 271.3 * pixel_size) // 2
global y_enter_world := floor(height + 207.7 * pixel_size) // 2
global color_button := 0x6E6E6E
global color_worlds := 0x0B0805

; openEnchantmentGui constants
global x_tool_slot := x_center - 4 * pixel_size
global y_tool_slot := y_center + 9 * pixel_size
global y_handgrip := y_center + 14 * pixel_size
global color_ench_table := 0xFCFDFC
global color_tool_slot := 0xC5C5C5
global color_handgrip := 0xC4B393

; getDigit constants
global x_first_digit := (width + 132.7 * pixel_size) // 2
global x_second_digit := x_first_digit + 6 * pixel_size
global y_digit := (height - 44.3 * pixel_size) // 2
global x_fd_off4 := x_first_digit + 4 * pixel_size
global x_sd_off1 := x_second_digit + pixel_size
global x_sd_off3 := x_second_digit + 3 * pixel_size
global y_d_off2 := y_digit + 2 * pixel_size
global y_d_off4 := y_digit + 4 * pixel_size
global y_d_off6 := y_digit + 6 * pixel_size
global digit_color := 0x80FF20

; lookForEnchantment constants
global desired_level := getMinLevel(enchanting_material)
global x_ench_slot := (width - 111.3 * pixel_size) // 2
global y_ench_slot := (height - 54 * pixel_size) // 2
global x_ench_level := x_first_digit + 12 * pixel_size
global color_ench_level := 0xA09172

; evaluateEnchantment constants
global x_enchantment := x_ench_slot + 12 * pixel_size
global y_first_ench := y_ench_slot + 1
global y_ench_box := y_first_ench + 8 * pixel_size
global y_second_ench := y_first_ench + 10 * pixel_size
global y_third_ench := y_first_ench + 20 * pixel_size
global y_fourth_ench := y_first_ench + 30 * pixel_size
global x_e_off4 := x_enchantment + 4 * pixel_size
global x_e_off8 := x_enchantment + 8 * pixel_size
global x_efficiency_level := x_enchantment + 54 * pixel_size
global x_unbreaking_level := x_enchantment + 59 * pixel_size
global x_fortune_level := x_enchantment + 44 * pixel_size
global color_ench_box := 0x1B0C1B
global char_color := 0xAAAAAA

; Auxiliar Window
^F6::
Gui, +AlwaysOnTop
Gui, Add, Text, vEnchs w180 h50 Center, 0
Gui, Show, w200 h70 Center, Helper Window
return

; Normal functions
F6::GoSub, startScript

; Control functions
^F4::GoSub, createBackup
^F5::GoSub, loadBackup
^F7::Reload
^F8::ExitApp

startScript:
	while (desired_level <= 50 && minecraft_window && !finished) {
		GoSub, loadBackupRobot
		GoSub, searchEnchantmentRobot
	}
return

loadBackupRobot:
	GoSub, loadBackup
	GoSub, reloadWorld
return

searchEnchantmentRobot:
	GoSub, openEnchantmentGui

	if (error) {
		error := false
		return
	}

	GoSub, lookForEnchantment
	GoSub, evaluateEnchantment
return

loadBackup:
	FileCopyDir, %backup_folder%\%world_name%, %world_folder%, 1
return

reloadWorld:
	waitForUpdate(x_to_menu, y_to_menu, color_button)
	Click, %x_to_menu% %y_to_menu%
	waitForUpdate(x_singleplayer, y_singleplayer, color_button)
	Click, %x_singleplayer% %y_singleplayer%
	waitForUpdate(x_worlds, y_worlds, color_worlds)
	GoSub, clickUntilSelected
	Click, %x_enter_world% %y_enter_world%
return

openEnchantmentGui:
	waitForUpdate(x_center, y_center, color_ench_table)
	Click, Right
	waitForUpdate(x_tool_slot, y_tool_slot, color_tool_slot)
	PixelGetColor, pixel_handgrip, x_tool_slot, y_handgrip, RGB

	if (pixel_handgrip != color_handgrip) {
		error := true
	}
return

lookForEnchantment:
	Click, Left
	Click, %x_ench_slot% %y_ench_slot%
	waitForUpdate(x_ench_level, y_digit, color_ench_level)

	while (getNumber() < desired_level) {
		Click, %x_ench_slot% %y_ench_slot% Left 2
		waitForUpdate(x_ench_level, y_digit, color_ench_level)
	}

	Click, %x_ench_level% %y_digit%
	MouseMove, x_ench_slot, y_ench_slot
return

evaluateEnchantment:
	waitForUpdate(x_enchantment, y_ench_box, color_ench_box)
	GoSub, loadActualEnchantments
	GoSub, showEnchantments

	Sleep, lag

	if (backupConditionsMet()) {
		GoSub, createBackup
		Sleep, lag
	}

	if (finishedConditionsMet()) {
		finished := true
	}

	GoSub, clearActualEnchantments
return

loadActualEnchantments:
	st_ench := getEnchantment(y_first_ench)
	st_lvl := getLevel(y_first_ench, st_ench)
	addActualEnchantment(st_ench, st_lvl)
	nd_ench := getEnchantment(y_second_ench)
	nd_lvl := getLevel(y_second_ench, nd_ench)

	if (nd_ench != "Fortune" || nd_lvl != 5) {
		addActualEnchantment(nd_ench, nd_lvl)
		rd_ench := getEnchantment(y_third_ench)
		rd_lvl := getLevel(y_third_ench, rd_ench)

		if (rd_ench != "Fortune" || rd_lvl != 5) {
			addActualEnchantment(rd_ench, rd_lvl)
			th_ench := getEnchantment(y_fourth_ench)
			th_lvl := getLevel(y_fourth_ench, th_ench)

			if (th_ench != "Fortune" || th_lvl != 5) {
				addActualEnchantment(th_ench, th_lvl)
			}
		}
	}
return

clearActualEnchantments:
	loop % actual_enchantments.length() {
		actual_enchantments.pop()
		actual_levels.pop()
	}
return

showEnchantments:
	enchantments := ""

	loop % actual_enchantments.length() {
		enchantments := enchantments actual_enchantments[A_Index] actual_levels[A_Index] "`n"
	}

	GuiControl, , Enchs, %enchantments%
return

clickUntilSelected:
	Sleep, clock
	Click, %x_worlds% %y_worlds%
	PixelGetColor, pixel_color, x_enter_world, y_enter_world, RGB

	while (pixel_color != color_button) {
		Sleep, clock
		Click, %x_worlds% %y_worlds%
		PixelGetColor, pixel_color, x_enter_world, y_enter_world, RGB
		Sleep, clock
	}
return

createBackup:
	if (world_name == "UNKNOWN") {
		world_name := getWorldName()
	}

	new_folder := world_name

	if (actual_enchantments.length() > 0) {
		first := true
		enchs := SubStr(enchanting_material, 1, 1) "["
		FormatTime, current_time, , yy-MM-dd HH.mm.ss

		loop % actual_enchantments.length() {
			if (!first) {
				enchantments := enchantments " "
				first := false
			}

			enchantments := enchantments subStr(actual_enchantments[A_Index], 1, 1) actual_levels[A_Index]
		}

		new_folder := current_time " " enchs "]"
	}

	FileCreateDir, %backup_folder%\%new_folder%
	FileCopyDir, %world_folder%, %backup_folder%\%new_folder%, 1
return

getMinLevel(material) {
	if (material == "Gold") {
		return 43
	} else if (material == "Iron") {
		return 46
	} else if (material == "Diamond") {
		return 47
	} else if (material == "Stone") {
		return 48
	} else if (material == "Wood") {
		return 49
	} else {
		return 51
	}
}

addActualEnchantment(enchantment, level) {
	actual_enchantments.push(enchantment)
	actual_levels.push(level)
}

getNumber() {
	first_digit := getFirstDigit()

	if (first_digit < 4) {
		return 0
	} else {
		return 10 * first_digit + getSecondDigit()
	}
}

getFirstDigit() {
	PixelGetColor, pixel_a, x_fd_off4, y_digit, RGB

	if (pixel_a == digit_color) {
		PixelGetColor, pixel_b, x_first_digit, y_digit, RGB

		if (pixel_b == digit_color) {
			return 5
		} else {
			return 4
		}
	}
}

getSecondDigit() {
	PixelGetColor, pixel_a, x_second_digit, y_digit, RGB
	PixelGetColor, pixel_b, x_sd_off1, y_digit, RGB
	PixelGetColor, pixel_c, x_second_digit, y_d_off2, RGB
	PixelGetColor, pixel_d, x_sd_off1, y_d_off4, RGB
	PixelGetColor, pixel_e, x_sd_off3, y_d_off6, RGB

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

getEnchantment(y_pos) {
	PixelGetColor, pixel_a, x_e_off8, y_pos, RGB
	PixelGetColor, pixel_b, x_e_off4, y_pos + 3 * pixel_size, RGB

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

getLevel(y_pos, enchantment) {
	if (enchantment == "Efficiency") {
		return getNumberLevel(x_efficiency_level, y_pos)
	} else if (enchantment == "Unbreaking") {
		return getNumberLevel(x_unbreaking_level, y_pos)
	} else if (enchantment == "Fortune") {
		return getNumberLevel(x_fortune_level, y_pos)
	} else if (enchantment == "Silk Touch") {
		return 1
	} else {
		return 0
	}
}

getNumberLevel(x_pos, y_pos) {
	PixelGetColor, pixel_a, x_pos + 5 * pixel_size, y_pos, RGB
	PixelGetColor, pixel_b, x_pos + 8 * pixel_size, y_pos, RGB

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

backupConditionsMet() {
	return conditionsMet(order_for_backup, backup_requirements)
}

finishedConditionsMet() {
	return conditionsMet(order_for_finish, finish_requirements)
}

conditionsMet(ordered, requirements) {
	if (requirements.length() == actual_enchantments.length()) {
		if (ordered) {
			index = 1

			for ench_i, lvl_i in requirements {
				if (ench_i != actual_enchantments[index] || lvl_i != actual_levels[index]) {
					return false
				}

				++index
			}
		} else {
			loop % actual_enchantments.length() {
				ench_i := actual_enchantments[A_Index]
				lvl_i := actual_levels[A_Index]

				if (requirements[ench_i] != lvl_i) {
					return false
				}
			}
		}

		return true
	}

	return false
}

waitForUpdate(x_pos, y_pos, color) {
	PixelGetColor, pixel_color, x_pos, y_pos, RGB

	while (pixel_color != color) {
		Sleep, clock
		PixelGetColor, pixel_color, x_pos, y_pos, RGB
	}
}

getWorldName() {
	next := false
	world := "UNKNOWN"

	loop, parse, world_folder, `\
	{
		if (next) {
			world := A_LoopField
			break
		}

		if (A_LoopField == "saves") {
			next := true
		}
	}

	return %world%
}

getClientSize(window, ByRef width := "", ByRef height := "") {
	VarSetCapacity(rect, 16)
	DllCall("GetClientRect", "ptr", window, "ptr", &rect)
	width := NumGet(rect, 8, "int")
	height := NumGet(rect, 12, "int")
}
