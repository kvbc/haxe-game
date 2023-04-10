package world;

import h2d.Graphics;
import h2d.Object;
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

class WorldDebugGrid {
    public static inline var LINE_SIZE_TILE = 3; // in pixels
    public static inline var LINE_SIZE_CHUNK = 25; // in pixels
    public static inline var TILE_LINES_MIN_CAMERA_ZOOM = 0.25;
    public static inline var FONT_SIZE_CHUNK = 128;

    static public var visible(default, set): Bool = false;

    static private var object: h2d.Object;
    static private var graphics: Null<h2d.Graphics> = null;

    static private var prevTopLeftChunkPosition: Null<ChunkVector2> = null;
    static private var prevBottomRightChunkPosition: Null<ChunkVector2> = null;

    //
    //
    //

    static public function init (parent: h2d.Object) {
        object = new Object(parent);

        World.eventManager.addListener(event -> {
            switch (event) {
                case UPDATE:
                    update();
                case CHUNKS_LOADED(_) | ANY_CHUNK_UNLOADED:
                    forceNextUpdate();
                case _:
                    return;
            }
        });
    }

    //
    //
    //

    static public function set_visible (newVisible: Bool): Bool {
        visible = newVisible;
        return newVisible;
    }

    //
    //
    //

    static private function destroy () {
        if (graphics != null) {
            graphics.remove();
            graphics = null;
        }
    }

    static private function forceNextUpdate (): Void {
        prevTopLeftChunkPosition = null;
        prevBottomRightChunkPosition = null;
    }

    static private function update (): Void {
        if (!visible) {
            forceNextUpdate();
            destroy();
            return;
        }
        
        var camera = World.camera;

        var topLeftChunkPosition, bottomRightChunkPosition;
        {
            var topLeftPixelPosition: PixelVector2 = camera.screenToWorldI(new PixelVector2(0, 0));
            var bottomRightPixelPosition: PixelVector2 = camera.screenToWorldI(
                new Vector2(camera.base.viewportWidth, camera.base.viewportHeight).toIntVector2()
            );
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
        var g = graphics = new Graphics(object);

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
            var chunk = World.getChunk(chunkPosition);

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