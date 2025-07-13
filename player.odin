package main

import l "core:math/linalg"
import rl "vendor:raylib"
import sa "core:container/small_array"

InputBuffer :: struct {
	input: BufferedInput
}


BufferedInput :: union {f32}


input :: proc() {
	frametime := rl.GetFrameTime()

	if rl.IsKeyPressed(.SPACE) {
		switch &v in input_buffer.input {
			case f32:
				v = 0.3
			case:
				input_buffer.input = 0.3
		}
	} else {
		switch &v in input_buffer.input {
			case f32:
				v -= frametime
				if v <= 0 {
					input_buffer.input = nil
				}
		}
	}
}

player_jump :: proc() {
	for &entity in entities {
		if entity.tag == .Player {
			_, jump_pressed := input_buffer.input.(f32)
			if jump_pressed && entity.grounded {
				entity.velocity.y = -60
				entity.grounded = false
			}
		}
	}
}

