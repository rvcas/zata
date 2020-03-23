const std = @import("std");
const testing = std.testing;

pub fn BinaryTree(comptime T: type) type {
    return struct {
        root: ?*Node,
        count: usize = 0,
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

        pub fn insert(self: *Self, data: T) !void {
            var newNode = try self.allocator.create(Node);
            defer self.allocator.destroy(newNode);

            newNode.* = Node.init(data);

            if (self.root == null) {
                self.root = newNode;
            } else {
                var currentNode = self.root;

                while (currentNode) |node| {
                    if (node.data < data) {
                        if (node.right) |right| {
                            currentNode = right;
                        } else {
                            node.right = newNode;
                            break;
                        }
                    } else {
                        if (node.left) |left| {
                            currentNode = left;
                        } else {
                            node.left = newNode;
                            break;
                        }
                    }
                }
            }

            self.count += 1;
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

    var tree = BinaryTree(i32).init(allocator);

    testing.expectEqual(tree.count, 0);
}

test "BinaryTree.insert method" {
    var arena = std.heap.ArenaAllocator.init(std.heap.direct_allocator);
    defer arena.deinit();

    const allocator = &arena.allocator;

    var tree = BinaryTree(i32).init(allocator);

    try tree.insert(3);
    try tree.insert(7);
    try tree.insert(2);

    testing.expectEqual(tree.count, 3);
    testing.expectEqual(tree.root.?.data, 3);
    testing.expectEqual(tree.root.?.right.?.data, 7);
    testing.expectEqual(tree.root.?.left.?.data, 2);
}
