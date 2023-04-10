package world;

import world.WorldDebugGrid;
import math.IntRect;
import utils.Grid;
import world.vector2.TileVector2;
import world.vector2.ChunkVector2;
import world.vector2.PixelVector2;
import world.vector2.WorldVector2;
import h2d.Bitmap;
import hxd.Perlin;
import world.WorldChunk;
import Logger.LogLevel;
import utils.Measure;
import h2d.Scene;
import h2d.col.Point;
import h2d.Object;
import hxd.Key;

private typedef SavedChunk = {
    position: ChunkVector2,
    serializedChunk: String
};

enum WorldEventKind {
    LOADED;
    CHUNKS_LOADED(chunks: Array<WorldChunk>);
    ANY_CHUNK_UNLOADED;
    UPDATE;
}

class World {
    static public inline var DEFAULT_CAMERA_ZOOM = 1;
    static public inline var MIN_CAMERA_ZOOM = 0.0001;
    static public inline var MAX_CAMERA_ZOOM = 5;
    static public inline var RENDER_DISTANCE = 2;

    static public var eventManager(get, never): event.EventManager<WorldEventKind>;
    static public var perlin(default, never) = new Perlin();
    static public var seed(default, never) = Math.random();
    static public var camera(default, null): WorldCamera;
    static public var scene(default, null): h2d.Scene;

    static private var eventDispatcher(default, never) = new event.EventDispatcher<WorldEventKind>();
    static private var name: String;
    static private var chunksObject: h2d.Object;
    static private var chunks = new Grid<ChunkVector2, WorldChunk>();
    static private var player: Player;

    static private var lastFPS: Int = cast hxd.Timer.fps();
    static private var lastFPSUpdateTimestamp: Float = haxe.Timer.stamp();

    static private var initialized: Bool = false;

    //
    //
    //

    static public function init (name: String) {
        Debug.assert(!initialized);
        initialized = true;

        Debug.assert(DEFAULT_CAMERA_ZOOM >= MIN_CAMERA_ZOOM);
        Debug.assert(DEFAULT_CAMERA_ZOOM <= MAX_CAMERA_ZOOM);
        
        WorldTilemap.init();

        World.name = name;

        scene = new Scene();
        camera = new WorldCamera(scene.camera);

        chunksObject = new h2d.Object(scene);
        player = new Player(scene, new WorldVector2(0, 0));
        WorldDebugGrid.init(scene);

        scene.camera.anchorX = 0.5;
        scene.camera.anchorY = 0.5;
        scene.camera.follow = player.body;
        camera.zoom = DEFAULT_CAMERA_ZOOM;

        // problem - console also scrolls
        hxd.Window.getInstance().addEventTarget((event: hxd.Event) -> {
            if (event.kind == EWheel) {
                var newZoom = camera.zoom - event.wheelDelta * 0.1;
                if (newZoom >= MIN_CAMERA_ZOOM)
                if (newZoom <= MAX_CAMERA_ZOOM) {
                    camera.zoom = newZoom;
                }
            }
        });

        var savedChunks = loadChunks().chunks;
        if (savedChunks.length > 0) {
            Logger.log("Loading chunks...");
            var measure = new Measure();
            var loadedChunks = [];
            for (savedChunk in savedChunks) {
                var chunk = WorldChunk.deserialize(chunksObject, savedChunk.position, savedChunk.serializedChunk);
                chunks[savedChunk.position] = chunk;
                loadedChunks.push(chunk);
            }
            eventDispatcher.dispatch(CHUNKS_LOADED(loadedChunks));
            measure.endLog("Chunks loaded!", INFO);
        }
        else {
            Logger.log('Save "$name" not found - no chunks to be loaded', WARN);
        }

        eventDispatcher.dispatch(LOADED);
    }

    /*
     *
     *
     *
     */

    static public function get_eventManager (): event.EventManager<WorldEventKind> {
        return eventDispatcher;
    }

    static public function getChunk (position: ChunkVector2): Null<WorldChunk> {
        return chunks[position];
    }

    static public function getTileData (tilePosition: TileVector2): Null<WorldTileData> {
        var chunkPosition = tilePosition.toChunkVector2();
        
        if (!chunks.exists(chunkPosition))
            return null;

        return chunks[chunkPosition].getTileData(tilePosition - chunkPosition.toTileVector2());
    }

    static private function getSavedChunk (savedChunks: Array<SavedChunk>, chunkPosition: ChunkVector2): Null<SavedChunk> {
        for (chunk in savedChunks) {
            if (chunk.position == chunkPosition) {
                return chunk;
            }
        }
        return null;
    }

    /*
     *
     *
     *
     */

    static public function onLoad (callback: () -> Void): Void {
        if (initialized)
            callback();
        else
            eventManager.addEventListener(LOADED, callback, true);
    }

