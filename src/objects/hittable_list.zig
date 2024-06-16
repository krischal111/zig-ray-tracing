const std = @import("std");
const imports = @import("../imports.zig");

const Hittable = imports.Hittable;
const HitRecord = imports.HitRecord;
const Interval = imports.Interval;
const Ray = imports.Ray;

pub const HittableList = struct {
    // const DefaultAllocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ArrayList = @import("std").ArrayList(Hittable);
    const test_allocator = std.heap.page_allocator;
    array: ArrayList,

    pub fn init() HittableList {
        return HittableList{ .array = ArrayList.init(test_allocator) };
    }
    pub fn deinit(self: *HittableList) void {
        self.array.deinit();
    }

    pub fn add(self: *HittableList, object: Hittable) void {
        self.array.append(object) catch undefined;
        // var append_writer = self.array.writer();
        // var writer = self.array.append(object);
        // append_writer.writeAll(&object);
        // append_writer.writeStruct(object);
        // self.array.append(object);
    }

    pub fn hit(self: HittableList, r: *const Ray, interval: Interval, rec: *HitRecord) bool {
        var temp_rec: HitRecord = .{};
        var hit_anything = false;
        var closest_so_far = interval.max;

        for (self.array.items) |it| {
            if (it.hit(r, Interval.init(interval.min, closest_so_far), &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;

                rec.* = temp_rec;
                // rec.point = temp_rec.point;
                // rec.normal = temp_rec.normal;
                // rec.t = temp_rec.t;
                // rec.front_face = temp_rec.front_face;
                // rec.material = temp_rec.material;
            }
        }

        return hit_anything;
    }
};
