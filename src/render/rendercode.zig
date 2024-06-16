const std = @import("std");
const imports = @import("../imports.zig");
const Vec3 = imports.Vec3;
const Point3 = Vec3;

// world
const Sphere = imports.Sphere;
const Hittable = imports.Hittable;
const HittableList = imports.HittableList;

// camera
const Camera = imports.Camera;

// formatting
const writers = imports.writers;

pub fn rendercode() !void {
    // Image
    const aspect_ratio: f64 = 16.0 / 10.0;
    const image_height: u32 = 40;

    // calculate image height, ensuring value of at least 1
    const image_width: u32 = blk: {
        const width: u32 = @intFromFloat(image_height * aspect_ratio);
        break :blk if (width < 1) 1 else width;
    };
    // _ = image_height;

    // camera
    var camera = Camera.init(.{
        .aspect_ratio = aspect_ratio,
        .viewport_height = 2.0,
        .image_width = image_width,
        .image_height = image_height,
        .focal_length = 1.0,
    });
    camera.display_camera_info();

    var world = @import("../scenes/two_spheres.zig").get_scene();
    defer world.list.deinit();

    world.list.add(.{ .sphere = Sphere.new(Point3.from_xyz(0, 0, -2), 0.5) });
    world.list.add(.{ .sphere = Sphere.new(Point3.from_xyz(0, 100.5, -301), 100) });

    const stdout = std.io.getStdOut();
    camera.render_p7(&world, stdout);
}
