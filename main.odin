package main

import "core:fmt"
import "core:c"
import rl "vendor:raylib"
import sa "core:container/small_array"

Vec2 :: [2]f32

WINDOW_WIDTH : f32 = 1600.0
WINDOW_HEIGHT : f32 = 900.0

SCREEN_WIDTH :: 400
SCREEN_HEIGHT :: 225

TICK_RATE :: 1.0/200.0


Time :: struct {
	t: f32,
	simulation_time: f32,
	started: bool
}



// Global values
offscreen: rl.RenderTexture2D
time: Time
platforms := [?]Platform {
	make_platform({0,50}, 500, 10),
	make_platform({0,30}, 5, 5, .Spike),
	make_platform({50,0}, 10, 100),
	make_platform({-50,0}, 10, 100),
}
camera := rl.Camera2D {zoom = 1, offset = Vec2 {SCREEN_WIDTH/2,SCREEN_HEIGHT/2}}
input_buffer: Input_Buffer
entities: [dynamic]Entity



main :: proc() {
	// Add player to the entites array
	append(&entities, make_player())
	rl.InitWindow(c.int(WINDOW_WIDTH), c.int(WINDOW_HEIGHT), "Moonflower")
	defer rl.CloseWindow()

	offscreen = rl.LoadRenderTexture(c.int(SCREEN_WIDTH), c.int(SCREEN_HEIGHT))

	for !rl.WindowShouldClose() {
		alpha := update()
		render(alpha)
		draw()
		free_all(context.temp_allocator)
	}
	delete(entities)
}



update :: proc() -> f32 {
	if !time.started {
		time.t = f32(rl.GetTime())
		time.started = true
	}
	// Get Input
	input()

	t1 := f32(rl.GetTime())
	elapsed := t1 - time.t
	if elapsed > 0.25 {
		elapsed = 0.25
	}
	time.t = t1
	time.simulation_time += elapsed
	for time.simulation_time >= TICK_RATE {
		// Physics stuff
		physics_step()
		time.simulation_time -= TICK_RATE
	}
	return time.simulation_time / TICK_RATE
}
