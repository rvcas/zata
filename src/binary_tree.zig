const std = @import("std");
const testing = std.testing;

pub fn BinaryTree(comptime T: type) type {
    return struct {
        root: ?*Node,
        count: usize,
        allocator: *std.mem.Allocator,

        const Self = @This();

        pub const Node = struct {
            left: ?*Node,
            right: ?*Node,
            data: T,

            pub fn init(data: T) Node {
                return Node{
                    .left = null,
                    .right = null,
                    .data = data,
                };
            }
        };

        pub fn init(allocator: *std.mem.Allocator) Self {
            return Self{
                .root = null,
                .count = 0,
                .allocator = allocator,
            };
        }
    };
}

test "BinaryTree basic init" {
    var arena = std.heap.ArenaAllocator.init(std.heap.direct_allocator);
    defer arena.deinit();

    const allocator = &arena.allocator;

    const tree = BinaryTree(i32){
        .root = null,
        .count = 0,
        .allocator = allocator,
    };

    testing.expectEqual(tree.count, 0);
}

test "BinaryTree.init method" {
    var arena = std.heap.ArenaAllocator.init(std.heap.direct_allocator);
    defer arena.deinit();

    const allocator = &arena.allocator;

    const tree = BinaryTree(i32).init(allocator);

    testing.expectEqual(tree.count, 0);
}
