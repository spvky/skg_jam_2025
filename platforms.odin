package main

import rl "vendor:raylib"
import sa "core:container/small_array"

Platform_Type :: enum {
	Normal,
	OneWay,
	Spike,
	Water
}

Moving_Platform :: struct {
	
}

Platform :: struct {
	translation: Vec2,
	size: Vec2,
	type: Platform_Type
}

// Make a platform
make_platform :: proc(translation: Vec2, width: f32, height: f32, type: Platform_Type =  .Normal) -> Platform {
	return Platform {
		translation = translation,
		size = {width, height},
		type = type
	}
}


Platform_Iter :: struct {
	platforms: sa.Small_Array(20, Platform),
	index: int
}

platforms_filter :: proc(platforms: []Platform, type: Platform_Type = .Normal) -> [dynamic]Platform {
	filtered := make([dynamic]Platform, 0, 8)
	for p in platforms {
		if p.type == type {
			append(&filtered, p)
		}
	}
	return filtered
}

// Create an iter of platforms of the given type, defaults to normal
platform_make_iter :: proc(platforms: []Platform, type: Platform_Type = .Normal) -> Platform_Iter {
	inner_platforms: sa.Small_Array(20, Platform)

	for p in platforms {
		if p.type == type {
			sa.append(&inner_platforms, p)
		}
	}
	return Platform_Iter {platforms = inner_platforms}
}

iter_platforms :: proc(iter: ^Platform_Iter) -> (val: Platform, cond: bool) {
	length := sa.len(iter.platforms)
	in_range := iter.index < length

	for in_range {
		val, cond = sa.get_safe(iter.platforms, iter.index)
		iter.index += 1
		return
	}
	return
}
