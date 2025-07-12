package main

import rl "vendor:raylib"

draw_platforms :: proc(platforms: []Platform) {
	for platform in platforms {
		rl.DrawRectangleV(platform.translation, platform.size, rl.WHITE)
	}
}

draw_player :: proc(player: Player) {
	rl.DrawCircleV(player.translation, player.radius, rl.WHITE)
}
