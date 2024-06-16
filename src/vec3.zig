pub const Vec3 = extern union {
    v: _Vec3,
    c: _Color,
    p: [3]f64,
    position: _Vec3,
    color: _Color,
    array: [3]f64,

    // instantiation works
    pub fn zero() @This() {
        return .{ .v = _Vec3.zero() };
    }
    pub fn new(v: _Vec3) @This() {
        return .{ .v = v };
    }
    pub fn new_color(c: _Color) @This() {
        return .{ .c = c };
    }
    pub fn from_xyz(xx: f64, yy: f64, zz: f64) @This() {
        return .{
            .v = _Vec3.from_xyz(xx, yy, zz),
        };
    }
    pub fn from_rgb(rr: f64, gg: f64, bb: f64) @This() {
        return .{
            .c = _Color.from_rgb(rr, gg, bb),
        };
    }
    pub fn as_array(self: @This()) [3]f64 {
        return self.p;
    }

    pub fn x(self: @This()) f64 {
        return self.v.x;
    }
    pub fn y(self: @This()) f64 {
        return self.v.y;
    }
    pub fn z(self: @This()) f64 {
        return self.v.z;
    }
    pub fn dot(self: @This(), other: @This()) f64 {
        return (self.v.dot(other.v));
    }
    pub fn cross(self: @This(), other: @This()) @This() {
        return .{ .v = self.v.cross(other.v) };
    }
    pub fn length_squared(self: @This()) f64 {
        return self.v.length_squared();
    }
    pub fn length(self: @This()) f64 {
        return self.v.length();
    }
    pub fn unit_vector(self: @This()) @This() {
        return .{ .v = self.v.unit_vector() };
    }
    pub fn add(self: @This(), other: @This()) @This() {
        return .{ .v = self.v.add(other.v) };
    }
    pub fn subtract(self: @This(), other: @This()) @This() {
        return .{ .v = self.v.subtract(other.v) };
    }
    pub fn multiply(self: @This(), other: @This()) @This() {
        return .{ .v = self.v.multiply(other.v) };
    }
    pub fn scale(self: @This(), t: f64) @This() {
        return .{ .v = self.v.scale(t) };
    }
    pub fn divide(self: @This(), t: f64) @This() {
        return .{ .v = self.v.divide(t) };
    }
    pub fn write_color_p7(self: @This(), out_stream: std.fs.File) !void {
        return self.c.write_color_p7(out_stream);
    }
    pub fn write_color_p3(self: @This(), out_stream: std.fs.File) !void {
        return self.c.write_color_p3(out_stream);
    }
};

const _Vec3 = extern struct {
    x: f64 = 0.0,
    y: f64 = 0.0,
    z: f64 = 0.0,

    fn zero() @This() {
        return .{};
    }
    fn from_xyz(xx: f64, yy: f64, zz: f64) @This() {
        return (.{ .x = xx, .y = yy, .z = zz });
    }

    fn dot(self: @This(), other: @This()) f64 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    fn cross(self: @This(), other: @This()) @This() {
        return .{
            .x = self.y * other.z - self.z * other.y,
            .y = self.z * other.x - self.x * other.z,
            .z = self.x * other.y - self.y * other.x,
        };
        // return @This().from_xyz(self.y * other.z - self.z * other.y, self.z * other.x - self.x * other.z, self.x * other.y - self.y * other.x);
    }

    fn length_squared(self: @This()) f64 {
        return self.dot(self);
    }

    fn length(self: @This()) f64 {
        return @sqrt(self.dot(self));
    }

    fn unit_vector(self: @This()) @This() {
        return self.divide(self.length());
    }

    fn add(self: @This(), other: @This()) @This() {
        return @This().from_xyz(self.x + other.x, self.y + other.y, self.z + other.z);
    }

    fn subtract(self: @This(), other: @This()) @This() {
        return @This().from_xyz(self.x - other.x, self.y - other.y, self.z - other.z);
    }

    /// Element wise multiplication
    fn multiply(self: @This(), other: @This()) @This() {
        return @This().from_xyz(self.x * other.x, self.y * other.y, self.z * other.z);
    }

    /// Multiply by a scalar
    fn scale(self: @This(), t: f64) @This() {
        return @This().from_xyz(self.x * t, self.y * t, self.z * t);
    }

    /// Divide by a scalar
    fn divide(self: @This(), t: f64) @This() {
        return @This().from_xyz(self.x / t, self.y / t, self.z / t);
    }
};

