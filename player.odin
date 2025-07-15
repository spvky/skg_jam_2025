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
	for &entity in entities {
		if entity.tag == .Player {
			delta: f32
			if rl.IsKeyDown(.A) && input_buffer.lockout == 0 {
				delta -= 1
			}
			if rl.IsKeyDown(.D) && input_buffer.lockout == 0 {
				delta += 1
			}
			entity.x_delta = delta
		}
	}
}

print_player_velocity :: proc() {
	for entity in entities {
		if entity.tag == .Player {
			velo_string := fmt.tprintf("Velocity: %v", entity.velocity)
			rl.DrawText(strings.clone_to_cstring(velo_string),10, 10, 24, rl.WHITE)
		}
	}
}

player_jump :: proc() {
	for &entity in entities {
		if entity.tag == .Player {
			if is_action_buffered(.Jump) {
				#partial switch entity.state {
					case .Grounded:
						entity.velocity.y = -60
						entity.state = .Airborne
						consume_action(.Jump)
					case .Slide:
						jump_force:= Vec2 {0,-45}
						switch entity.sliding_wall {
							case .Right:
								jump_force.x = -150
							case .Left:
								jump_force.x = 150
						}
						entity.velocity = jump_force
						entity.state = .Airborne
						input_buffer.lockout = 0.25
						entity.speed[.Slide].acceleration = 0
						consume_action(.Jump)
				}
			}

			if is_action_buffered(.Drill) {
				#partial switch entity.state {
					case .Grounded:
						entity.velocity.y = -70
						entity.state = .Drill
						consume_action(.Drill)
					case .Airborne:
						if entity.velocity.y < 100 {
							entity.velocity.y = 100
						} else {
							entity.velocity.y += 100
						}
						entity.state = .Drill
						consume_action(.Drill)
				}
			}
		}
	}
}

