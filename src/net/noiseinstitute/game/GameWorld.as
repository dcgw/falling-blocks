package net.noiseinstitute.game {
    import net.flashpunk.World;
    import net.flashpunk.graphics.Image;
    import net.noiseinstitute.basecode.Range;

    public class GameWorld extends World {
        private static const MAX_EXPLOSIONS:int = 4;

        [Embed(source="Frame.png")]
        private static const FRAME_IMAGE:Class;

        private var explosions:Vector.<Explosion> = new <Explosion>[];
        private var nextExplosion:int = 0;

        private var playfield:Playfield = new Playfield();

        public function GameWorld() {
            playfield.x = Math.floor((Main.WIDTH - Playfield.WIDTH) * 0.5);
            playfield.y = Math.floor((Main.HEIGHT - Playfield.HEIGHT) * 0.5);
            add(playfield);

            var brick:Brick = new Brick(playfield);
            brick.newBrick();
            add(brick);

            for (var i:int = 0; i<MAX_EXPLOSIONS; ++i) {
                explosions[i] = new Explosion();
                addGraphic(explosions[i]);
            }

            playfield.onExplosion = onExplosion;

            addGraphic(new Image(FRAME_IMAGE));
        }

        private function onExplosion(x:int, y:int, magnitude:Number):void {
            x = playfield.x + x * Block.WIDTH;
            y = playfield.y + y * Block.HEIGHT;
            magnitude *= Block.WIDTH;

            explosions[nextExplosion].start(x, y, magnitude);
            nextExplosion = Range.wrap(nextExplosion+1, 0, MAX_EXPLOSIONS-1);
        }
    }
}
