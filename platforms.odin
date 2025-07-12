package main

import rl "vendor:raylib"
import sa "core:container/small_array"

Platform_Type :: enum {
	Normal,
	OneWay
}

Platform :: struct {
	translation: Vec2,
	size: Vec2,
	type: Platform_Type
}

make_platform :: proc(translation: Vec2, width: f32, height: f32, type: Platform_Type =  .Normal) -> Platform {
	return Platform {
		translation = translation,
		size = {width, height},
		type = type
	}
}

draw_platforms :: proc(platforms: []Platform) {
	for platform in platforms {
		rl.DrawRectangleV(platform.translation, platform.size, rl.WHITE)
	}
}

Platform_Iter :: struct {
	platforms: sa.Small_Array(20, Platform),
	index: int
}

platform_make_iter :: proc(platforms: []Platform, type: Platform_Type) -> Platform_Iter {
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
