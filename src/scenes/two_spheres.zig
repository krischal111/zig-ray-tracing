const std = @import("std");
const imports = @import("../imports.zig");
const Vec3 = imports.Vec3;
const Point3 = Vec3;

// world
const Sphere = imports.Sphere;
const Hittable = imports.Hittable;
const HittableList = imports.HittableList;

pub fn get_scene() Hittable {
    // Todo: add allocator interface
    // Also to add an errdefer if the allocation fails

    var world = Hittable{ .list = HittableList.init() };

    // An sphere of radius 0.5 that is 2 units away from the camera
    // along the negative z-direction.
    world.list.add(.{ .sphere = Sphere.new(Point3.from_xyz(0, 0, -2), 0.5) });
    // An sphere of radius 100 that is 300 units away from the camera
    // along negative z-direction.
    // And a little bit up along the y-direction
    world.list.add(.{ .sphere = Sphere.new(Point3.from_xyz(0, 100.5, -301), 100) });

    return world;
}
