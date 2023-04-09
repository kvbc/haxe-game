package math;

import math.Vector2;

private typedef BaseIntVector2 = hxmath.math.IntVector2;

@:forward
@:forward.new
@:transitive
@:build(macros.ForwardOpsMacro.build("IntVector2", "hxmath.math.IntVector2"))
abstract IntVector2(BaseIntVector2) from BaseIntVector2 to BaseIntVector2 {
    @:to
    public inline function toVector2 (): math.Vector2 { 
        return new math.Vector2(
            Math.floor(this.x),
            Math.floor(this.y)
            // Std.int(this.x),
            // Std.int(this.y)
        //     Math.ceil(this.x),
        //     Math.ceil(this.y)
        );
    }

    public function minxy (): Int {
        return Std.int(Math.min(this.x, this.y));
    }

    public function maxxy (): Int {
        return Std.int(Math.max(this.x, this.y));
    }

    static public function fromIPoint (p: h2d.col.IPoint): IntVector2 {
        return new IntVector2(p.x, p.y);
    }

    static public function fromPoint (p: h2d.col.Point): IntVector2 {
        return Vector2.fromPoint(p).toIntVector2();
    }

    public inline function toIPoint (): h2d.col.IPoint {
        return new h2d.col.IPoint(this.x, this.y);
    }

    public inline function toPoint (): h2d.col.Point {
        return toVector2().toPoint();
    }

    @:op(A / B) public function div (value: Int): IntVector2
        return (toVector2() / value).toIntVector2();
}