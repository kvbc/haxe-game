package math;

import h2d.col.Point;
import h2d.col.IPoint;
import math.Vector2;

private typedef BaseIntVector2 = hxmath.math.IntVector2;

@:forward
@:forward.new
@:transitive
@:build(macros.ForwardOpsMacro.build())
abstract IntVector2(BaseIntVector2) from BaseIntVector2 {
    @:to
    public inline function toVector2 (): math.Vector2 { 
        return new math.Vector2(this.x, this.y);
    }

    public inline function minxy (): Int {
        return Std.int(Math.min(this.x, this.y));
    }

    public inline function maxxy (): Int {
        return Std.int(Math.max(this.x, this.y));
    }

    static public inline function fromIPoint (p: IPoint): IntVector2 {
        return new IntVector2(p.x, p.y);
    }

    static public inline function fromPoint (p: Point): IntVector2 {
        return Vector2.fromPoint(p).toIntVector2();
    }

    public inline function toIPoint (): IPoint {
        return new IPoint(this.x, this.y);
    }

    public inline function toPoint (): Point {
        return toVector2().toPoint();
    }

    @:op(A / B) public inline function div (value: Int): IntVector2
        return (toVector2() / value).toIntVector2();
}