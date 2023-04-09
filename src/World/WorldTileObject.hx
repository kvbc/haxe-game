package world;

import utils.Direction4;
import world.WorldTilemap.ConnectionsMap;
import Logger.LogLevel;
import h2d.Object;
import utils.Measure;

class WorldTileObject extends Object {
    static public inline var DEBUG_RENDER_TIMEOUT: Float = 2.0;

    private var data: WorldTileData;
    private var bmp: h2d.Bitmap;
    private var debugBmp: h2d.Bitmap;
    private var lastRenderTimestamp: Null<Float> = null;

    //
    //
    //

    public function new (?parent: Object, chunk: WorldChunk, data: WorldTileData) {
        super(parent);

        this.data = data;
        this.bmp = new h2d.Bitmap(null, this);
        this.debugBmp = new h2d.Bitmap(
            h2d.Tile.fromColor(
                0xFF0000,
                WorldTileData.PX_SIZE,
                WorldTileData.PX_SIZE
            ),
            this
        );

        var pixelPosition = data.position.toPixelVector2();
        this.x = pixelPosition.x;
        this.y = pixelPosition.y;

        var chunkTileOffset = chunk.tilePositionToOffset(data.position);
        
        rerender(); // first render

        // Whenever a neighbour chunk gets loaded, rerender if its an edge tile
        chunk.eventManager.addListener(event -> {
            switch (event) {
                case BORDER_CHUNKS_LOADED(borderChunks):
                    if (borderChunks.exists(UP))
                    if (chunkTileOffset.y == 0) {
                        rerender();
                        return;
                    }
                    if (borderChunks.exists(DOWN))
                    if (chunkTileOffset.y == WorldChunk.TILE_SIZE - 1) {
                        rerender();
                        return;
                    }
                    if (borderChunks.exists(LEFT))
                    if (chunkTileOffset.x == 0) {
                        rerender();
                        return;
                    }
                    if (borderChunks.exists(RIGHT))
                    if (chunkTileOffset.x == WorldChunk.TILE_SIZE - 1) {
                        rerender();
                        return;
                    }
                case _:
                    return;
            }
        });

        this.debugBmp.visible = false;
        DebugGrid.eventManager.addListener(event -> {
            if (event == SHOWED)
                this.debugBmp.visible = true;
            else if (event == HID)
                this.debugBmp.visible = false;
        });

        World.eventManager.addListener(event -> {
            if (event == UPDATE) {
                var timestampNow = haxe.Timer.stamp();
                var timeElapsedSinceLastRender = timestampNow - this.lastRenderTimestamp;
                this.debugBmp.alpha = 1.0 - Math.min(1.0, timeElapsedSinceLastRender / DEBUG_RENDER_TIMEOUT);
            }
        });
    }

    static private function dataToTilemapTileType (data: WorldTileData): WorldTilemap.TileType {
        return switch (data.type) {
            case GRASS: GRASS;
            case WATER: WATER;
            case SAND:  SAND;
        }
    }

    private function rerender (): Void {
        this.lastRenderTimestamp = haxe.Timer.stamp();

        var tmTileType = dataToTilemapTileType(data);
        var frontConnections = new ConnectionsMap();
        for (dir in Direction4.getAll()) {
            var dirVector = dir.toIntVector2();
            var neighbourData = World.instance.getTileData(data.position + dirVector);
            if (neighbourData == null) // tile doesn't exist
                continue;

            if (data.zIndex > neighbourData.zIndex)
                continue;
            if (data.zIndex == neighbourData.zIndex) {
                if (data.type == GRASS)
                    continue;
                if (data.type == SAND)
                if (neighbourData.type == WATER)
                    continue;
            }

            var neighbourType = dataToTilemapTileType(neighbourData);
            if (neighbourType == tmTileType)
                continue;
            if (!frontConnections.exists(neighbourType))
                frontConnections[neighbourType] = new Direction4Bitmask();
            frontConnections[neighbourType] |= dir;
        }
        var tile: h2d.Tile = WorldTilemap.getTile(tmTileType, frontConnections);

        tile.scaleToSize(WorldTileData.PX_SIZE, WorldTileData.PX_SIZE);
        bmp.tile = tile;
    }
}