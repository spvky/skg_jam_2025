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
	player_jump()
	apply_gravity()
	manage_player_x_velocity()
	simulate_dynamics()
}

simulate_dynamics :: proc() {
		player.snapshot = player.translation
		#partial switch player.state {
			case .Slide:
				wall_slide_velocity := Vec2{player.velocity.x, player.velocity.y / 10}
				player.translation += player.velocity * TICK_RATE
			case:
				player.translation += player.velocity * TICK_RATE
		}
}

apply_gravity :: proc() {
		switch player.state {
			case .Airborne:
				player.velocity.y += 100 * TICK_RATE
			case .Slide:
				player.velocity.y += 50 * TICK_RATE
			case .Drill:
				player.velocity.y += 150 * TICK_RATE
			case .Grounded:
				player.velocity.y = 0
		}
}

manage_player_x_velocity :: proc() {
		current_state := player.state
		max, acceleration, deceleration := player.speed[current_state].max, player.speed[current_state].acceleration, player.speed[current_state].deceleration
		if player.x_delta != 0 {
			if player.x_delta * player.velocity.x < max {
				player.velocity.x += TICK_RATE * acceleration * player.x_delta
			}
		} else {
			factor := 1 - deceleration
			player.velocity.x = player.velocity.x * factor
			if math.abs(player.velocity.x) < 0.3 {
				player.velocity.x = 0
			}
		}
		for &speed in player.speed {
			if speed.acceleration < speed.base_acceleration {
				speed.acceleration += speed.base_acceleration * TICK_RATE
				if speed.acceleration > speed.base_acceleration {
					speed.acceleration = speed.base_acceleration
				}
			}
		}
}

player_platform_collision :: proc() {

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

		collisions := make([dynamic]Collision_Data, 0, 8, allocator = context.temp_allocator)

		// Find collisions
		for platform in platforms {
			half_height := Vec2{0, player.height/2}
			nearest_platform := project_point_onto_platform(platform, player.translation)
			nearest_player := l.clamp(nearest_platform, player.translation - half_height, player.translation + half_height)

			if l.distance(nearest_player, nearest_platform) < player.radius  && platform.type != .OneWay {//!should_ignore{
				if platform.type != .Water {
					calculate_collision(&collisions, nearest_player, nearest_platform, player.radius, platform.type)
				} else {
					volume_top := platform.translation.y - (platform.size.y / 2)
					// Calculate difference between player y position and the top of the watre volume
					diff := volume_top - player.translation.y
					submersion_depth := diff / platform.size.y
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
			feet_position := player.translation + Vec2{0, player.height - 2.5}
			nearest_feet := project_point_onto_platform(platform, feet_position)
			switch platform.type {
				case .Normal, .OneWay:
					if l.distance(feet_position, nearest_feet) < 3 && player.velocity.y >= 0 {
						player.last_grounded_pos = player.translation
						ground_hits += 1

					}
				case .Spike:
					if l.distance(feet_position, nearest_feet) < 4 && player.state == .Drill && player.tag == .Player{
						player.last_grounded_pos = player.translation
						if rl.IsKeyDown(.J) {
							player.velocity.y = -80
						} else {
							player.velocity.y = -35
						}
					}
				case .Water:
			}

			if platform.type == .Normal {
				// Right Wall
				right_position := player.translation + Vec2{player.radius, 0}
				nearest_right := project_point_onto_platform(platform, right_position)
				if l.distance(right_position, nearest_right) < 2 && player.velocity.y >= 0 {
					right_wall_hits += 1
				}
				
				// Left wall
				left_position := player.translation - Vec2{player.radius, 0}
				nearest_left := project_point_onto_platform(platform, left_position)
				if l.distance(left_position, nearest_left) < 2 && player.velocity.y >= 0 {
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
		if ground_hits > 0 {
			player.state = .Grounded
		} else {
			if sliding {
				player.state = .Slide
			} else {
				if player.state != .Drill {
					player.state = .Airborne
				}
			}
		}
}


project_point_onto_platform :: proc(platform: Platform, point: Vec2) -> Vec2 {
	min := platform.translation - (platform.size / 2)
	max := platform.translation + (platform.size / 2)
	return l.clamp(point, min, max)
}
