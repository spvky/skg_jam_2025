package main

import "core:fmt"
import "core:math"
import sa "core:container/small_array"
import l "core:math/linalg"

Collision_Data :: struct {
	normal: Vec2,
	mtv: Vec2
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

	calculate_collision :: proc(collisions: ^[dynamic]Collision_Data, nearest_entity: Vec2, nearest_collider: Vec2, radius: f32) {
		collision: Collision_Data
		collision_vector := nearest_entity - nearest_collider
		pen_depth := radius - l.length(collision_vector)
		collision_normal := l.normalize(collision_vector)
		mtv := collision_normal * pen_depth
		collision.normal = collision_normal
		collision.mtv = mtv
		append(collisions, collision)
	}

	for &entity in entities {
		collisions := make([dynamic]Collision_Data, 0, 8, allocator = context.temp_allocator)

		for platform in platforms {
			half_height := Vec2{0, entity.height/2}
			nearest_platform := project_point_onto_platform(platform, entity.translation)
			nearest_entity := l.clamp(nearest_platform, entity.translation - half_height, entity.translation + half_height)

			should_ignore := entity.velocity.y < 1 && platform.type == .OneWay
			if l.distance(nearest_entity, nearest_platform) < entity.radius  && !should_ignore{
				calculate_collision(&collisions, nearest_entity, nearest_platform, entity.radius)
			}
		}

		for collision in collisions {
			entity.translation += collision.mtv
			x_dot := math.abs(l.dot(collision.normal, Vec2{1,0}))
			y_dot := math.abs(l.dot(collision.normal, Vec2{0,1}))
			if  x_dot > 0.7 {
				entity.velocity.x = 0
			}
			if y_dot > 0.7 {
				entity.velocity.y = 0
			}
		}

		// grounded check
		ground_hits: int
		for platform in platforms {
			feet_position := entity.translation + Vec2{0, entity.height}
			nearest_platform := project_point_onto_platform(platform, feet_position)
			if l.distance(feet_position, nearest_platform) < 1 && entity.velocity.y >= 0 {
				ground_hits += 1
			}
		}
		if ground_hits > 0 {
			entity.grounded = true
		} else {
			entity.grounded = false
		}
	}
}


project_point_onto_platform :: proc(platform: Platform, point: Vec2) -> Vec2 {
	min := platform.translation - (platform.size / 2)
	max := platform.translation + (platform.size / 2)
	return l.clamp(point, min, max)
}
