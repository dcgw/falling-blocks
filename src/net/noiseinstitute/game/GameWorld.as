package net.noiseinstitute.game {
    import net.flashpunk.World;

    public class GameWorld extends World {
        public function GameWorld() {
            var playfield:Playfield = new Playfield();
            playfield.x = Math.floor((Main.WIDTH - Playfield.WIDTH) * 0.5);
            playfield.y = Math.floor((Main.HEIGHT - Playfield.HEIGHT) * 0.5);
            add(playfield);

            var brick:Brick = new Brick(playfield);
            brick.newBrick();
            add(brick);
        }
    }
}
