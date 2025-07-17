package main

import "core:fmt"

Player :: struct {
	translation: Vec2,
	snapshot: Vec2,
	radius: f32,
	velocity: Vec2,
	state: Player_State,
	sliding_wall: Sliding_Wall,
	holding_down: bool,
	x_delta: f32,
	speed: [Player_State]Speed,
	last_grounded_pos: Vec2,
	water_surface: f32
}

Speed :: struct {
	max: f32,
	base_acceleration: f32,
	acceleration: f32,
	deceleration: f32
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
