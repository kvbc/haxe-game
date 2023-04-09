package math;

private typedef BaseVector2 = hxmath.math.Vector2;

@:forward
@:forward.new
@:transitive
@:build(macros.ForwardOpsMacro.build("Vector2", "hxmath.math.Vector2"))
abstract Vector2(BaseVector2) from BaseVector2 to BaseVector2 {
    @:to
    public inline function toIntVector2 (): IntVector2 {
        return new IntVector2(
            // Std.int(this.x),
            // Std.int(this.y)
            Math.floor(this.x),
            Math.floor(this.y)
        );
    }

    static public function fromPoint (p: h2d.col.Point): Vector2 {
        return new Vector2(p.x, p.y);
    }

    static public function fromIPoint (p: h2d.col.IPoint): Vector2 {
        return IntVector2.fromIPoint(p).toVector2();
    }

    public inline function toPoint (): h2d.col.Point {
        return new h2d.col.Point(this.x, this.y);
    }

    public inline function toIPoint (): h2d.col.IPoint {
        return toIntVector2().toIPoint();
    }

    @:op(A / B) public function div (value: Int): Vector2
        return (this: BaseVector2) / (value: Float);
}