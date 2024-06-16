const std = @import("std");
const imports = @import("../imports.zig");

const HitRecord = imports.HitRecord;

const Sphere = imports.Sphere;
const Ray = imports.Ray;
const Interval = imports.Interval;
const HittableList = imports.HittableList;

pub const Hittable = union(enum) {
    sphere: Sphere,
    list: HittableList,
    // HittableList: @import("hittable_list.zig").HittableList,
    nothing: struct {
        pub fn hit(_: @This(), _: *const Ray, _: Interval, _: *HitRecord) bool {
            return false;
        }
    },

    pub fn hit(self: Hittable, r: *const Ray, interval: Interval, rec: *HitRecord) bool {
        switch (self) {
            inline else => |object| return object.hit(r, interval, rec),
        }
    }
};
