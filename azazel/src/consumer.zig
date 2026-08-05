//! Consumer of the vaxis library that Azazel builds from source. Calls
//! vaxis.gwidth.gwidth, which resolves grapheme display widths through the
//! Unicode tables uucode generates at build time. Correct widths mean the whole
//! graph (vaxis + zigimg + the uucode `fields` tables) compiled and works.
const std = @import("std");
const vaxis = @import("vaxis");

pub fn main() !void {
    const m: vaxis.gwidth.Method = .unicode;
    const ascii = vaxis.gwidth.gwidth("a", m);
    const wide = vaxis.gwidth.gwidth("\u{4e16}", m);
    const combining = vaxis.gwidth.gwidth("e\u{0301}", m);
    std.debug.print("azazel+vaxis: gwidth ascii={d} wide={d} combining={d}\n", .{ ascii, wide, combining });
    if (ascii != 1 or wide != 2 or combining != 1) return error.UnexpectedWidth;
    std.debug.print("azazel+vaxis: generated Unicode table OK\n", .{});
}
