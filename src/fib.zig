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

test "fib(21)" {
    assert(fib(21) == 10946);
}
