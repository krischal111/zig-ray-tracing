const std = @import("std");

pub const Interval = struct {
    min: f64 = -std.math.inf(f64),
    max: f64 = std.math.inf(f64),

    pub fn init(min: f64, max: f64) Interval {
        return Interval{ .min = min, .max = max };
    }

    pub fn not_contains(self: Interval, x: f64) bool {
        return !self.contains(x);
    }
    pub fn not_surrounds(self: Interval, x: f64) bool {
        return !self.surrounds(x);
    }

    pub fn contains(self: Interval, x: f64) bool {
        return self.min <= x and x <= self.max;
    }

    pub fn surrounds(self: Interval, x: f64) bool {
        return self.min < x and x < self.max;
    }

    const empty = Interval{ .min = std.math.inf(f64), .max = -std.math.inf(f64) };
    const universe = Interval{ .min = -std.math.inf(f64), .max = std.math.inf(f64) };
};

test "Interval" {
    const i = Interval.init(0, 1);
    try std.testing.expect(!i.contains(-0.5));
    try std.testing.expect(i.contains(-0.0));
    try std.testing.expect(i.contains(0.0));
    try std.testing.expect(i.contains(0.5));
    try std.testing.expect(i.contains(1.0));
    try std.testing.expect(!i.contains(1.5));

    try std.testing.expect(!i.surrounds(-0.5));
    try std.testing.expect(!i.surrounds(-0.0));
    try std.testing.expect(!i.surrounds(0.0));
    try std.testing.expect(i.surrounds(0.5));
    try std.testing.expect(!i.surrounds(1.0));
    try std.testing.expect(!i.surrounds(1.5));
}
