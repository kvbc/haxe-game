package world.vector2;

import math.Vector2;

@:forward
@:forward.new
@:build(macros.ForwardOpsMacro.build("WorldVector2", "math.Vector2"))
@:build(macros.ForwardOpsMacro.build("WorldVector2", "hxmath.math.Vector2"))
abstract WorldVector2(Vector2) from Vector2 to Vector2 {
    public function toPixelVector2 (): PixelVector2 {
        return this.toIntVector2();
    }

    public function toTileVector2 (): TileVector2 {
        return toPixelVector2().toTileVector2();
    }

    public function toChunkVector2 (): ChunkVector2 {
        return toTileVector2().toChunkVector2();
    }
}