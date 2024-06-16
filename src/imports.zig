// Basics
pub const Vec3 = @import("geometry/vec3.zig").Vec3;
pub const Color = Vec3;
pub const Point3 = Vec3;

// Objects
pub const Sphere = @import("objects/sphere.zig").Sphere;
pub const Hittable = @import("objects/hittable.zig").Hittable;
pub const HittableList = @import("objects/hittable_list.zig").HittableList;
pub const HitRecord = @import("render/hit_record.zig").HitRecord;

// Ray
pub const ray = @import("render/ray.zig");
pub const Ray = @import("render/ray.zig").Ray;

// Camera
pub const Camera = @import("render/camera2.zig").Camera;

// Utils
pub const Interval = @import("utils/interval.zig").Interval;

// Render
pub const writers = @import("format/writers.zig");

// Materials
// const Lambertian = @import("materials/lambertian.zig").Lambertian;

// Math
const std = @import("std");
pub const INFINITY = std.math.inf(f64);
