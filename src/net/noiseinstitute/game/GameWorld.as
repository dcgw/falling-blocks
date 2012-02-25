package net.noiseinstitute.game {
    import net.flashpunk.World;

    public class GameWorld extends World {
        public function GameWorld() {
            var playfield:Playfield = new Playfield();
            add(playfield);

            var brick:Brick = new Brick(playfield);
            brick.x = brick.y = 3;
            brick.shape = Brick.T;
            add(brick);
        }
    }
}
