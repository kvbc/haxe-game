package utils;

abstract Byte (Int) to Int {
    static private inline var MAX_INT: Int = 255;
    static public var MAX(default, never): Byte = new Byte(MAX_INT);

    public inline function new (int: Int) {
        Debug.assertRange(int, 0, MAX_INT);
        this = int;
    }

    @:from
    static public inline function fromInt (int: Int): Byte {
        return new Byte(int);
    }

    @:from
    static public inline function fromFloat (float: Float): Byte {
        return fromInt(cast float);
    }
}

abstract Color (Int) {
    public var r(get, set): Byte;
    public var g(get, set): Byte;
    public var b(get, set): Byte;
    public var a(get, set): Byte;

    public var rf(get, set): Float;
    public var gf(get, set): Float;
    public var bf(get, set): Float;
    public var af(get, set): Float;

    public inline function new (_r: Byte, _g: Byte, _b: Byte, ?_a: Null<Byte> = null) {
        if (_a == null)
            _a = Byte.MAX;
        this = 
            (_a << 24) |
            (_r << 16) |
            (_g << 8)  |
            (_b);
    }

    static public inline function fromFloats (r: Float, g: Float, b: Float, a: Float = 1.0): Color {
        Debug.assertRange(r, 0, 1);
        Debug.assertRange(g, 0, 1);
        Debug.assertRange(b, 0, 1);
        Debug.assertRange(a, 0, 1);
        return new Color(
            r * Byte.MAX,
            g * Byte.MAX,
            b * Byte.MAX,
            a * Byte.MAX
        );
    }

    // explicit
    static public inline function fromInt (int: Int): Color {
        return cast int;
    }

    private inline function set (other: Color) {
        this = cast(other, Int);
    }

    //
    //
    //

    public inline function toString (): String {
        return '($r, $g, $b)($af)';
    }

    public inline function isSimilar (other: Color, threshold: Float): Bool {
        Debug.assertRange(threshold, 0, 1);
        var drf = Math.abs(rf - other.rf);
        var dgf = Math.abs(gf - other.gf);
        var dbf = Math.abs(bf - other.bf);
        var daf = Math.abs(af - other.af);
        return (drf + dgf + dbf + daf) < threshold;
    }

    //
    //
    //

    public inline function get_a (): Byte { return (this >> 24) & 0xFF; }
    public inline function get_r (): Byte { return (this >> 16) & 0xFF; }
    public inline function get_g (): Byte { return (this >> 8)  & 0xFF; }
    public inline function get_b (): Byte { return (this)       & 0xFF; }

    public inline function get_af (): Float { return a / 255; }
    public inline function get_rf (): Float { return r / 255; }
    public inline function get_gf (): Float { return g / 255; }
    public inline function get_bf (): Float { return b / 255; }

    //
    //
    //

    public inline function set_a (na: Byte): Byte {
        set(new Color(r, g, b, na));
        return na;
    }
    public inline function set_r (nr: Byte): Byte {
        set(new Color(nr, g, b, a));
        return nr;
    }
    public inline function set_g (ng: Byte): Byte {
        set(new Color(r, ng, b, a));
        return ng;
    }
    public inline function set_b (nb: Byte): Byte {
        set(new Color(r, g, nb, a));
        return nb;
    }

    public inline function set_af (naf: Float): Float {
        set(Color.fromFloats(rf, gf, bf, naf));
        return naf;
    }
    public inline function set_rf (nrf: Float): Float {
        set(Color.fromFloats(nrf, gf, bf, af));
        return nrf;
    }
    public inline function set_gf (ngf: Float): Float {
        set(Color.fromFloats(rf, ngf, bf, af));
        return ngf;
    }
    public inline function set_bf (nbf: Float): Float {
        set(Color.fromFloats(rf, gf, nbf, af));
        return nbf;
    }
}