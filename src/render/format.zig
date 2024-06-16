const std = @import("std");

const _Header = struct {
    width: u32 = 800,
    height: u32 = 600,
    depth: u32 = 3,
    maxval: u32 = 255,
    tupltype: []const u8 = "RGB",
};
pub fn write_p3_header(file: std.fs.File, header: _Header) !void {
    const writer = file.writer();
    try writer.print("P3\n{} {}\n{}\n", .{ header.width, header.height, header.maxval });
    // _ = writer;
    // _ = header;
}
pub fn write_p7_header(file: std.fs.File, header: _Header) !void {
    const writer = file.writer();
    try writer.print("P7\nWIDTH {}\nHEIGHT {}\nDEPTH {}\nMAXVAL {}\nTUPLTYPE {s}\nENDHDR\n", .{ header.width, header.height, header.depth, header.maxval, header.tupltype });
    // _ = writer;
    // _ = header;
}
