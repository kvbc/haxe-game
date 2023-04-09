package;

import math.IntVector2;
import world.vector2.ChunkVector2;
import event.EventManager;
import event.EventDispatcher;
import world.World;
import world.WorldChunk;
import world.World.WorldEventKind;
import world.vector2.ChunkVector2;
import world.vector2.TileVector2;
import world.vector2.PixelVector2;
import math.Vector2;

enum DebugGridEventKind {
    LOADED;
    SHOWED;
    HID;
}

class DebugGrid {
    public static inline var LINE_SIZE_TILE = 3; // in pixels
    public static inline var LINE_SIZE_CHUNK = 25; // in pixels
    public static inline var TILE_LINES_MIN_CAMERA_ZOOM = 0.25;
    public static inline var FONT_SIZE_CHUNK = 128;

    static public var instance(default, null): Null<DebugGrid> = null;
    static public var eventManager(get, never): EventManager<DebugGridEventKind>;
    static private var eventDispatcher = new EventDispatcher<DebugGridEventKind>();

    private var parent: Null<h2d.Object> = null;
    private var graphics: Null<h2d.Graphics> = null;

    private var prevTopLeftChunkPosition: Null<ChunkVector2> = null;
    private var prevBottomRightChunkPosition: Null<ChunkVector2> = null;

    public var show(default, set): Bool = false;

    //
    //
    //

    private function new (?parent: h2d.Object) {
        this.parent = parent;
    }

    public static function init (?parent: h2d.Object): DebugGrid {
        Debug.assert(instance == null);
        instance = new DebugGrid(parent);
        eventDispatcher.dispatch(LOADED);

        World.eventManager.addListener(event -> {
            if (
                (event == ANY_CHUNK_LOADED) ||
                (event == ANY_CHUNK_UNLOADED)
            ) {
                instance.forceNextUpdate();
            }
            else if (event == UPDATE) {
                instance.update();
            }
        });

        return instance;
    }

    //
    //
    //

    public function set_show (show: Bool): Bool {
        if (this.show != show) {
            if (show)
                eventDispatcher.dispatch(SHOWED);
            else
                eventDispatcher.dispatch(HID);
        }
        this.show = show;
        return show;
    }

    static public function get_eventManager () {
        return eventDispatcher;
    }

    //
    //
    //

    private function destroy () {
        if (graphics != null) {
            graphics.remove();
            graphics = null;
        }
    }

    private function forceNextUpdate (): Void {
        prevTopLeftChunkPosition = null;
        prevBottomRightChunkPosition = null;
    }

    private function update (): Void {
        if (!show) {
            forceNextUpdate();
            destroy();
            return;
        }
        
        var camera = World.instance.camera;

        var topLeftChunkPosition, bottomRightChunkPosition;
        {
            var topLeftPixelPosition = new PixelVector2(0, 0);
            var bottomRightPixelPosition: PixelVector2 = new Vector2(camera.base.viewportWidth, camera.base.viewportHeight).toIntVector2();
            camera.base.screenToCamera(topLeftPixelPosition.toPoint());
            camera.base.screenToCamera(bottomRightPixelPosition.toPoint());
            topLeftChunkPosition = topLeftPixelPosition.toChunkVector2();
            bottomRightChunkPosition = bottomRightPixelPosition.toChunkVector2();
        }

        if (prevTopLeftChunkPosition != null)
        if (topLeftChunkPosition == prevTopLeftChunkPosition)
            return;
        if (prevBottomRightChunkPosition != null)
        if (bottomRightChunkPosition == prevBottomRightChunkPosition)
            return;

        prevTopLeftChunkPosition = topLeftChunkPosition.clone();
        prevBottomRightChunkPosition = bottomRightChunkPosition.clone();

        // little bit of render padding
        topLeftChunkPosition -= new ChunkVector2(1, 1);
        bottomRightChunkPosition += new ChunkVector2(1, 1);

        var topLeftTilePosition = topLeftChunkPosition.toTileVector2();
        var bottomRightTilePosition = bottomRightChunkPosition.toTileVector2();

        var topLeftPixelPosition = topLeftChunkPosition.toPixelVector2();
        var bottomRightPixelPosition = bottomRightChunkPosition.toPixelVector2();

        destroy();
        var g = graphics = new h2d.Graphics(parent);

        for (tileIdx in topLeftTilePosition.minxy() ... bottomRightTilePosition.maxxy()) {
            if (tileIdx % WorldChunk.TILE_SIZE == 0) { // chunk line
                g.lineStyle(LINE_SIZE_CHUNK, 0xFF0000);
            }
            else { // tile line
                if (camera.zoom < TILE_LINES_MIN_CAMERA_ZOOM)
                    continue;
                g.lineStyle(LINE_SIZE_TILE, 0xFF0000);
            }

            var pixelX = new TileVector2(tileIdx, 0).toPixelVector2().x;
            g.moveTo(pixelX, topLeftPixelPosition.y);
            g.lineTo(pixelX, bottomRightPixelPosition.y);

            var pixelY = new TileVector2(0, tileIdx).toPixelVector2().y;
            g.moveTo(topLeftPixelPosition.x, pixelY);
            g.lineTo(bottomRightPixelPosition.x, pixelY);
        }
        
        for (chunkX in topLeftChunkPosition.x ... bottomRightChunkPosition.x + 1)
        for (chunkY in topLeftChunkPosition.y ... bottomRightChunkPosition.y + 1) {
            var chunkPosition = new ChunkVector2(chunkX, chunkY);
            var chunkTilePosition = chunkPosition.toTileVector2();
            var chunkPixelPosition = chunkPosition.toPixelVector2();
            var chunk = World.instance.getChunk(chunkPosition);

            var font = hxd.res.DefaultFont.get().clone();
            font.resizeTo(FONT_SIZE_CHUNK);

            var text = new h2d.Text(font);
            text.x = chunkPixelPosition.x;
            text.y = chunkPixelPosition.y;

            if (chunk == null)
                text.text = '$chunkPosition';
            else
                text.text = '$chunk';

            g.addChild(text);
        }

    }
}