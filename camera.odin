package main

import l "core:math/linalg"
import rl "vendor:raylib"

camera_control := CameraControl {target_offset = Vec2 {SCREEN_WIDTH/2,SCREEN_HEIGHT/2}}
camera := rl.Camera2D {zoom = 1, offset = Vec2 {SCREEN_WIDTH/2,SCREEN_HEIGHT/2}}
camera_3d := rl.Camera3D { position = {0,25,200}, up = {0,1,0}, projection = .PERSPECTIVE, fovy = 45, target ={0,25,0}}


follow_player :: proc() {
	frametime := rl.GetFrameTime()
	player_pos := Vec3 {0,player.last_grounded_pos.y - 30, 0}
	camera_3d.target = Vec3{camera_3d.position.x, camera_3d.position.y, camera_3d.position.z - 200}
	target_camera_pos := Vec3{player_pos.x, player_pos.y, camera_3d.position.z}
	camera_3d.position = l.lerp(camera_3d.position, target_camera_pos, frametime * 3)
}
