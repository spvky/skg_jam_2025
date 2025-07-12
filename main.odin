package main

import "core:fmt"
import rl "vendor:raylib"
import sa "core:container/small_array"

Vec2 :: [2]f32

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
		draw_player(player)
		rl.EndMode2D()
		rl.EndDrawing()
	}
}
