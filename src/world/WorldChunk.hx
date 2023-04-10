package world;

import h2d.Tile;
import h2d.Bitmap;
import h2d.TileGroup;
import world.vector2.TileVector2;
import world.vector2.ChunkVector2;
import utils.FiniteGrid;
import utils.Direction4;
import event.EventManager;
import event.EventDispatcher;
import utils.Measure;
import h2d.Object;
import haxe.ds.Vector;
import world.WorldTilemap;

private enum CreationType {
    GENERATED;
    DESERIALIZED;
}

class WorldChunk {
    public static inline var TILE_SIZE: Int = 16;
    public static inline var TILE_RENDERS_PER_FRAME = 1;

    private var object: h2d.Object;
    private var creationType: CreationType;
    private var tileDataGrid: FiniteGrid<WorldTileData>;
    private var tileGroup: TileGroup;

    private static inline var DEBUG_RENDER_TIMEOUT: Float = 2.0;
    private var debugBmp: Bitmap;
    private var lastRenderTimestamp: Float = 0.0;

    public var position(default, null): ChunkVector2;

    //
    //
    //

    private function new (
        ?parent: Object,
        position: ChunkVector2,
        tileDataGrid: FiniteGrid<WorldTileData>,
        creationType: CreationType
    ) {
        this.object = new h2d.Object(parent);
        {
            var pxPosition = position.toPixelVector2();
            object.x = pxPosition.x;
            object.y = pxPosition.y;
        }

        this.position = position;
        this.creationType = creationType;
        this.tileDataGrid = tileDataGrid;

        // FIXME sometimes works, sometimes doesn't
        tileGroup = new TileGroup(WorldTilemap.getGlobalTile(), object);
        // tileGroup = new TileGroup(object);

        this.debugBmp = new Bitmap(
            Tile.fromColor(
                0xFF0000,
                TILE_SIZE * WorldTileData.PX_SIZE,
                TILE_SIZE * WorldTileData.PX_SIZE
            ),
            object
        );
        this.debugBmp.visible = false;

        //
        //
        //

        World.onLoad(() -> {
            rerender();

            World.eventManager.addEventListener(UPDATE, () -> {
                this.debugBmp.visible = WorldDebugGrid.visible;
                if (WorldDebugGrid.visible) {
                    var timestampNow = haxe.Timer.stamp();
                    var timeElapsedSinceLastRender = timestampNow - this.lastRenderTimestamp;
                    this.debugBmp.alpha = 1.0 - Math.min(1.0, timeElapsedSinceLastRender / DEBUG_RENDER_TIMEOUT);
                }
            });

            World.eventManager.addListener(event -> {
                switch (event) {
                    case CHUNKS_LOADED(chunks):
                        if (chunks.contains(this)) {
                            rerender();
                        }
                        else {
                            for (chunk in chunks)
                            for (dir in Direction4.getAll()) {
                                var borderChunkPosition = this.position + dir.toIntVector2();
                                if (borderChunkPosition == chunk.position) {
                                    rerender();
                                    return;
                                }
                            }
                        }
                    case _:
                        return;
                }
            });
        });

    }

    //
    //
    //

    public function destroy (): Void {
        object.remove();
    }

    public function getTileData (tileOffset: TileVector2): WorldTileData {
        return tileDataGrid.get(tileOffset);
    }

    //
    //
    //

    private function rerender (): Void {
        this.lastRenderTimestamp = haxe.Timer.stamp();

        tileGroup.clear();

        tileDataGrid.forEach((data: WorldTileData, offset: TileVector2, _) -> {
            function toTilemapTileType (dataType: WorldTileData.Type): WorldTilemap.TileType {
                return switch (dataType) {
                    case GRASS : GRASS;
                    case SAND  : SAND;
                    case WATER : WATER;
                }
            }

            var frontNeighbours = new Map();
            for (dir in Direction4.getAll()) {
                var nPos = data.position + dir.toIntVector2();
                var nData = World.getTileData(nPos);
                if (nData == null)
                    continue;

                if (nData.type == data.type)
                    continue;
                if (data.zIndex > nData.zIndex)
                    continue;
                if (data.zIndex == nData.zIndex) {
                    if (data.type == GRASS)
                        continue;
                    if (data.type == SAND)
                    if (nData.type == WATER)
                        continue;
                }

                frontNeighbours[dir] = toTilemapTileType(nData.type);
            }

            var tile = WorldTilemap.getTile({
                backTileType: toTilemapTileType(data.type),
                neighbours: frontNeighbours
            });
            tile.scaleToSize(WorldTileData.PX_SIZE, WorldTileData.PX_SIZE);

            var pxOffset = offset.toPixelVector2();
            tileGroup.add(pxOffset.x, pxOffset.y, tile);
        });
    }

    //
    //
    //

    static public function generate (parent: Object, position: ChunkVector2): WorldChunk {
        var chunkTilePosition = position.toTileVector2();
        
        var tileDataGrid = new FiniteGrid<WorldTileData>(TILE_SIZE, TILE_SIZE);
        tileDataGrid.forEach((_, tileOffset: TileVector2, _) -> {
            var tilePosition = chunkTilePosition + tileOffset;
            var tileData = WorldTileData.generate(tilePosition);
            tileDataGrid.set(tileOffset, tileData);
        });

        return new WorldChunk(parent, position, tileDataGrid, CreationType.GENERATED);
    }

    public function serialize (): String {
        var string = "";
        
        tileDataGrid.forEach((tileData: WorldTileData, tilePosition: TileVector2, _) -> {
            string += tileData.serialize();
            var isLastX = (tilePosition.x == TILE_SIZE - 1);
            var isLastY = (tilePosition.y == TILE_SIZE - 1);
            if (!(isLastX && isLastY))
                string += ';';
        });

        return string;
    }

    static public function deserialize (parent: Object, position: ChunkVector2, string: String): WorldChunk {
        var chunkTilePosition = position.toTileVector2();

        var index = 0;
        var serializedTiles = string.split(';');
        var tileDataGrid = new FiniteGrid<WorldTileData>(TILE_SIZE, TILE_SIZE);
        for (serializedTile in serializedTiles) {
            var tileOffset = tileDataGrid.indexToPosition(index);
            var tilePosition = chunkTilePosition + tileOffset;
            var tileData = WorldTileData.deserialize(tilePosition, serializedTile);
            tileDataGrid.set(tileOffset, tileData);
            index++;
        }

        return new WorldChunk(parent, position, tileDataGrid, CreationType.DESERIALIZED);
    }

    //
    //
    //

    public function toString (): String {
        return
            '$position' + '\n' +
            '$creationType';
    }
}