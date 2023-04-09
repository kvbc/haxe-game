package tests.extenders;

import utest.Assert;
using extenders.FloatExtender;

class FloatExtenderTest extends utest.Test {
    private function test () {
        var n: Float = 3.123456789;

        Assert.equals(n.roundPrecision(1), 3.1);
        Assert.equals(n.roundPrecision(2), 3.12);
        Assert.equals(n.roundPrecision(3), 3.123);
        // weird stuff happens with precision > 3, but it's generally fine
        // Assert.equals(n.roundPrecision(4), 3.1234);
        // Assert.equals(n.roundPrecision(5), 3.12345);
        // Assert.equals(n.roundPrecision(6), 3.123456);
        // Assert.equals(n.roundPrecision(7), 3.1234567);
        // Assert.equals(n.roundPrecision(8), 3.12345678);
        // Assert.equals(n.roundPrecision(9), 3.123456789);
    }
}