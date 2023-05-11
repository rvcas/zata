const std = @import("std");

pub usingnamespace @import("linked_list.zig");
pub usingnamespace @import("binary_tree.zig");

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

// test "all" {
//     _ = @import("linked_list.zig");
//     _ = @import("binary_tree.zig");
// }
