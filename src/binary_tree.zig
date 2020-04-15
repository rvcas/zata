const std = @import("std");
const testing = std.testing;

pub fn BinaryTree(comptime T: type) type {
    return struct {
        root: ?*Node,
        count: usize = 0,
        allocator: *std.mem.Allocator,

        const Self = @This();

        pub fn init(allocator: *std.mem.Allocator) Self {
            return Self{
                .root = null,
                .count = 0,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            Node.deinit(self.root, self);
            self.root = null;
        }

        pub fn insert(self: *Self, data: T) !void {
            self.root = Node.insert(self.root, self, data);
        }

        pub fn map(self: *Self, func: fn (T) T) void {
            Node.map(self.root, func);
        }

        pub fn delete(self: *Self, data: T) void {
            self.root = Node.delete(self.root, self, data);
        }

        pub fn contains(self: *Self, data: T) bool {
            var iter = self.root;

            while (iter) |node| {
                if (node.data == data) {
                    return true;
                } else if (node.data < data) {
                    iter = node.right;
                } else {
                    iter = node.left;
                }
            } else {
                return false;
            }
        }

        const Node = struct {
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

            pub fn deinit(self: ?*Node, tree: *Self) void {
                if (self) |node| {
                    deinit(node.left, tree);
                    deinit(node.right, tree);

                    tree.allocator.destroy(self);
                    tree.count -= 1;
                }
            }

            fn insert(self: ?*Node, tree: *Self, data: T) ?*Node {
                if (self) |node| {
                    if (data > node.data) {
                        node.right = insert(node.right, tree, data);
                    } else if (data < node.data) {
                        node.left = insert(node.left, tree, data);
                    }

                    return self;
                } else {
                    var newNode = try tree.allocator.create(Node);
                    errdefer tree.allocator.destroy(newNode);

                    newNode.* = Node.init(data);

                    tree.count += 1;

                    return newNode;
                }
            }

            fn map(self: ?*Node, func: fn (T) T) void {
                if (self) |node| {
                    node.data = func(node.data);
                    map(node.left, func);
                    map(node.right, func);
                }
            }

            fn delete(self: ?*Node, tree: *Self, data: T) ?*Node {
                if (self) |node| {
                    if (node.data == data) {

                        // node with only one child or no child
                        if (node.left == null) {
                            var temp = node.right;

                            tree.count -= 1;

                            tree.allocator.destroy(self);

                            return temp;
                        } else if (node.right == null) {
                            var temp = node.left;

                            tree.count -= 1;

                            tree.allocator.destroy(self);

                            return temp;
                        }

                        // node with two children: Get the inorder successor
                        // (smallest in the right subtree)
                        var min = node.right;

                        while (min != null and min.?.left != null) {
                            min = min.?.left;
                        }

                        node.data = min.?.data;

                        node.right = delete(node.right, tree, min.?.data);
                    } else if (node.data < data) {
                        node.right = delete(node.right, tree, data);
                    } else {
                        node.left = delete(node.left, tree, data);
                    }

                    return self;
                } else {
                    return null;
                }
            }
        };
    };
}

test "BinaryTree basic init" {
    const tree = BinaryTree(i32){
        .root = null,
        .count = 0,
        .allocator = testing.allocator,
    };

    testing.expectEqual(tree.count, 0);
}

test "BinaryTree.init method" {
    const tree = BinaryTree(i32).init(testing.allocator);

    testing.expectEqual(tree.count, 0);
}

test "BinaryTree.insert method" {
    var tree = BinaryTree(i32).init(testing.allocator);
    defer tree.deinit();

    try tree.insert(3);
    try tree.insert(7);
    try tree.insert(2);

    testing.expectEqual(tree.count, 3);
    testing.expectEqual(tree.root.?.data, 3);
    testing.expectEqual(tree.root.?.right.?.data, 7);
    testing.expectEqual(tree.root.?.left.?.data, 2);
}

test "BinaryTree.map method" {
    var tree = BinaryTree(i32).init(testing.allocator);
    defer tree.deinit();

    try tree.insert(3);
    try tree.insert(7);
    try tree.insert(2);

    const addOne = struct {
        fn function(data: i32) i32 {
            return data + 1;
        }
    }.function;

    tree.map(addOne);

    testing.expectEqual(tree.count, 3);
    testing.expectEqual(tree.root.?.data, 4);
    testing.expectEqual(tree.root.?.right.?.data, 8);
    testing.expectEqual(tree.root.?.left.?.data, 3);
}

test "BinaryTree.contains method" {
    var tree = BinaryTree(i32).init(testing.allocator);
    defer tree.deinit();

    try tree.insert(3);
    try tree.insert(7);
    try tree.insert(2);

    testing.expect(tree.contains(7));
    testing.expect(tree.contains(2));
    testing.expect(!tree.contains(8));
}

test "BinaryTree.delete method" {
    var tree = BinaryTree(i32).init(testing.allocator);
    defer tree.deinit();

    try tree.insert(4);
    try tree.insert(7);
    try tree.insert(1);
    try tree.insert(3);
    try tree.insert(6);

    testing.expectEqual(tree.count, 5);
    testing.expectEqual(tree.root.?.data, 4);

    tree.delete(4);

    testing.expectEqual(tree.count, 4);
    testing.expectEqual(tree.root.?.data, 6);
}
