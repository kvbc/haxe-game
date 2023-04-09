package world;

import world.vector2.TileVector2;
import world.vector2.ChunkVector2;
import utils.FiniteGrid;
import utils.Direction4;
import event.EventManager;
import event.EventDispatcher;
import utils.Measure;
import h2d.Object;
import haxe.ds.Vector;

enum WorldChunkEventKind {
    BORDER_CHUNKS_LOADED(borderChunks: Map<Direction4, WorldChunk>);
}

private enum CreationType {
    GENERATED;
    DESERIALIZED;
}

class WorldChunk {
    public static inline var TILE_SIZE: Int = 16;
    public static inline var TILE_RENDERS_PER_FRAME = 1;

    private var object: h2d.Object;
    private var creationType: CreationType;
    private var eventDispatcher = new EventDispatcher<WorldChunkEventKind>();

    public var position(default, null): ChunkVector2;
    public var tileDataGrid(default, null): FiniteGrid<WorldTileData>;
    public var tileObjectsGrid(default, null): FiniteGrid<WorldTileObject>;
    public var eventManager(get, never): EventManager<WorldChunkEventKind>;

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

        this.position = position;
        this.creationType = creationType;

        this.tileDataGrid = tileDataGrid;
        tileObjectsGrid = new FiniteGrid<WorldTileObject>(TILE_SIZE, TILE_SIZE);

        World.eventManager.addListener(event -> {
            switch (event) {
                case CHUNKS_LOADED(chunks):
                    var borderChunks = new Map<Direction4, WorldChunk>();
                    for (chunk in chunks) {
                        for (dir in Direction4.getAll()) {
                            var borderChunkPosition = this.position + dir.toIntVector2();
                            if (chunk.position == borderChunkPosition) {
                                borderChunks[dir] = chunk;
                            }
                        }
                    }
                    if (borderChunks.keys().hasNext()) {
                        eventDispatcher.dispatch(BORDER_CHUNKS_LOADED(borderChunks));
                    }
                    if (!chunks.contains(this)) {
                        return;
                    }
                case _:
                    return;
            }

            function whenWorldLoaded () {
                tileDataGrid.forEach((data: WorldTileData, position: TileVector2, _) -> {
                    tileObjectsGrid.set(position, new WorldTileObject(null, this, data));
                });

                var renderIndex: Int = 0;
                World.eventManager.addListener(event -> {
                    if (event != UPDATE)
                        return;
                    for (i in 0 ... TILE_RENDERS_PER_FRAME) {
                        if (!tileObjectsGrid.isValidIndex(renderIndex))
                            break;
                        object.addChild(
                            tileObjectsGrid.idxGet(renderIndex++)
                        );
                    }
                });
            }

            if (World.instance == null) {
                World.eventManager.addListener(event -> {
                    if (event == LOADED)
                        whenWorldLoaded();
                });
            }
            else {
                whenWorldLoaded();
            }
        });
    }

    //
    //
    //

    public function get_eventManager () {
        return this.eventDispatcher;
    }

    public function destroy (): Void {
        object.remove();
    }

    public function tilePositionToOffset (tilePosition: TileVector2): TileVector2 {
        var chunkTilePosition = this.position.toTileVector2();
        return tilePosition - chunkTilePosition;
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