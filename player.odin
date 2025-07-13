package main

import l "core:math/linalg"
import rl "vendor:raylib"
import sa "core:container/small_array"



Player :: struct {
	translation: Vec2,
	height: f32,
	radius: f32,
	velocity: Vec2,
	grounded: bool,
	holding_down: bool,
	input_buffer: InputBuffer
}

InputBuffer :: struct {
	input: BufferedInput
}



BufferedInput :: union {f32}


player_input :: proc(player: ^Player, frametime: f32) {
	if rl.IsKeyDown(.S) {
		player.holding_down = true
	} else {
		player.holding_down = false
	}

	if rl.IsKeyPressed(.SPACE) {
		switch &v in player.input_buffer.input {
			case f32:
				v = 0.3
			case:
				player.input_buffer.input = 0.3
		}
	} else {
		switch &v in player.input_buffer.input {
			case f32:
				v -= frametime
				if v <= 0 {
					player.input_buffer.input = nil
				}
		}
	}

	_, jump_pressed := player.input_buffer.input.(f32)
	if jump_pressed && player.grounded {
		player.velocity.y = -60
		// player.translation.y -= 10
		player.grounded = false
	}
}

player_platform_collision :: proc(player: ^Player, platforms: []Platform) -> [dynamic]Collision_Data {
	normal_platforms := platform_make_iter(platforms)
	one_way_platforms := platform_make_iter(platforms, .OneWay)

	collisions := dynamic_platform_collision(player.translation, player.radius, sa.slice(&normal_platforms.platforms))

	
	if player.velocity.y >= 0 && !player.holding_down {
		one_way_collisions := dynamic_platform_collision(player.translation, player.radius, sa.slice(&one_way_platforms.platforms))
		if len(one_way_collisions) > 0 {
			append_elems(&collisions, ..one_way_collisions[:])
		}
	}

	// grounded check
	for platform in platforms {
		half_height := Vec2{0, player.height/2}
		nearest_platform := project_point_onto_platform(platform, player.translation)
		nearest_player := l.clamp(nearest_platform, player.translation - half_height, player.translation + half_height)
		if l.distance(nearest_player, nearest_platform) < 1 && player.velocity.y >= 0 {
			player.grounded = true
		}
	}
	return collisions
}
