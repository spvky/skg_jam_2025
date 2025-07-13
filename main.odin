package main

import "core:fmt"
import rl "vendor:raylib"
import sa "core:container/small_array"

Vec2 :: [2]f32

SCREEN_WIDTH :: 1600
SCREEN_HEIGHT :: 900

TICK_RATE :: 1.0/200.0


Time :: struct {
	t0: f32,
	t1: f32,
	simulation_time: f32,
	started: bool
}

update :: proc(using time: ^Time) {
	if !started {
		t0 = f32(rl.GetTime())
		started = true
	}

	// Get Input

	t1 = f32(rl.GetTime())
	elapsed := t1 - t0
	if elapsed > 0.25 {
		elapsed = 0.25
	}
	t0 = t1
	simulation_time += elapsed
	for simulation_time >= TICK_RATE {
		// Physics stuff
		simulation_time -= TICK_RATE
	}
}

main :: proc() {
	game_time: f32
	physics_time: f32

	time: Time

	platforms := [?]Platform {
		make_platform({-25,25}, 50, 10)
	}

	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Moonflower")
	defer rl.CloseWindow()
	camera := rl.Camera2D {zoom = 10, offset = Vec2{SCREEN_WIDTH/2,SCREEN_HEIGHT/2}}
	player := Player {radius=10, height=8}

	for !rl.WindowShouldClose() {

		// Physics
		frametime := rl.GetFrameTime()
		t0 := rl.GetTime()

		t1 := rl.GetTime()
		physics_step(platforms[:], &player, frametime)


		rl.BeginDrawing()
		rl.ClearBackground({12,37,31,255})
		camera.target = 0
		render(camera, platforms[:], player)
		rl.EndDrawing()
	}
}
