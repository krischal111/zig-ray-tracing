const std = @import("std");
const imports = @import("../imports.zig");

const Vec3 = imports.Vec3;
const Point3 = Vec3;
const Color = Vec3;
const Ray = imports.Ray;
const Hittable = imports.Hittable;
const HitRecord = imports.HitRecord;
const Interval = imports.Interval;

pub const INFINITY = std.math.inf(f64);

const _CameraParameters = struct {
    aspect_ratio: f64,
    image_height: u32,
    image_width: ?u32 = null,
    viewport_height: f64 = 2.0,
    viewport_width: ?f64 = null,
    focal_length: f64 = 1.0,
    camera_center: Point3 = Point3.zero(),
    camera_direction: Vec3 = Vec3.from_xyz(0.0, 0.0, -1.0),
    camera_orientation: Vec3 = Vec3.from_xyz(0.0, 1.0, 0.0),
};

pub const Camera = struct {
    const Self = @This();

    // Other parameters for debug
    aspect_ratio: f64 = 16.0 / 10.0,
    focal_length: f64 = 1.0,
    viewport_height: f64 = 2.0,
    viewport_width: f64 = 3.2,
    viewing_direction: Vec3,
    camera_orientation: Vec3,

    // dertermines the size of the image
    image_width: u32 = 600,
    image_height: u32 = 375,

    // determines the camera and ray tracing parameters
    center: Vec3 = Vec3.zero(),
    pixel_00_location: Vec3,
    pixel_delta_height: Vec3,
    pixel_delta_width: Vec3,

    pub fn init(camera_param: _CameraParameters) Self {
        // Determine image dimensions
        const aspect_ratio = camera_param.aspect_ratio;
        const image_height = camera_param.image_height;
        const image_width = if (camera_param.image_width) |width| width else blk: {
            const imheight: f64 = @floatFromInt(image_height);
            const width: u32 = @intFromFloat(imheight * aspect_ratio);
            break :blk if (width < 1) 1 else width;
        };
        const approx_aratio = blk: {
            const imheight: f64 = @floatFromInt(image_height);
            const imwidth: f64 = @floatFromInt(image_width);
            const aratio: f64 = imwidth / imheight;
            break :blk aratio;
        };

        // Determine viewport dimensions (in f64)
        const center = camera_param.camera_center;
        const focal_length = camera_param.focal_length;
        const viewport_height = camera_param.viewport_height;
        const viewport_width = if (camera_param.viewport_width) |vpw| vpw else blk: {
            break :blk viewport_height * approx_aratio;
        };

        // Calculate horizontal and vertical component
        const viewport_width_vec = camera_param.camera_direction.cross(camera_param.camera_orientation).unit_vector().scale(viewport_width);
        const viewport_height_vec = viewport_width_vec.cross(camera_param.camera_direction).unit_vector().scale(viewport_height);

        // Calculate delta_vector from pixel to pixel
        const pixel_delta_height = viewport_height_vec.divide(@floatFromInt(image_height)).scale(-1);
        const pixel_delta_width = viewport_width_vec.divide(@floatFromInt(image_width));

        // Upperleft corner of the viewport
        // upperleft = center + (viewport_u / 2) + (viewport_v / 2) + unit_vector(camera_direction)*focal_length;
        const viewport_upperleft = center.add(viewport_height_vec.divide(2.0)).subtract(viewport_width_vec.divide(2.0)).add(camera_param.camera_direction.unit_vector().scale(focal_length));

        // Camera is at the origin
        // Camera is looking towards the viewing direction
        // Camera is oriented in the direction of the orientation vector as the rough up direction
        // We calculate the true right direction (viewport_width_vec) by crossing the orientation vector (camera_orientation) and the viewing direction (camera_direction)
        // We calculate the true up direction (viewport_height_vec) by crossing the true right direction (camera_width_vec) and the viewing direction (camera_direction)

        // The pixel_00_location is the center of the first pixel which is the upperleft corner of the viewport
        const pixel_00_location = viewport_upperleft.add(pixel_delta_height.divide(2.0)).add(pixel_delta_width.divide(2.0));
        return .{
            .aspect_ratio = aspect_ratio,
            .focal_length = focal_length,
            .viewport_width = viewport_width,
            .viewport_height = viewport_height,

            .viewing_direction = camera_param.camera_direction,
            .camera_orientation = camera_param.camera_orientation,

            .center = center,
            .image_width = image_width,
            .image_height = image_height,
            .pixel_00_location = pixel_00_location,
            .pixel_delta_height = pixel_delta_height,
            .pixel_delta_width = pixel_delta_width,
        };
    }

    pub fn display_camera_info(self: Camera) void {
        std.debug.print("Camera Information\n", .{});
        std.debug.print("=======================================\n", .{});
        std.debug.print("Aspect Ratio: \t{d:.2}\n", .{self.aspect_ratio});
        std.debug.print("Focal Length: \t{d:.2}\n", .{self.focal_length});
        std.debug.print("Viewport Width: \t{d:.2}\n", .{self.viewport_width});
        std.debug.print("Viewport Height: \t{d:.2}\n", .{self.viewport_height});
        std.debug.print("Viewing Direction: \t{d:.2}\n", .{self.viewing_direction.array});
        std.debug.print("Camera Orientation: \t{d:.2}\n", .{self.camera_orientation.array});
        std.debug.print("Center: \t\t{d:.2}\n", .{self.center.array});
        std.debug.print("Image Width: \t\t{}\n", .{self.image_width});
        std.debug.print("Image Height: \t\t{}\n", .{self.image_height});
        std.debug.print("Pixel 00 Location: \t{d:.5}\n", .{self.pixel_00_location.array});
        std.debug.print("Pixel Delta Height: \t{d:.5}\n", .{self.pixel_delta_height.array});
        std.debug.print("Pixel Delta Width: \t{d:.5}\n", .{self.pixel_delta_width.array});
    }

    const writers = imports.writers;
    const SimpleWriter = writers.SimpleWriter;

    pub fn render(self: Camera, world: *const Hittable, file: std.fs.File, writer: SimpleWriter) void {
        // write header
        writer.write_header(file, .{
            .width = self.image_width,
            .height = self.image_height,
            .depth = 3,
        }) catch undefined;

        for (0..self.image_height) |j| { // y-height
            std.debug.print("\rScanlines remaining: {} ", .{self.image_height - j});
            for (0..self.image_width) |i| { // x-width
                const x_scale: f64 = @floatFromInt(i);
                const y_scale: f64 = @floatFromInt(j);
                const pixel_center = self.pixel_00_location.add(self.pixel_delta_height.scale(y_scale)).add(self.pixel_delta_width.scale(x_scale));
                const ray = Ray{
                    .origin = self.center,
                    .direction = pixel_center.subtract(self.center).unit_vector(),
                };
                const color = self.ray_clor(ray, world, 0);
                writer.write_color(color, file) catch undefined;
            }
        }
        return;
    }

    pub fn render_p7(self: Camera, world: *const Hittable, file: std.fs.File) void {
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
                const pixel_center = self.pixel_00_location.add(self.pixel_delta_height.scale(y_scale)).add(self.pixel_delta_width.scale(x_scale));
                const ray_direction = pixel_center.subtract(self.center);
                const ray = Ray{ .origin = self.center, .direction = ray_direction };

                const pixel_color = self.ray_color(&ray, world);
                pixel_color.write_color_p7(file) catch undefined;
            }
        }
        std.debug.print("\rDone.                   ", .{});
        std.debug.print("\n{} Scanlines completed.", .{self.image_height});
    }

    pub fn init2() Camera {
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
            return hit_rec.normal.add(Vec3.from_xyz(1.0, 1.0, 1.0)).unit_vector();
        } else {
            const background_color = imports.ray.sky_ray_color;
            return background_color(ray);
        }
    }
};
