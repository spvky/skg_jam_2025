package main

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

Player :: struct {
	translation: Vec2,
	snapshot: Vec2,
	radius: f32,
	velocity: Vec2,
	state: Player_State,
	sliding_wall: Sliding_Wall,
	holding_down: bool,
	movement_delta: Vec2,
	speed: [Player_State]Speed,
	last_grounded_pos: Vec2,
}

Speed :: struct {
	max: f32,
	base_acceleration: f32,
	acceleration: f32,
	deceleration: f32
}

Player_State :: enum {
	Airborne,
	Drill,
	Slide,
	Submerged
}

Sliding_Wall :: enum {
	Right,
	Left
}

make_player :: proc() -> Player {
	return Player {
		radius = 4,
		speed = [Player_State]Speed {
			.Airborne = Speed{
				max = 50,
				acceleration = 275,
				base_acceleration = 275,
				deceleration = 0.025
			},
			.Drill = Speed{
				max = 50,
				acceleration = 150,
				base_acceleration = 150,
				deceleration = 0.025
			},
			.Slide = Speed{
				max = 10,
				acceleration = 0.1,
				base_acceleration = 300,
				deceleration = 0.01
			},
			.Submerged = Speed {
				max = 50,
				acceleration = 100,
				base_acceleration = 100,
				deceleration = 0.01
			}
		}
	}
}

print_player_velocity :: proc() {
	velo_string := fmt.tprintf("Velocity: [%5.2f,%5.2f]", player.velocity.x, player.velocity.y)
	rl.DrawText(strings.clone_to_cstring(velo_string),10, 10, 24, rl.WHITE)
	camera_string := fmt.tprintf("Camera Y Offset: %5.2f", camera.offset.y)
	rl.DrawText(strings.clone_to_cstring(camera_string),10, 34, 24, rl.WHITE)
}
