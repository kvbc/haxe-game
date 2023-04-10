package world;

import world.vector2.TileVector2;
import vendor.SimplexNoise;
import Logger.LogLevel;
import h2d.Object;
import utils.Measure;

enum Type {
    GRASS;
    WATER;
    SAND;
}

class WorldTileData {
    public static inline var PX_SIZE: Int = 128;

    public var position(default, null): TileVector2;
    public var type(default, null): Type;
    public var zIndex(default, null): Int = 0;

    //
    //
    //

    private function new (position: TileVector2, type: Type) {
        this.position = position;
        this.type = type;
    }

    //
    //
    //

    static public function generate (position: TileVector2): WorldTileData {
        var noise = SimplexNoise.simplexTiles(position.x / 100, position.y / 100, 1, 1, World.seed);
        // var noise = Math.random() * 2 - 1;
        var type: Type = null;
        if (noise < -0.5)
            type = WATER;
        else if (noise < 0)
            type = SAND;
        else
            type = GRASS;
        return new WorldTileData(position, type);
    }

    public function serialize (): String {
        if (type == WATER)
            return "0";
        if (type == GRASS)
            return "1";
        return "2";
    }

    static public function deserialize (position: TileVector2, string: String): WorldTileData {
        var type: Null<Type> = null;
        if (string == "0")
            type = WATER;
        else if (string == "1")
            type = GRASS;
        else if (string == "2")
            type = SAND;
        else
            Logger.log(ERROR);

        return new WorldTileData(position, type);
    }
}