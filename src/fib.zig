const std = @import("std");
const testing = std.testing;

pub fn fib(n: u64) u64 {
    if (n == 0) {
        return 0;
    }
    if (n == 1) {
        return 1;
    }

    return fib(n - 1) + fib(n - 2);
}

pub fn fibMem(n: u64, map: *std.AutoHashMap(u64, u64)) u64 {
    if (map.contains(n)) {
        return map.getValue(n) orelse 0;
    }

    var x: u64 = fib(n - 1) + fib(n - 2);

    _ = map.put(n, x) catch unreachable;

    return x;
}

pub fn fibLin(n: u64, map: *std.AutoHashMap(u64, u64)) u64 {
    // limit to 256 max fib number.
    var i: u8 = 2;

    while (i <= n) : (i += 1) {
        _ = map.put(i, map.getValue(i - 1).? + map.getValue(i - 2).?) catch unreachable;
    }

    return map.getValue(n).?;
}

pub fn fibDyn(n: u64) u64 {
    if (n == 0 or n == 1) {
        return n;
    }

    var iter: u64 = 1;
    var prev: u64 = 0;
    var result: u64 = 1;

    while (iter < n) : (iter += 1) {
        var temp = result;
        result += prev;
        prev = temp;
    }

    return result;
}

test "fib" {
    testing.expectEqual(@as(u64, 21), fib(8));
}

test "fibMem" {
    var map = std.AutoHashMap(u64, u64).init(std.testing.allocator);
    defer map.deinit();

    _ = map.put(0, 0) catch unreachable;
    _ = map.put(1, 1) catch unreachable;

    testing.expectEqual(@as(u64, 21), fibMem(8, &map));
}

test "fibLin" {
    var map = std.AutoHashMap(u64, u64).init(std.testing.allocator);
    defer map.deinit();

    _ = map.put(0, 0) catch unreachable;
    _ = map.put(1, 1) catch unreachable;

    testing.expectEqual(@as(u64, 21), fibLin(8, &map));
}

test "fibDyn" {
    testing.expectEqual(@as(u64, 21), fibDyn(8));
}
