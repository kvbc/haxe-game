package utils;

import hxd.res.DynamicText.Key;
import haxe.Constraints.Constructible;
import math.IntVector2;
import hxbit.Serializable;
import haxe.ds.Vector;
import math.IntRect;

private class BaseGrid<TKey: IntVector2, TValue> {
    public var map(default, null) = new Map<Int, Map<Int, TValue>>(); // Y -> X

    public function new () {}

    public function forEach (callback: (value: Null<TValue>, position: IntVector2) -> Void): Void {
        for (y => row in map)
        for (x => value in row) {
            var position = new IntVector2(x, y);
            callback(value, position);
        }
    }

    //
    //
    //

    public function removePosition (position: TKey): Void {
        Debug.assert(exists(position));
        this.map[position.y].remove(position.x);
    }

    public function exists (position: TKey): Bool {
        return this.map.exists(position.y) && this.map[position.y].exists(position.x);
    }
}

@:generic
@:forward
@:forward.new
abstract Grid<TKey: IntVector2, TValue> (BaseGrid<TKey, TValue>) {
    @:arrayAccess
    public function get (position: TKey): Null<TValue> {
        // Debug.assert(this.exists(position));
        if (!this.map.exists(position.y))
            return null;
        return this.map[position.y][position.x];
    }

    @:arrayAccess
    public function set (position: TKey, value: TValue): Void {
        if (!this.map.exists(position.y))
            this.map[position.y] = new Map();
        this.map[position.y][position.x] = value;
    }
}