package main

Entity :: struct {
	tag: EntityTag,
	translation: Vec2,
	snapshot: Vec2,
	height: f32,
	radius: f32,
	velocity: Vec2,
	grounded: bool,
	holding_down: bool,
}

EntityTag :: enum {
	Player,
	Enemy
}
