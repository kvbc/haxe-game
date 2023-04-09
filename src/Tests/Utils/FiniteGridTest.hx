package tests.utils;

import math.IntVector2;
import utest.Assert;
import utils.FiniteGrid;

class FiniteGridTest extends utest.Test {
    function test () {
        var g = new FiniteGrid<Int>(5, 5);
        var p = new IntVector2(2, 1);
        // 0 1 2 3 4
        // 5 6 7
        var i = 7;
        Assert.equals(g.get(p), null);
        Assert.equals(g.idxGet(0), null);
        Assert.isTrue(p == g.indexToPosition(i));
        Assert.equals(i, g.positionToIndex(p));
        Assert.isTrue(g.isValidPosition(p));
        Assert.isTrue(g.isValidIndex(i));

        {
            var v = 69;
            g.set(p, v);
            Assert.equals(v, g.get(p));
        }
        {
            var v = 420;
            g.idxSet(i, v);
            Assert.equals(v, g.idxGet(i));
        }

        var v = 35;
        g.forEach((_, pos, _) -> {
            g.set(pos, v);
        });
        Assert.equals(v, g.get(p));
    }
}