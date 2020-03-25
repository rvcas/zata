const std = @import("std");
const assert = std.debug.assert;

pub fn fib(n: u64) u64 {
    if (n == 0) {
        return 0;
    }
    if (n == 1) {
        return 1;
    }

    return fib(n - 1) + fib(n - 2);
}


pub fn fib_mem(n: u64, map: *std.AutoHashMap(u64,u64)) u64 {
    if (map.contains(n)) {
        return map.getValue(n) orelse 0;
    }

    var x: u64 = fib(n - 1) + fib(n - 2);
    _  = map.put(n, x) catch unreachable;

    return x;
}

test "fib(21)" {
    assert(fib(21) == 10946);
test "memorization" {
    var map = std.AutoHashMap(u64, u64).init(std.testing.allocator);
    defer map.deinit();
    _ = map.put(0, 0) catch unreachable;
    _ = map.put(1, 1) catch unreachable;
    assert(fib_mem(21, &map) == 10946);

}

}
