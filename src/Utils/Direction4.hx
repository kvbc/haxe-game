package utils;

import math.IntVector2;

abstract Direction4Bitmask(Int) {
    public function new () {
        this = 0;
    }

    public function isEmpty (): Bool {
        return this == 0;
    }

    static private function dirbit (dir: Direction4): Int {
        return switch (dir) {
            case UP:    1 << 0;
            case DOWN:  1 << 1;
            case LEFT:  1 << 2;
            case RIGHT: 1 << 3;
        }
    }

    @:from static public function fromDirection (dir: Direction4): Direction4Bitmask {
        return cast dirbit(dir);
    }

    @:op(A | B)
    public function setDirection (dir: Direction4): Direction4Bitmask {
        return cast(this | dirbit(dir));
    }

    @:op(A & B)
    public function areDirectionsSet (...dirs: Direction4): Bool {
        for (dir in dirs)
            if (this & dirbit(dir) == 0)
                return false;
        return true;
    }
}

enum abstract Direction4(Int) {
    static private var V_UP    (get, never): IntVector2;
    static private var V_DOWN  (get, never): IntVector2;
    static private var V_LEFT  (get, never): IntVector2;
    static private var V_RIGHT (get, never): IntVector2;
    static private function get_V_UP    () return { new IntVector2(0, -1); }
    static private function get_V_DOWN  () return { new IntVector2(0,  1); }
    static private function get_V_LEFT  () return { new IntVector2(-1, 0); }
    static private function get_V_RIGHT () return { new IntVector2( 1, 0); }

    var UP;
    var DOWN;
    var LEFT;
    var RIGHT;

    static public function getAll (): Array<Direction4> {
        return [UP, DOWN, LEFT, RIGHT];
    }

    @:from
    static public function fromIntVector2 (v: IntVector2): Direction4 {
        if (v == V_UP)    return UP;
        if (v == V_DOWN)  return DOWN;
        if (v == V_LEFT)  return LEFT;
        if (v == V_RIGHT) return RIGHT;
        throw "Invalid direction vector";
    }

    @:to
    public function toIntVector2 (): IntVector2 {
        return switch (cast this) {
            case UP:    V_UP;
            case DOWN:  V_DOWN;
            case LEFT:  V_LEFT;
            case RIGHT: V_RIGHT;
        }
    }
}