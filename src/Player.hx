package;

import hxd.Res;
import world.vector2.WorldVector2;
import world.vector2.PixelVector2;
import h2d.Bitmap;

using extenders.TileExtender;

class Player {
    public var position(get, set): WorldVector2;
    public var speed: Int = 700;
    public var flipX(default, set) = false;
    
    private var leftHand: Bitmap;
    private var rightHand: Bitmap;
    public var body(default, null): Bitmap;
    private var head: Bitmap;

    public function new (scene: h2d.Scene, position: WorldVector2) {
    #if !parsing
        hxd.Res.initEmbed();

        leftHand  = new Bitmap(Res.parsed.player_green.toTile().scale(0.25).centerSelf());
        rightHand = new Bitmap(Res.parsed.player_pink .toTile().scale(0.25).centerSelf());
        body      = new Bitmap(Res.parsed.player_blue .toTile().scale(0.25).centerSelf());
        head      = new Bitmap(Res.parsed.player_red  .toTile().scale(0.25).centerSelf());
        scene.addChild(leftHand);
        scene.addChild(rightHand);
        scene.addChild(body);
        scene.addChild(head);

        this.position = position;
    #end
    }

    public function set_flipX (flipX: Bool): Bool {
        this.flipX = flipX;
        return flipX;
    }
    
    public function get_position (): WorldVector2 {
        return new WorldVector2(body.x, body.y);
    }

    public function set_position (newPosition: WorldVector2): WorldVector2 {
        body.x = newPosition.x;
        body.y = newPosition.y;

        leftHand.x = body.x - body.tile.width / 2 - leftHand.tile.width / 2;
        leftHand.y = body.y;
        rightHand.x = body.x + body.tile.width / 2 + rightHand.tile.width / 2;
        rightHand.y = body.y;
        head.x = body.x;
        head.y = body.y - body.tile.height / 2 - head.tile.height / 2;

        return newPosition;
    }

    public function toString (): String {
        return '
            Player
                worldPosition: $position
                pixelPosition ${position.toPixelVector2()}
                tilePosition: ${position.toTileVector2()}
                chunkPosition: ${position.toChunkVector2()}
                speed: $speed
        ';
    }
}