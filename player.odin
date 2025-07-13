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

	player_movement()
}

player_movement :: proc() {
	for &entity in entities {
		if entity.tag == .Player {
			delta: f32
			if rl.IsKeyDown(.A) {
				delta -= 1
			}
			if rl.IsKeyDown(.D) {
				delta += 1
			}

			if delta == 0 {
				entity.velocity.x = entity.velocity.x * 0.999
			} else {
				entity.velocity.x = delta * 50
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

