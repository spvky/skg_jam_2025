package main

import "core:math"
import sa "core:container/small_array"
import l "core:math/linalg"

Collision_Data :: struct {
	collision_normal: Vec2,
	collision_point: Vec2,
	penetration_depth: f32
}

Dynamic_Body :: struct {
	translation: ^Vec2,
	velocity: ^Vec2,
	grounded: bool
}

physics_step :: proc(platforms: []Platform, player: ^Player, frametime: f32) {
	bodies := make([dynamic]Dynamic_Body,0,8, allocator = context.temp_allocator)
	player_platform_collision(player, platforms)
	player_input(player, frametime)
	append(&bodies, Dynamic_Body {
		translation = &player.translation,
		velocity = &player.velocity,
		grounded = player.grounded
	})

	apply_gravity(bodies[:], frametime)
	simulate_dynamics(bodies[:], frametime)
}

simulate_dynamics :: proc(bodies: []Dynamic_Body, frametime: f32) {
	for body in bodies {
		body.translation^ += body.velocity^ * frametime
	}
}

apply_gravity :: proc(bodies: []Dynamic_Body, frametime: f32) {
	for body in bodies {
		if body.grounded {
			body.velocity.y = 0
		} else {
			body.velocity.y += 100 * frametime
		}
	}
}


dynamic_platform_collision :: proc(translation: Vec2, radius: f32, platforms: []Platform) -> [dynamic]Collision_Data {
	collisions := make([dynamic]Collision_Data, 0, 8, allocator = context.temp_allocator)

	for platform in platforms {
		nearest := project_point_onto_platform(platform, translation)
		if l.distance(nearest,translation) < radius {
				collision_vector := translation - nearest
				penetration_depth := radius - l.length(collision_vector)
			append(&collisions, Collision_Data {
				collision_normal = l.normalize(collision_vector),
				collision_point = nearest,
				penetration_depth = penetration_depth
			})
		}
	}
	return collisions
}


project_point_onto_platform :: proc(platform: Platform, point: Vec2) -> Vec2 {
	min := platform.translation - (platform.size / 2)
	max := platform.translation + (platform.size / 2)
	return l.clamp(point, min, max)
}
