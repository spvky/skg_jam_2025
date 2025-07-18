package main

import "core:fmt"
import "core:math"
import sa "core:container/small_array"
import l "core:math/linalg"
import rl "vendor:raylib"

Collision_Data :: struct {
	normal: Vec2,
	mtv: Vec2,
	type: Platform_Type
}

Dynamic_Body :: struct {
	translation: ^Vec2,
	velocity: ^Vec2,
	grounded: bool
}

physics_step :: proc() {
	player_platform_collision()
	player_spin()
	apply_gravity()
	manage_player_velocity()
	simulate_dynamics()
}

simulate_dynamics :: proc() {
		player.snapshot = player.translation
		#partial switch player.state {
			case .Slide:
				wall_slide_velocity := Vec2{player.velocity.x, player.velocity.y / 10}
				// player.translation += player.velocity * TICK_RATE
				player.translation += wall_slide_velocity * TICK_RATE
			case:
				player.translation += player.velocity * TICK_RATE
		}
		normalized_velo := l.normalize0(Vec2{player.velocity.x, player.velocity.y})
		if normalized_velo != {0,0} {
			player.rotation = math.to_degrees(math.atan2_f32(normalized_velo.x, -normalized_velo.y))
		}
		player.displayed_rotation = l.lerp(player.displayed_rotation, player.rotation, 10 * TICK_RATE)
}

apply_gravity :: proc() {
		switch player.state {
			case .Airborne:
				player.velocity.y += 100 * TICK_RATE
			case .Slide:
				player.velocity.y += 50 * TICK_RATE
			case .Drill:
				player.velocity.y += 150 * TICK_RATE
			case .Submerged:
		}
}

manage_player_velocity :: proc() {
		current_state := player.state
		max, acceleration, deceleration := player.speed[current_state].max, player.speed[current_state].acceleration, player.speed[current_state].deceleration

	switch player.state {
		case .Airborne, .Drill, .Slide:
			if player.movement_delta.x != 0 {
				if player.movement_delta.x * player.velocity.x < max {
					player.velocity.x += TICK_RATE * acceleration * player.movement_delta.x
				}
			} else {
				factor := 1 - deceleration
				player.velocity.x = player.velocity.x * factor
				if math.abs(player.velocity.x) < 0.3 {
					player.velocity.x = 0
				}
			}
		case .Submerged:
			if player.movement_delta != {0,0} {
			speed_in_direction := l.dot(player.velocity, l.normalize(player.movement_delta))
				if speed_in_direction < max {
					player.velocity += l.normalize(player.movement_delta) * TICK_RATE * acceleration
				} else {
					factor := 1 - (deceleration/4)
					player.velocity = player.velocity * factor
				}
			} else {
				factor := 1 - deceleration
				player.velocity = player.velocity * factor
				if l.length(player.velocity) < 0.3 {
					player.velocity = {0,0}
				}
			}
	}
}

player_platform_collision :: proc() {
	// Helper proc to calculate collision
	calculate_collision :: proc(collisions: ^[dynamic]Collision_Data, nearest_player: Vec2, nearest_collider: Vec2, radius: f32, type: Platform_Type) {
		collision: Collision_Data
		collision_vector := nearest_player - nearest_collider
		pen_depth := radius - l.length(collision_vector)
		collision_normal := l.normalize(collision_vector)
		mtv := collision_normal * pen_depth
		collision.normal = collision_normal
		collision.mtv = mtv
		collision.type = type
		append(collisions, collision)
	}

	player.last_grounded_pos = player.translation
	collisions := make([dynamic]Collision_Data, 0, 8, allocator = context.temp_allocator)

	in_water := false
	// Find collisions
	for platform in platforms {
		nearest_platform := project_point_onto_platform(platform, player.translation)

		if l.distance(player.translation, nearest_platform) < player.radius {
			if platform.type != .Water {
				calculate_collision(&collisions, player.translation, nearest_platform, player.radius, platform.type)
			} else {
				in_water = true
			}
		}
	}

	// Respond to collisions
	for collision in collisions {
		#partial switch collision.type {
		case .Normal:
			player.translation += collision.mtv
			x_dot := math.abs(l.dot(collision.normal, Vec2{1,0}))
			y_dot := math.abs(l.dot(collision.normal, Vec2{0,1}))
			if  x_dot > 0.7 {
				player.velocity.x = 0
			}
			if y_dot > 0.7 {
				player.velocity.y = 0
			}
		}
	}

	// Grounded and Wall Slide checks
	ground_hits: int
	right_wall_hits: int
	left_wall_hits: int
	for platform in platforms {
		//Grounded
		feet_position := player.translation + Vec2{0, player.radius}
		nearest_feet := project_point_onto_platform(platform, feet_position)
		if platform.type == .Spike {
			if l.distance(feet_position, nearest_feet) < 4 && player.state == .Drill {
				if rl.IsKeyDown(.J) {
					player.velocity.y = -80
				} else {
					player.velocity.y = -35
				}
			}
		}

		if platform.type == .Normal {
			// Right Wall
			right_position := player.translation + Vec2{player.radius, 0}
			nearest_right := project_point_onto_platform(platform, right_position)
			if l.distance(right_position, nearest_right) < 2 {
				right_wall_hits += 1
			}
			
			// Left wall
			left_position := player.translation - Vec2{player.radius, 0}
			nearest_left := project_point_onto_platform(platform, left_position)
			if l.distance(left_position, nearest_left) < 2 {
				left_wall_hits += 1
			}
		}
	}

	sliding: bool

	if right_wall_hits > 0 {
		player.sliding_wall = .Right
		sliding = true
	}
	if left_wall_hits > 0 {
		player.sliding_wall = .Left
		sliding = true
	}
	// Handle grounded state last because it overrides wall sliding
	if !in_water {
		if sliding {
			player.state = .Slide
		} else {
			if player.state != .Drill {
				player.state = .Airborne
			}
		}
	}
	if in_water do player.state = .Submerged
}

project_point_onto_platform :: proc(platform: Platform, point: Vec2) -> Vec2 {
	min := platform.translation - (platform.size / 2)
	max := platform.translation + (platform.size / 2)
	return l.clamp(point, min, max)
}
