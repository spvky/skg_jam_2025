package main

import "core:fmt"
import "core:strings"
import l "core:math/linalg"
import rl "vendor:raylib"
import sa "core:container/small_array"

Input_Buffer :: struct {
	actions: [Input_Action]Buffered_Input,
	lockout: f32
}

Buffered_Input :: union {f32}

Input_Action :: enum {
	Jump,
	Drill
}

update_buffer :: proc() {
	frametime := rl.GetFrameTime()

	if input_buffer.lockout > 0 {
		input_buffer.lockout -= frametime
		if input_buffer.lockout < 0 {
			input_buffer.lockout = 0
		}
	}

	for &buffered in input_buffer.actions {
		switch &v in buffered {
			case f32:
				v -= frametime
				if v <= 0 {
					buffered = nil
				}
		}
	}
}

buffer_action :: proc(action: Input_Action) {
	switch &v in input_buffer.actions[action] {
		case f32:
			v = 0.15
		case:
			input_buffer.actions[action] = 0.15
	}
}


consume_action :: proc(action: Input_Action) {
	input_buffer.actions[action] = nil
}

is_action_buffered :: proc(action: Input_Action) -> bool {
	_, action_pressed := input_buffer.actions[action].(f32)
	return action_pressed
}

input :: proc() {
	frametime := rl.GetFrameTime()
	update_buffer()
	// Tracking raw input in the input buffer
	if rl.IsKeyPressed(.SPACE) do buffer_action(.Jump)
	if rl.IsKeyPressed(.J) do buffer_action(.Drill)
	set_player_delta()
}

set_player_delta :: proc() {
	delta: f32
	if rl.IsKeyDown(.A) && input_buffer.lockout == 0 {
		delta -= 1
	}
	if rl.IsKeyDown(.D) && input_buffer.lockout == 0 {
		delta += 1
	}
	player.x_delta = delta
}

print_player_velocity :: proc() {
	velo_string := fmt.tprintf("Velocity: [%5.2f,%5.2f]", player.velocity.x, player.velocity.y)
	rl.DrawText(strings.clone_to_cstring(velo_string),10, 10, 24, rl.WHITE)
	camera_string := fmt.tprintf("Camera Y Offset: %5.2f", camera.offset.y)
	rl.DrawText(strings.clone_to_cstring(camera_string),10, 34, 24, rl.WHITE)
}

player_jump :: proc() {
	if is_action_buffered(.Jump) {
		#partial switch player.state {
			case .Grounded:
				player.velocity.y = -60
				player.state = .Airborne
				consume_action(.Jump)
			case .Slide:
				jump_force:= Vec2 {0,-45}
				switch player.sliding_wall {
					case .Right:
						jump_force.x = -150
					case .Left:
						jump_force.x = 150
				}
				player.velocity = jump_force
				player.state = .Airborne
				input_buffer.lockout = 0.25
				player.speed[.Slide].acceleration = 0
				consume_action(.Jump)
		}
	}

	if is_action_buffered(.Drill) {
		#partial switch player.state {
			case .Grounded:
				player.velocity.y = -70
				player.state = .Drill
				consume_action(.Drill)
			case .Airborne:
				if player.velocity.y < 100 {
					player.velocity.y = 100
				} else {
					player.velocity.y += 100
				}
				player.state = .Drill
				consume_action(.Drill)
		}
	}
}

