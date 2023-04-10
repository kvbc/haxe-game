package world;

import math.Vector2;
import world.vector2.PixelVector2;
import world.vector2.WorldVector2;
import math.IntVector2;

class WorldCamera {
    public var base(default, null): h2d.Camera;
    public var zoom(get, set): Float;
    public var position(get, set): WorldVector2;

    //
    //
    //

    public function new (baseCamera: h2d.Camera) {
        this.base = baseCamera;
    }

    public function worldToScreen (pos: Vector2): Vector2 {
        var pt = pos.toPoint();
        base.cameraToScreen(pt);
        return Vector2.fromPoint(pt);
    }
    public function worldToScreenI (pos: IntVector2): IntVector2 {
        return worldToScreen(pos.toVector2()).toIntVector2();
    }
    
    public function screenToWorld (pos: Vector2): Vector2 {
        var pt = pos.toPoint();
        base.screenToCamera(pt);
        return Vector2.fromPoint(pt);
    }
    public function screenToWorldI (pos: IntVector2): IntVector2 {
        return screenToWorld(pos.toVector2()).toIntVector2();
    }

    public function getMouseScreenPosition (): PixelVector2 {
        return new PixelVector2(
            hxd.Window.getInstance().mouseX,
            hxd.Window.getInstance().mouseY
        );
    }
    public function getMouseWorldPosition (): PixelVector2 {
        return screenToWorldI(getMouseScreenPosition());
    }

    //
    // get / set
    //
    
    public function get_zoom (): Float {
        return base.scaleX;
    }

    public function set_zoom (newZoom: Float): Float {
        base.scaleX = newZoom;
        base.scaleY = newZoom;
        return newZoom;
    }

    public function get_position (): WorldVector2 {
        return new WorldVector2(base.x, base.y);
    }

    public function set_position (newPosition: WorldVector2): WorldVector2 {
        base.x = newPosition.x;
        base.y = newPosition.y;
        return newPosition;
    }

    //
    //
    //

    public function toString (): String {
        return '
            Camera
                zoom: $zoom
        ';
    }
}