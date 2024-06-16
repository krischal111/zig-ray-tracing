const std = @import("std");
const imports = @import("../imports.zig");

const Vec3 = imports.Vec3;
const Point3 = Vec3;
const Ray = imports.Ray;

const INFINITY = imports.INFINITY;

pub const HitRecord = struct {
    t: f64 = INFINITY,
    point: ?Point3 = undefined,
    normal: ?Vec3 = undefined,
    front_face: bool = undefined,

    pub inline fn set_face_normal(self: *HitRecord, r: *const Ray, outward_normal: Vec3) void {
        self.front_face = r.direction.dot(outward_normal) < 0.0;
        self.normal = if (self.front_face) outward_normal else outward_normal.scale(-1.0);
    }
};
