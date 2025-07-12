package main

import rl "vendor:raylib"

Vec2 :: [2]f32

Player :: struct {
	translation: Vec2,
	radius: f32
}

SCREEN_WIDTH :: 1600
SCREEN_HEIGHT :: 900


main :: proc() {
	platforms := [?]Platform {
		make_platform({-25,25}, 50, 10)
	}

	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Moonflower")
	defer rl.CloseWindow()
	camera := rl.Camera2D {zoom = 10, offset = Vec2{SCREEN_WIDTH/2,SCREEN_HEIGHT/2}}
	player := Player {radius=10}

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({12,37,31,255})
		camera.target = 0
		rl.BeginMode2D(camera)
		draw_platforms(platforms[:])
		rl.DrawCircleV(player.translation, player.radius, rl.WHITE)
		rl.EndMode2D()
		rl.EndDrawing()
	}
}
