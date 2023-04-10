package tests.math;

import math.IntVector2;
import utest.Assert;
import math.IntRect;

class IntRectTest extends utest.Test {
    function test () {
        {
            var r = new IntRect(5, 10, 5, 10);
            Assert.equals(r.x, 5);
            Assert.equals(r.y, 5);
            Assert.equals(r.width, 6);
            Assert.equals(r.height, 6);
        }
        {
            var r = IntRect.fromDimensions(100, 100, 10, 10);
            Assert.equals(r.left, 100);
            Assert.equals(r.top, 100);
            Assert.equals(r.right, 109);
            Assert.equals(r.bottom, 109);
        }

        var r = IntRect.fromDimensions(5, 5, 10, 10);
        Assert.isFalse(r.containsPoint(new IntVector2(3, 3)));
        Assert.isTrue(r.containsPoint(new IntVector2(7, 7)));

        var r2 = IntRect.fromDimensions(3, 3, 20, 20);
        r.expandToFit(r2);
        Assert.equals(r.x, 3);
        Assert.equals(r.y, 3);
        Assert.equals(r.width, 20);
        Assert.equals(r.height, 20);
    }
}