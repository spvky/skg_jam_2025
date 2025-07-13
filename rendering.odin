package main

import "core:c"
import rl "vendor:raylib"
import l "core:math/linalg"

draw_platforms :: proc() {
	for platform in platforms {
		rl.DrawRectangleV(platform.translation, platform.size, rl.WHITE)
	}
}

draw_entities :: proc(alpha: f32) {
	for entity in entities {
		position := l.lerp(entity.snapshot, entity.translation, alpha)
		color := rl.RED
		if entity.tag == .Player {
			color = entity.grounded ? rl.WHITE : rl.BLUE
			rl.DrawCircleV(position, entity.radius, color)
		}
	}
}


render :: proc(alpha: f32) {
	rl.BeginTextureMode(offscreen)
	rl.BeginMode2D(camera)
	rl.ClearBackground({12,37,31,255})
	draw_platforms()
	draw_entities(alpha)
	rl.EndMode2D()
	rl.EndTextureMode()
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	render_source := rl.Rectangle{0,0, SCREEN_WIDTH, -SCREEN_HEIGHT}
	render_origin := Vec2{0,0}
	rect := rl.Rectangle{0,0, WINDOW_WIDTH, WINDOW_HEIGHT}
	rl.DrawTexturePro(offscreen.texture, render_source, rect, render_origin, 0, rl.WHITE)
	rl.EndDrawing()
}
