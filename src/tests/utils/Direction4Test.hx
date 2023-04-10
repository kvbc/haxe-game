package tests.utils;

import math.IntVector2;
import utest.Assert;
import utils.Direction4;

class Direction4Test extends utest.Test {
    function test () {
        Assert.isTrue(UP   .toIntVector2() == new IntVector2( 0, -1));
        Assert.isTrue(DOWN .toIntVector2() == new IntVector2( 0,  1));
        Assert.isTrue(LEFT .toIntVector2() == new IntVector2(-1,  0));
        Assert.isTrue(RIGHT.toIntVector2() == new IntVector2( 1,  0));
        
        Assert.isTrue(UP    == Direction4.fromIntVector2(new IntVector2( 0, -1)));
        Assert.isTrue(DOWN  == Direction4.fromIntVector2(new IntVector2( 0,  1)));
        Assert.isTrue(LEFT  == Direction4.fromIntVector2(new IntVector2(-1,  0)));
        Assert.isTrue(RIGHT == Direction4.fromIntVector2(new IntVector2( 1,  0)));
        
        var bm: Direction4Bitmask = UP;
        Assert.isFalse(bm & [LEFT]);
        bm |= DOWN;
        Assert.isTrue(bm & [UP]);
        Assert.isTrue(bm & [DOWN]);
        Assert.isTrue(bm & [UP, DOWN]);
        Assert.isFalse(bm & [LEFT, RIGHT]);
        bm |= LEFT;
        Assert.isTrue(bm & [LEFT]);
        Assert.isFalse(bm & [RIGHT]);
        bm |= RIGHT;
        Assert.isTrue(bm & [RIGHT]);
    }
}