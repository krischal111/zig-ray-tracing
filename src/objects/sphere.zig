const std = @import("std");
const imports = @import("../imports.zig");

const Vec3 = imports.Vec3;
const HitRecord = imports.HitRecord;
const Ray = imports.Ray;
const Interval = imports.Interval;

pub const Sphere = struct {
    center: Vec3 = Vec3.zero(),
    radius: f64 = 1.0,

    pub fn new(center: Vec3, radius: f64) Sphere {
        return Sphere{ .center = center, .radius = @max(0, radius) };
    }

    pub fn hit(self: Sphere, ray: *const Ray, interval: Interval, rec: *HitRecord) bool {
        const oc = ray.origin.subtract(self.center);
        const a = ray.direction.length_squared();
        const half_b = oc.dot(ray.direction);
        const c = oc.length_squared() - self.radius * self.radius;
        const discriminant = half_b * half_b - a * c;

        if (discriminant < 0.0) { // no real roots (no intersection)
            return false;
        }

        const sqrtd = @sqrt(discriminant);

        // Logic:
        // Check if the smaller root is in the range
        // If no, check if the larger root is in the range
        // If no, return false, early return

        // Find the nearest root that lies in the acceptable range.
        const smaller_root = (half_b - sqrtd) / a;
        if (smaller_root > interval.max) {
            return false;
        }
        var nearest_root = smaller_root;
        if (interval.not_contains(smaller_root)) {
            const larger_root = (half_b + sqrtd) / a;
            nearest_root = larger_root; // larger root
            if (interval.not_contains(larger_root)) {
                return false;
            }
        }

        rec.t = nearest_root;
        rec.point = ray.at(rec.t);
        // const outward_normal = (rec.p - self.center) / self.radius;
        // rec.set_face_normal(ray, outward_normal);
        const outward_normal = rec.point.subtract(self.center).divide(self.radius); // makes the normal unit length
        rec.set_face_normal(ray, outward_normal);

        return true;
    }
};
