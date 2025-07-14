package main

import "core:c"
import rl "vendor:raylib"
import l "core:math/linalg"

draw_platforms :: proc() {
	for platform in platforms {
		rec := rl.Rectangle{x = platform.translation.x, y = platform.translation.y, width = platform.size.x, height = platform.size.y}
		rl.DrawRectanglePro(rec, platform.size / 2, 0, rl.WHITE)
	}
}

draw_entities :: proc(alpha: f32) {
	for entity in entities {
		position := l.lerp(entity.snapshot, entity.translation, alpha)
		color := rl.RED
		if entity.tag == .Player {
			#partial switch entity.state {
			case .Slide:
				color = rl.GREEN
			case .Airborne:
				color = rl.BLUE
			case .Drill:
				color = rl.PINK
			case:
				color = rl.WHITE
			}
			size := Vec2 {entity.radius * 2, entity.height}
			rl.DrawCircleV(position + {0, entity.height / 2}, entity.radius, color)
			rl.DrawCircleV(position - {0, entity.height / 2}, entity.radius, color)
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
	print_player_velocity()
	rl.EndDrawing()
}
