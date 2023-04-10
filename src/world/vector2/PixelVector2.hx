package world.vector2;

import math.IntVector2;

@:forward
@:forward.new
@:transitive
@:build(macros.ForwardOpsMacro.build())
abstract PixelVector2(IntVector2) from IntVector2 to IntVector2 {
    public function toTileVector2 (): TileVector2 {
        return this / world.WorldTileData.PX_SIZE;
    }

    public function toChunkVector2 (): ChunkVector2 {
        return toTileVector2().toChunkVector2();
    }
}