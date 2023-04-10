package tests.utils;

import utest.Assert;
import math.IntVector2;
import utils.Grid;

class GridTest extends utest.Test {
    function test () {
        var g = new Grid<IntVector2, Int>();
        var p = new IntVector2(314, 123);

        Assert.isFalse(g.exists(p));
        g[p] = 69;
        Assert.equals(69, g[p]);
        Assert.isTrue(g.exists(p));

        g.removePosition(p);
        Assert.isFalse(g.exists(p));
        g[p] = 69;

        var v = 420;
        g.forEach((_, pos) -> {
            g[pos] = v;
        });
        Assert.equals(v, g[p]);
    }
}