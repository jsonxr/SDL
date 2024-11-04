const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const match = @import("./glob.zig").match;

fn compareStrings(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs).compare(std.math.CompareOperator.lt);
}

pub fn file_glob(allocator: Allocator, path: []const u8, globs: []const []const u8) ![][]const u8 {
    var files = std.ArrayList([]const u8).init(allocator);
    defer files.deinit();

    var dir = try std.fs.cwd().openDir(path, .{
        .iterate = true,
        .access_sub_paths = true,
    });
    defer dir.close();

    var walker = try dir.walk(allocator);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        for (globs) |glob| {
            if (match(glob, entry.path)) {
                const copy = try allocator.dupe(u8, entry.path);
                try files.append(copy);
                break;
            }
        }
    }

    const items = try files.toOwnedSlice();
    std.mem.sort([]const u8, items, {}, compareStrings);
    return items;
}

test "file_glob" {
    try std.fs.cwd().makeDir("test-tmp");
    var iter_dir = try std.fs.cwd().openDir(
        "test-tmp",
        .{ .iterate = false },
    );
    defer {
        iter_dir.close();
        std.fs.cwd().deleteTree("test-tmp") catch unreachable;
    }
    _ = try iter_dir.createFile("x.c", .{});
    _ = try iter_dir.createFile("y.h", .{});
    _ = try iter_dir.createFile("z.c", .{});

    const allocator = testing.allocator;
    const files = try file_glob(allocator, "test-tmp", &.{"*.c"});
    defer {
        for (files) |file| allocator.free(file);
        allocator.free(files);
    }

    try testing.expect(std.mem.eql(u8, files[0], "x.c"));
    try testing.expect(std.mem.eql(u8, files[1], "z.c"));
}
