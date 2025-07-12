package main

import "core:math"
import sa "core:container/small_array"
import l "core:math/linalg"

CollisionData :: struct {
	collision_normal: Vec2,
	collision_point: Vec2,
	penetration_depth: f32
}


dynamic_platform_collision :: proc(translation: Vec2, radius: f32, platforms: []Platform) -> [dynamic]CollisionData {
	collisions: [dynamic]CollisionData

	for platform in platforms {
		nearest := project_point_onto_platform(platform, translation)
		if l.distance(nearest,translation) < radius {
				collision_vector := translation - nearest
				penetration_depth := radius - l.length(collision_vector)
			append(&collisions, CollisionData {
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
