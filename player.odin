package main

import rl "vendor:raylib"
import sa "core:container/small_array"

Player :: struct {
	translation: Vec2,
	radius: f32,
	velocity: Vec2,
	grounded: bool,
	holding_down: bool,
}

player_input :: proc(player: ^Player) {
	if rl.IsKeyDown(.S) {
		player.holding_down = true
	} else {
		player.holding_down = false
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
	return collisions
}
