package tests.extenders;

import h2d.Bitmap;
import hxd.Window;
import utest.Assert;
using extenders.TileExtender;

class TileExtenderTest extends utest.Test {
    private function test () {
        var tile = h2d.Tile.fromColor(0xFF0000, 100, 100);
        var w = tile.width;
        var h = tile.height;

        tile.scale(1.5);
        w *= 1.5;
        h *= 1.5;

        Assert.equals(w, tile.width);
        Assert.equals(h, tile.height);

        tile.scale(0.5);
        w *= 0.5;
        h *= 0.5;

        Assert.equals(w, tile.width);
        Assert.equals(h, tile.height);
    }
}