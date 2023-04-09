package tests.utils;

import utest.Assert;
import utils.Color;

class ColorTest extends utest.Test {
    function test () {
        var c = new Color(255, 0, 255);
        Assert.equals(c.r, 255);
        Assert.equals(c.g, 0);
        Assert.equals(c.b, 255);
        Assert.equals(c.a, 255); // 0-255 => transparent-opaque

        Assert.equals(c.rf, 1);
        Assert.equals(c.gf, 0);
        Assert.equals(c.bf, 1);
        Assert.equals(c.af, 1);

        c.r = 128;
        c.g = 64;
        c.b = 32;
        Assert.equals(c.r, 128);
        Assert.equals(c.g, 64);
        Assert.equals(c.b, 32);

        Assert.floatEquals(c.rf, 128 / 255);
        Assert.floatEquals(c.gf, 64 / 255);
        Assert.floatEquals(c.bf, 32 / 255);

        c.rf = 0.25;
        c.gf = 0.50;
        c.bf = 0.75;
        Assert.floatEquals(Std.int(0.25*255)/255, c.rf);
        Assert.floatEquals(Std.int(0.50*255)/255, c.gf);
        Assert.floatEquals(Std.int(0.75*255)/255, c.bf);

        Assert.equals(c.r, Std.int(255 * 0.25));
        Assert.equals(c.g, Std.int(255 * 0.50));
        Assert.equals(c.b, Std.int(255 * 0.75));
    }
}