package math;

class IntRect {
    public var left: Int;
    public var right: Int;
    public var top: Int;
    public var bottom: Int;

    public var x(get, set): Int;
    public var y(get, set): Int;
    public var width(get, set): Int;
    public var height(get, set): Int;

    public function new (
        left: Int,
        right: Int,
        top: Int,
        bottom: Int
    ) {
        this.left = left;
        this.right = right;
        this.top = top;
        this.bottom = bottom;
    }

    static public function fromDimensions (
        x: Int,
        y: Int,
        width: Int,
        height: Int
    ): IntRect {
        var rect = new IntRect(0, 0, 0, 0);
        rect.x = x;
        rect.y = y;
        rect.width = width;
        rect.height = height;
        return rect;
    }

    //
    //
    //

    public function get_x (): Int {
        return left;
    }

    public function get_y (): Int {
        return top;
    }

    public function get_width (): Int {
        return right - left + 1;
    }

    public function get_height (): Int {
        return bottom - top + 1;
    }

    //
    //
    //

    public function set_x (newX: Int): Int {
        left = newX;
        return newX;
    }

    public function set_y (newY: Int): Int {
        top = newY;
        return newY;
    }

    public function set_width (newWidth: Int): Int {
        Debug.assert(newWidth > 0);
        right = left + newWidth - 1;
        return newWidth;
    }
    
    public function set_height (newHeight: Int): Int { 
        Debug.assert(newHeight > 0);
        bottom = top + newHeight - 1;
        return newHeight;
    }

    //
    //
    //

    public function expandToFit (other: IntRect): Void {
        left   = cast Math.min(left,   other.left);
        right  = cast Math.max(right,  other.right);
        top    = cast Math.min(top,    other.top);
        bottom = cast Math.max(bottom, other.bottom);
    }

    public function containsPoint (point: math.IntVector2): Bool {
        return (
            (point.x >= left) &&
            (point.x <= right) &&
            (point.y >= top) &&
            (point.y <= bottom)
        );
    }
}