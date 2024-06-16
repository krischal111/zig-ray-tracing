const std = @import("std");
const imports = @import("../imports.zig");

const Ray = imports.Ray;
const Color = imports.Color;
const HitRecord = imports.HitRecord;
const Interval = imports.Interval;
const INFINITY = imports.INFINITY;

const Sky = @This();

pub fn hit(_: Sky, ray: *const Ray, interval: Interval, rec: *HitRecord) bool {
    const unit_direction = ray.direction.unit_vector();
    const a = 0.5 * (unit_direction.position.y + 1.0); // between 0 to 1 for lerp
    const color = Color.from_rgb(1, 1, 1).scale(1 - a).add(Color.from_rgb(0.5, 0.7, 1).scale(a));

    rec.t = INFINITY;
    rec.front_face = true;
    rec.normal = null;
    rec.point = null;
}

pub fn sky_ray_color(r: *const Ray) Color {
    const unit_direction = r.direction.unit_vector();
    const a = 0.5 * (unit_direction.v.y + 1.0);
    return Color.from_rgb(1.0, 1.0, 1.0).scale(1.0 - a).add(Color.from_rgb(0.5, 0.7, 1.0).scale(a));
}