    static public function update (delta: Float): Void {
        eventDispatcher.dispatch(UPDATE);

        {
            var timeNow = haxe.Timer.stamp();
            if (timeNow - lastFPSUpdateTimestamp >= 1.0) {
                lastFPS = cast hxd.Timer.fps();
                lastFPSUpdateTimestamp = timeNow;
            }
        }

        // 
        // 
        // 

        {
            var moveVector = new WorldVector2(0, 0);
            if (Key.isDown(Key.W)) moveVector.y = -1;
            if (Key.isDown(Key.S)) moveVector.y =  1;
            if (Key.isDown(Key.A)) moveVector.x = -1;
            if (Key.isDown(Key.D)) moveVector.x =  1;

            if (moveVector.x != 0)
                player.flipX = (moveVector.x < 0);

            player.position += moveVector * player.speed * delta;
        }

        //
        //
        //

        var playerChunkPosition = player.position.toChunkVector2();

        {
            var chunkRenderRect = IntRect.fromDimensions(
                playerChunkPosition.x - RENDER_DISTANCE,
                playerChunkPosition.y - RENDER_DISTANCE,
                RENDER_DISTANCE * 2 + 1,  
                RENDER_DISTANCE * 2 + 1
            );
            var chunksToRemove = [];
            chunks.forEach((chunk, _) -> {
                if (!chunkRenderRect.containsPoint(chunk.position))
                    chunksToRemove.push(chunk);
            });
            if (chunksToRemove.length > 0) {
                // saveChunks(chunksToRemove);
                for (chunk in chunksToRemove) {
                    chunk.destroy();
                    chunks.removePosition(chunk.position);
                }
                eventDispatcher.dispatch(ANY_CHUNK_UNLOADED);
            }
        }

        // 
        // 
        // 

        {
            var savedChunks: Null<Array<SavedChunk>> = null;
            var loadedChunks = [];

            for (ix in -RENDER_DISTANCE ... RENDER_DISTANCE + 1)
            for (iy in -RENDER_DISTANCE ... RENDER_DISTANCE + 1) {
                var chunkPosition = playerChunkPosition + new ChunkVector2(ix, iy);
                if (!chunks.exists(chunkPosition)) {
                    if (savedChunks == null)
                        savedChunks = loadChunks().chunks;

                    var savedChunk: Null<SavedChunk> = getSavedChunk(savedChunks, chunkPosition);
                    
                    var chunk: WorldChunk = if (savedChunk == null) {
                        WorldChunk.generate(chunksObject, chunkPosition);
                    }
                    else {
                        WorldChunk.deserialize(chunksObject, chunkPosition, savedChunk.serializedChunk);
                    }

                    chunks[chunkPosition] = chunk;
                    loadedChunks.push(chunk);
                }
            }
            
            if (loadedChunks.length > 0) {
                eventDispatcher.dispatch(CHUNKS_LOADED(loadedChunks));
            }
        }
    }

    /*
     *
     *
     *
     */

    static private function load (): Null<String> {
        return hxd.Save.load(null, name);
    }

    static private function save (serializedWorld: String): Void {
        hxd.Save.save(serializedWorld, name);
    }

    static private function loadChunks (): {
        serializedWorld: Null<String>,
        chunks: Array<SavedChunk>
    } {
        var serializedWorld = load();
        if (serializedWorld == null)
            return {
                serializedWorld: null,
                chunks: []
            }

        var savedChunks = new Array<SavedChunk>();

        for (line in serializedWorld.split('\n')) {
            var split = line.split(':');
            var positionX = Std.parseInt(split[0]);
            var positionY = Std.parseInt(split[1]);
            var serializedChunk = split[2];
            var position = new ChunkVector2(positionX, positionY);

            for (savedChunk in savedChunks)
                if (savedChunk.position == position)
                    savedChunks.remove(savedChunk);

            savedChunks.push({
                position: position,
                serializedChunk: serializedChunk
            });
        }

        return {
            serializedWorld: serializedWorld,
            chunks: savedChunks
        };
    }

    static private function saveChunks (chunksToSave: Array<WorldChunk>): Void {
        var measure = new Measure();
        
        var savedChunks = loadChunks();

        var saved = savedChunks.serializedWorld;
        var newSave = saved;

        for (chunk in chunksToSave) {
            var string = chunk.position.x + ':' + chunk.position.y + ':' + chunk.serialize();

            if (newSave == null)
                newSave = string;
            else {
                newSave += '\n' + string;
            }
        }

        save(newSave);

        measure.endLog('save chunks');
    }

    /*
     *
     *
     *
     */

     static public function toString (): String {
        var mouseScreenPosition = camera.getMouseScreenPosition();
        var mouseWorldPosition = camera.getMouseWorldPosition();
        return '
            Performance
                fps: ${lastFPS}
                vsync: ${hxd.Window.getInstance().vsync ? "ON" : "OFF"}
            $player
            $camera
            Mouse
                Screen
                    px: ${mouseScreenPosition}
                    tile: ${mouseScreenPosition.toTileVector2()}
                    chunk: ${mouseScreenPosition.toChunkVector2()}
                World
                    px: ${mouseWorldPosition}
                    tile: ${mouseWorldPosition.toTileVector2()}
                    chunk: ${mouseWorldPosition.toChunkVector2()}
        ';
    }
}