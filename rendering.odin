package main

import "core:c"
import "core:math"
import "core:fmt"
import rl "vendor:raylib"
import l "core:math/linalg"

render_platforms :: proc() {
	for platform in platforms {
		color: rl.Color
		#partial switch platform.type {
			case .Normal, .OneWay:
				// color = rl.WHITE
				// position := [3]f32{platform.translation.x, platform.translation.y, 5}
				// size := [3]f32{platform.size.x, platform.size.y, 5}
				// rl.DrawCubeV(position, size, color)
			case .Spike:
				color = rl.RED
				position := [3]f32{platform.translation.x, platform.translation.y, 5}
				size := [3]f32{platform.size.x, platform.size.y, 5}
				rl.DrawCubeV(position, size, color)
		}
	}
}

render_water :: proc() {
	for platform in platforms {
		if platform.type == .Water {
			position := [3]f32{platform.translation.x, platform.translation.y, 5}
			size := [3]f32{platform.size.x, platform.size.y, 3}
			rl.DrawCubeV(position, size, {0,12,128,100})
		}
	}
}

render_player :: proc (alpha: f32) {
	raw_position := l.lerp(player.snapshot, player.translation, alpha)
	position := Vec3{raw_position.x, raw_position.y, 0}
	color := rl.WHITE
		if ODIN_DEBUG {
		#partial switch player.state {
		case .Slide:
			color = rl.GREEN
		case .Airborne:
			color = rl.BLUE
		case .Drill:
			color = rl.PINK
		case:
			color = rl.WHITE
		}
	}
	normalized_velo := l.normalize0(Vec2{player.velocity.x, player.velocity.y})
	rl.DrawModelEx(fish_model,position,{0,0,1}, player.displayed_rotation, 1, color)
}

update_camera_offset :: proc(alpha: f32) {
	frametime := rl.GetFrameTime()
	camera_control.target_offset.y += 10 * frametime
	camera.offset.y = l.lerp(camera.offset.y, camera_control.target_offset.y, frametime * 10)
}

render :: proc(alpha: f32) {
	rl.BeginTextureMode(offscreen)
	rl.ClearBackground({12,37,31,255})
	rl.BeginMode3D(camera_3d)
	render_water()
	render_platforms()
	render_player(alpha)
	rl.EndMode3D()
	rl.EndTextureMode()
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	render_source := rl.Rectangle{0,0, SCREEN_WIDTH, SCREEN_HEIGHT}
	render_origin := Vec2{0,0}
	rect := rl.Rectangle{0,0, WINDOW_WIDTH, WINDOW_HEIGHT}
	rl.DrawTexturePro(offscreen.texture, render_source, rect, render_origin, 0, rl.WHITE)
	if ODIN_DEBUG {
		print_player_velocity()
	}
	rl.EndDrawing()
}