test "Vec3 instantiation" {
    const expect = @import("std").testing.expect;
    const expectEqual = @import("std").testing.expectEqual;

    // checking if instantiating it as xyz works
    const v0 = Vec3.from_xyz(1.0, 2.0, 3.0);
    try expect(v0.x() == 1.0);
    try expect(v0.y() == 2.0);
    try expect(v0.z() == 3.0);

    // checking if instanting it otherwise works
    const v1 = Vec3.new(.{ .x = 1.0, .y = 2.0, .z = 3.0 });
    try expectEqual(v0.c, v1.c);

    // checking if instantiating as zero vs from rgb are equivalent
    const v2 = Vec3.zero();
    const v3 = Vec3.from_rgb(0, 0, 0);
    try expectEqual(v2.p, v3.p);

    // checking if instantiang as from rgb or color are equivalnet
    const v4 = Vec3.new_color(.{ .r = 0.0, .b = 0.0, .g = 0.0 });
    try expectEqual(v3.p, v4.p);
}

test "Vec3 calculation 1" {
    const expect = @import("std").testing.expect;
    const expectEqual = @import("std").testing.expectEqual;

    const v0 = Vec3.from_xyz(1.0, 2.0, 3.0);
    const v1 = Vec3.from_xyz(4.0, 5.0, 6.0);
    const dot = v0.dot(v1);
    try expect(dot == 32);

    const v2 = v0.add(v1);
    const v3 = v2.subtract(v1);
    const v4 = v3.multiply(v1);
    try expect(v2.x() == 5);
    try expectEqual(v3.p, v0.p);
    try expect(v4.x() == 4.0);
}

test "Vec3 calculation 2" {
    const expect = @import("std").testing.expect;
    const expectEqual = @import("std").testing.expectEqual;

    const v0 = Vec3.from_xyz(1.0, 2.0, 3.0);
    const v1 = Vec3.from_xyz(4.0, 5.0, 6.0);
    const v2 = v0.cross(v1);
    const v0crossv1 = Vec3.from_xyz(-3.0, 6.0, -3.0);
    try expectEqual(v2.p, v0crossv1.p);

    const v3 = v0.scale(2.0);
    const v4 = v2.divide(3.0);
    try expectEqual(v3.p, .{ 2.0, 4.0, 6.0 });
    try expectEqual(v4.p, .{ -1.0, 2.0, -1.0 });

    const v5 = Vec3.from_xyz(3.0, 4.0, 0);
    const v5len = v5.length();
    try expect(v5len == 5.0);

    const v6 = v5.unit_vector();
    try expectEqual(v6.p, .{ 0.6, 0.8, 0.0 });
}

test "Vec3 calculation 3" {
    // const expect = @import("std").testing.expect;
    const expectEqual = @import("std").testing.expectEqual;

    const orien = Vec3.from_xyz(0, 1, 0);
    const direc = Vec3.from_xyz(0, 0, -1);
    const right = direc.cross(orien);
    const expec = Vec3.from_xyz(1, 0, 0);
    try expectEqual(right.p, expec.p);
}

const _Color = extern struct {
    r: f64 = 0.5,
    g: f64 = 0.5,
    b: f64 = 0.5,

    fn from_rgb(rr: f64, gg: f64, bb: f64) @This() {
        return (.{ .r = rr, .g = gg, .b = bb });
    }

    fn write_color_p7(self: @This(), out_stream: std.fs.File) !void {
        // this is not rust, this is zig

        const clamp = @import("std").math.clamp;

        const rbyte: u8 = @intFromFloat(clamp(self.r, 0.0, 0.999) * 256.0);
        const gbyte: u8 = @intFromFloat(clamp(self.g, 0.0, 0.999) * 256.0);
        const bbyte: u8 = @intFromFloat(clamp(self.b, 0.0, 0.999) * 256.0);

        const outw = out_stream.writer();
        try outw.print("{c}{c}{c}", .{ rbyte, gbyte, bbyte });
    }

    fn write_color_p3(self: @This(), out_stream: std.fs.File) !void {
        const clamp = @import("std").math.clamp;

        const rbyte: u8 = @intFromFloat(clamp(self.r, 0.0, 0.999) * 256.0);
        const gbyte: u8 = @intFromFloat(clamp(self.g, 0.0, 0.999) * 256.0);
        const bbyte: u8 = @intFromFloat(clamp(self.b, 0.0, 0.999) * 256.0);

        const outw = out_stream.writer();
        try outw.print("{} {} {}\n", .{ rbyte, gbyte, bbyte });
    }
};

const Color = Vec3;
const std = @import("std");
