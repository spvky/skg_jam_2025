package main

import "core:c"
import rl "vendor:raylib"
import l "core:math/linalg"

render_platforms :: proc() {
	for platform in platforms {
		color: rl.Color
		#partial switch platform.type {
			case .Normal, .OneWay:
				color = rl.WHITE
				position := [3]f32{platform.translation.x, platform.translation.y, 5}
				size := [3]f32{platform.size.x, platform.size.y, 5}
				rl.DrawCubeV(position, size, color)
			case .Spike:
				color = rl.RED
				position := [3]f32{platform.translation.x, platform.translation.y, 5}
				size := [3]f32{platform.size.x, platform.size.y, 5}
				rl.DrawCubeV(position, size, color)
			case .Water:
				color = {0,45,255,100}
				position := [3]f32{platform.translation.x, platform.translation.y, 5}
				size := [3]f32{platform.size.x, platform.size.y, 5}
				rl.DrawCubeWiresV(position, size, color)
		}
	}
}

render_entites :: proc (alpha: f32) {
	raw_position := l.lerp(player.snapshot, player.translation, alpha)
	position := Vec3{raw_position.x, raw_position.y, 0}
	color := rl.RED
	if player.tag == .Player {
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
		rl.DrawSphere(position, player.radius, color)
	}
}

update_camera_offset :: proc(alpha: f32) {
	frametime := rl.GetFrameTime()
	camera_control.target_offset.y += 10 * frametime
	camera.offset.y = l.lerp(camera.offset.y, camera_control.target_offset.y, frametime * 10)
}

render_3d :: proc(alpha: f32) {
	rl.BeginTextureMode(offscreen)
	rl.ClearBackground({12,37,31,255})
	rl.BeginMode3D(camera_3d)
	render_platforms()
	render_entites(alpha)
	rl.EndMode3D()
	rl.EndTextureMode()
}

render :: proc(alpha: f32) {
	rl.BeginTextureMode(offscreen)
	rl.BeginMode2D(camera)
	rl.ClearBackground({12,37,31,255})
	update_camera_offset(alpha)
	draw_platforms()
	draw_entities(alpha)
	rl.EndMode2D()
	rl.EndTextureMode()
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	render_source := rl.Rectangle{0,0, SCREEN_WIDTH, SCREEN_HEIGHT}
	render_origin := Vec2{0,0}
	rect := rl.Rectangle{0,0, WINDOW_WIDTH, WINDOW_HEIGHT}
	rl.DrawTexturePro(offscreen.texture, render_source, rect, render_origin, 0, rl.WHITE)
	print_player_velocity()
	rl.EndDrawing()
}
