const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;
const Color = Vec3;
const Ray = @import("ray.zig").Ray;
const Hittable = @import("hittable.zig").Hittable;
const HitRecord = @import("hit_record.zig").HitRecord;
const Interval = @import("interval.zig").Interval;

const INFINITY = std.math.inf(f64);

pub const Camera = struct {
    const Self = @This();
    aspect_ratio: f64 = 16.0 / 10.0,
    image_width: u32 = 600,
    image_height: u32 = 375,

    center: Vec3 = Vec3.zero(),
    pixel_00_location: Vec3,
    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3,

    pub fn render(self: Camera, world: *const Hittable, file: std.fs.File) void {
        // self.init();

        const format = @import("format.zig");
        // const stdout = std.io.getStdOut().writer();
        format.write_p7_header(file, .{
            .width = self.image_width,
            .height = self.image_height,
            .depth = 3,
        }) catch undefined;

        for (0..self.image_height) |j| {
            std.debug.print("\rScanlines remaining: {} ", .{self.image_height - j});
            for (0..self.image_width) |i| {
                const x_scale: f64 = @floatFromInt(i);
                const y_scale: f64 = @floatFromInt(j);
                const pixel_center = self.pixel_00_location.add(self.pixel_delta_u.scale(x_scale)).add(self.pixel_delta_v.scale(y_scale));
                const ray_direction = pixel_center.subtract(self.center);
                const ray = Ray{ .origin = self.center, .direction = ray_direction };

                const pixel_color = self.ray_color(&ray, world);
                pixel_color.write_color_p7(file) catch undefined;
            }
        }
    }

    pub fn init() Camera {
        const aspect_ratio = 16.0 / 10.0;
        const image_width: u32 = 600;
        const image_height: u32 = blk: {
            const imwidth: f64 = @floatFromInt(image_width);
            const ht: u32 = @intFromFloat(imwidth / aspect_ratio);
            break :blk if (ht < 1) 1 else ht;
        };
        const center = Vec3.zero();

        // Determine viewport dimensions
        const focal_length = 1.0;
        const viewport_height = 2.0;
        const viewport_width = viewport_height * aspect_ratio;

        // Calculate horizontal and vertical location for viewport
        const viewport_u = Vec3.from_xyz(viewport_width, 0.0, 0.0);
        const viewport_v = Vec3.from_xyz(0.0, -viewport_height, 0.0);

        // Calculate delta vector from pixel to pixel
        const pixel_delta_u = viewport_u.divide(image_width);
        const pixel_delta_v = viewport_v.divide(image_height);

        // Upperleft corner of viewport
        const viewport_upperleft = center.subtract(Vec3.from_xyz(0.0, 0.0, focal_length)).subtract(viewport_u.divide(2.0)).subtract(viewport_v.divide(2.0));
        const pixel_00_loc = viewport_upperleft.add(pixel_delta_u.divide(2.0)).add(pixel_delta_v.divide(2.0));

        return .{
            .aspect_ratio = aspect_ratio,
            .image_width = image_width,
            .image_height = image_height,
            .center = center,
            .pixel_00_location = pixel_00_loc,
            .pixel_delta_u = pixel_delta_u,
            .pixel_delta_v = pixel_delta_v,
        };
    }

    fn ray_color(_: Camera, ray: *const Ray, world: *const Hittable) Color {
        var hit_rec: HitRecord = undefined;
        if (world.hit(ray, Interval.init(0, INFINITY), &hit_rec)) {
            return hit_rec.normal.add(Vec3.from_xyz(1.0, 1.0, 1.0)).scale(0.5);
        } else {
            const background_color = @import("ray.zig").sky_ray_color;
            return background_color(ray);
        }

        const unit_direction = ray.direction.unit_vector();
        const a = 0.5 * (unit_direction.y() + 1.0);
        return Vec3.from_xyz(1.0, 1.0, 1.0).scale(1.0 - a).add(Vec3.from_xyz(0.5, 0.7, 1.0).scale(a));
    }
};
