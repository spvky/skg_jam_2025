package main

import rl "vendor:raylib"

draw_platforms :: proc(platforms: []Platform) {
	for platform in platforms {
		rl.DrawRectangleV(platform.translation, platform.size, rl.WHITE)
	}
}

draw_player :: proc(player: Player) {
	color := player.grounded ? rl.WHITE : rl.RED
	rl.DrawCircleV(player.translation, player.radius, color)
}

render :: proc(camera: rl.Camera2D, platforms: []Platform, player: Player) {
	rl.BeginMode2D(camera)
	draw_platforms(platforms[:])
	draw_player(player)
	rl.EndMode2D()
}
