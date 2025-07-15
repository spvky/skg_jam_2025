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
	manage_entity_x_velocity()
	simulate_dynamics()
}

simulate_dynamics :: proc() {
	for &entity in entities {
		entity.snapshot = entity.translation
		#partial switch entity.state {
			case .Slide:
				wall_slide_velocity := Vec2{entity.velocity.x, entity.velocity.y / 10}
				entity.translation += entity.velocity * TICK_RATE
			case:
				entity.translation += entity.velocity * TICK_RATE
		}
	}
}

apply_gravity :: proc() {
	for &entity in entities {
		switch entity.state {
			case .Airborne:
				entity.velocity.y += 100 * TICK_RATE
			case .Slide:
				entity.velocity.y += 50 * TICK_RATE
			case .Drill:
				entity.velocity.y += 150 * TICK_RATE
			case .Grounded:
				entity.velocity.y = 0
		}
	}
}

manage_entity_x_velocity :: proc() {
	for &entity in entities {
		current_state := entity.state
		max, acceleration, deceleration := entity.speed[current_state].max, entity.speed[current_state].acceleration, entity.speed[current_state].deceleration
		if entity.x_delta != 0 {
			if entity.x_delta * entity.velocity.x < max {
				entity.velocity.x += TICK_RATE * acceleration * entity.x_delta
			}
		} else {
			factor := 1 - deceleration
			entity.velocity.x = entity.velocity.x * factor
			if math.abs(entity.velocity.x) < 0.3 {
				entity.velocity.x = 0
			}
		}
		for &speed in entity.speed {
			if speed.acceleration < speed.base_acceleration {
				speed.acceleration += speed.base_acceleration * TICK_RATE
				if speed.acceleration > speed.base_acceleration {
					speed.acceleration = speed.base_acceleration
				}
			}
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

		// Find collisions
		for platform in platforms {
			half_height := Vec2{0, entity.height/2}
			nearest_platform := project_point_onto_platform(platform, entity.translation)
			nearest_entity := l.clamp(nearest_platform, entity.translation - half_height, entity.translation + half_height)

			// should_ignore := entity.velocity.y < 1 && platform.type == .OneWay
			if l.distance(nearest_entity, nearest_platform) < entity.radius  && platform.type != .OneWay {//!should_ignore{
				calculate_collision(&collisions, nearest_entity, nearest_platform, entity.radius)
			}
		}

		// Respond to collisions
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

		// Grounded and Wall Slide checks
		ground_hits: int
		right_wall_hits: int
		left_wall_hits: int
		for platform in platforms {
			//Grounded
			feet_position := entity.translation + Vec2{0, entity.height}
			nearest_feet := project_point_onto_platform(platform, feet_position)
			if l.distance(feet_position, nearest_feet) < 1 && entity.velocity.y >= 0 {
				ground_hits += 1
			}

			if platform.type != .OneWay {
				// Right Wall
				right_position := entity.translation + Vec2{entity.radius, 0}
				nearest_right := project_point_onto_platform(platform, right_position)
				if l.distance(right_position, nearest_right) < 1 && entity.velocity.y >= 0 {
					right_wall_hits += 1
				}
				
				// Left wall
				left_position := entity.translation - Vec2{entity.radius, 0}
				nearest_left := project_point_onto_platform(platform, left_position)
				if l.distance(left_position, nearest_left) < 1 && entity.velocity.y >= 0 {
					left_wall_hits += 1
				}
			}
		}

		sliding: bool

		if right_wall_hits > 0 {
			entity.sliding_wall = .Right
			sliding = true
		}

		if left_wall_hits > 0 {
			entity.sliding_wall = .Left
			sliding = true
		}

		// Handle grounded state last because it overrides wall sliding
		if ground_hits > 0 {
			entity.state = .Grounded
		} else {
			if sliding {
				entity.state = .Slide
			} else {
				if entity.state != .Drill {
					entity.state = .Airborne
				}
			}
		}
	}
}


project_point_onto_platform :: proc(platform: Platform, point: Vec2) -> Vec2 {
	min := platform.translation - (platform.size / 2)
	max := platform.translation + (platform.size / 2)
	return l.clamp(point, min, max)
}
