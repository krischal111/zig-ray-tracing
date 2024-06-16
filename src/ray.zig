const Vec3 = @import("vec3.zig").Vec3;
const Point3 = Vec3;
const Color = Vec3;

pub const Ray = struct {
    origin: Point3,
    direction: Vec3,
    pub fn at(self: Ray, t: f64) Point3 {
        return self.origin.add(self.direction.scale(t));
    }
};

// blue to white gradient
// color ray_color(const ray& r) {
//     vec3 unit_direction = unit_vector(r.direction());
//     auto a = 0.5*(unit_direction.y() + 1.0);
//     return (1.0-a)*color(1.0, 1.0, 1.0) + a*color(0.5, 0.7, 1.0);
// }

pub fn sky_ray_color(r: *const Ray) Color {
    const unit_direction = r.direction.unit_vector();
    const a = 0.5 * (unit_direction.v.y + 1.0);
    return Color.from_rgb(1.0, 1.0, 1.0).scale(1.0 - a).add(Color.from_rgb(0.5, 0.7, 1.0).scale(a));
}
