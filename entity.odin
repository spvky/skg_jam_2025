package main

Entity :: struct {
	tag: EntityTag,
	translation: Vec2,
	snapshot: Vec2,
	height: f32,
	radius: f32,
	velocity: Vec2,
	state: Entity_State,
	sliding_wall: Sliding_Wall,
	holding_down: bool,
}

EntityTag :: enum {
	Player,
	Enemy
}

Entity_State :: enum {
	Grounded,
	Airborne,
	Drill,
	Slide
}

Sliding_Wall :: enum {
	Right,
	Left
}
