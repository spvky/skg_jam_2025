package main

import "core:fmt"
import l "core:math/linalg"
import rl "vendor:raylib"
import sa "core:container/small_array"

Input_Buffer :: struct {
	actions: [Input_Action]Buffered_Input,
	lockout: f32
}

Buffered_Input :: union {f32}

Input_Action :: enum {
	Spin,
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
	if rl.IsKeyPressed(.SPACE) do buffer_action(.Spin)
	set_player_movement_delta()
}

set_player_movement_delta :: proc() {
	delta: Vec2
	if rl.IsKeyDown(.A) && input_buffer.lockout == 0 {
		delta.x -= 1
	}
	if rl.IsKeyDown(.D) && input_buffer.lockout == 0 {
		delta.x += 1
	}
	if rl.IsKeyDown(.W) && input_buffer.lockout == 0 {
		delta.y -= 1
	}
	if rl.IsKeyDown(.S) && input_buffer.lockout == 0 {
		delta.y += 1
	}
	player.movement_delta = delta
}


player_spin :: proc() {
	if is_action_buffered(.Spin) {
		#partial switch player.state {
			case .Submerged:
				input_buffer.lockout = 0.5
				consume_action(.Spin)
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
				consume_action(.Spin)
			case .Airborne:
				if player.velocity.y < 100 {
					player.velocity.y = 100
				} else {
					player.velocity.y += 100
				}
				player.state = .Drill
				consume_action(.Spin)
		}
	}
}

