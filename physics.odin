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

physics_step :: proc() {
	entity_platform_collision()
	player_jump()
	apply_gravity()
	simulate_dynamics()
}

simulate_dynamics :: proc() {
	for &entity in entities {
		entity.snapshot = entity.translation
		entity.translation += entity.velocity * TICK_RATE
	}
}

apply_gravity :: proc() {
	for &entity in entities {
		if entity.grounded {
			entity.velocity.y = 0
		} else {
			entity.velocity.y += 100 * TICK_RATE
		}
	}
}

entity_platform_collision :: proc() {
	normal_platforms := platform_make_iter(platforms[:])
	one_way_platforms := platform_make_iter(platforms[:], .OneWay)

	for &entity in entities {
	
		if entity.velocity.y >= 0 && !entity.holding_down {
		}

		// grounded check
		for platform in platforms {
			half_height := Vec2{0, entity.height/2}
			nearest_platform := project_point_onto_platform(platform, entity.translation)
			nearest_entity := l.clamp(nearest_platform, entity.translation - half_height, entity.translation + half_height)
			if l.distance(nearest_entity, nearest_platform) < 1 && entity.velocity.y >= 0 {
				entity.grounded = true
			}
		}
	}
}


project_point_onto_platform :: proc(platform: Platform, point: Vec2) -> Vec2 {
	min := platform.translation - (platform.size / 2)
	max := platform.translation + (platform.size / 2)
	return l.clamp(point, min, max)
}
