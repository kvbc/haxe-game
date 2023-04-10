package world.vector2;

import math.IntVector2;

@:forward
@:forward.new
@:transitive
@:build(macros.ForwardOpsMacro.build())
abstract ChunkVector2(IntVector2) from IntVector2 to IntVector2 {
    public function toTileVector2 (): TileVector2 {
        return this * world.WorldChunk.TILE_SIZE;
    }

    public function toPixelVector2 (): PixelVector2 {
        return toTileVector2().toPixelVector2();
    }
}