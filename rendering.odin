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

resize_window :: proc(width, height: c.int) {
	rl.SetWindowSize(width,height)
	WINDOW_WIDTH = f32(width)
	WINDOW_HEIGHT = f32(height)

	letterbox.width = SCREEN_WIDTH
	letterbox.height = SCREEN_HEIGHT

	ratio_x := WINDOW_WIDTH / f32(SCREEN_WIDTH)
	ratio_y := WINDOW_HEIGHT / f32(SCREEN_HEIGHT)
	ratio := min(ratio_x, ratio_y)
	offset_x := (WINDOW_WIDTH - ratio * SCREEN_WIDTH) * 0.5
	offset_y := (WINDOW_HEIGHT - ratio * SCREEN_HEIGHT) * 0.5

	letterbox = rl.Rectangle{x = offset_x, y = offset_y, width = ratio * SCREEN_WIDTH, height = ratio * SCREEN_HEIGHT}
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
	rl.DrawTexturePro(offscreen.texture, render_source, letterbox, render_origin, 0, rl.WHITE)
	rl.EndDrawing()
}
