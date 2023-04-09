package utils;

import math.IntVector2;
import hxbit.Serializable;
import haxe.ds.Vector;
import math.IntRect;

class FiniteGrid<T> {
    public var rect(default, null): IntRect;
    public var map(default, null): Vector<Vector<T>>;

    public function new (width: Int, height: Int) {
        this.rect = IntRect.fromDimensions(0, 0, width, height);
        this.map = new Vector(rect.height);
        for (iy in 0 ... rect.height) {
            map[iy] = new Vector(rect.width);
            for (ix in 0 ... rect.width)
                map[iy][ix] = null;
        } 
    }

    public function forEach (callback: (value: Null<T>, position: IntVector2, index: Int) -> Void): Void {
        for (x in 0 ... this.rect.width)
        for (y in 0 ... this.rect.height) {
            var position = new IntVector2(x, y);
            var value = this.get(position);
            var index = positionToIndex(position);
            callback(value, position, index);
        }
    }

    //
    //
    //

    public function isValidPosition (position: IntVector2): Bool {
        return this.rect.containsPoint(position); 
    }

    public function isValidIndex (index: Int): Bool {
        var position = _indexToPosition(index);
        return isValidPosition(position);
    }

    private function _positionToIndex (position: IntVector2): Int {
        return position.y * this.rect.width + position.x;
    }
    public function positionToIndex (position: IntVector2): Int {
        Debug.assert(isValidPosition(position));
        return _positionToIndex(position);
    }

    private function _indexToPosition (index: Int): IntVector2 {
        var y: Int = cast(index / this.rect.width);
        var x: Int = cast(index % this.rect.width);
        var position = new IntVector2(x, y);
        return position;
    }
    public function indexToPosition (index: Int): IntVector2 {
        Debug.assert(isValidIndex(index));
        return _indexToPosition(index);
    }

    //
    //
    //

    public function get (position: IntVector2): Null<T> {
        Debug.assert(isValidPosition(position));
        return this.map[position.y][position.x];
    }

    public function set (position: IntVector2, value: T): Void {
        Debug.assert(isValidPosition(position));
        this.map[position.y][position.x] = value;
    }

    public function idxGet (index: Int): Null<T> {
        return this.get(indexToPosition(index));
    }

    public function idxSet (index: Int, value: T): Void {
        this.set(indexToPosition(index), value);
    }
}