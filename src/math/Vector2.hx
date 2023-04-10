package math;

private typedef BaseVector2 = hxmath.math.Vector2;

@:forward
@:forward.new
@:transitive
// @:build(macros.ForwardOpsMacro.build())
// FIXME magic autoBuild, the above does not work
@:autoBuild(macros.ForwardOpsMacro.build())
abstract Vector2(BaseVector2) from BaseVector2 {
    @:to
    public inline function toIntVector2 (): IntVector2 {
        return new IntVector2(
            Math.floor(this.x),
            Math.floor(this.y)
        );
    }

    static public inline  function fromPoint (p: h2d.col.Point): Vector2 {
        return new Vector2(p.x, p.y);
    }

    static public inline  function fromIPoint (p: h2d.col.IPoint): Vector2 {
        return IntVector2.fromIPoint(p).toVector2();
    }

    public inline function toPoint (): h2d.col.Point {
        return new h2d.col.Point(this.x, this.y);
    }

    public inline function toIPoint (): h2d.col.IPoint {
        return toIntVector2().toIPoint();
    }
    
    @:op(A / B) public inline function div (value: Int): Vector2
        return (this:BaseVector2) / (value:Float);
}