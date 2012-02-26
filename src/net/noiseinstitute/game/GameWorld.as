package net.noiseinstitute.game {
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;

    import net.flashpunk.World;
    import net.flashpunk.graphics.Image;
    import net.noiseinstitute.basecode.Range;

    public class GameWorld extends World {
        private static const MAX_EXPLOSIONS:int = 4;

        private static const MUSIC_VOLUME:Number = 0.7;

        [Embed(source="MusicStart.mp3")]
        private static const MUSIC_START:Class;

        [Embed(source="Music.mp3")]
        private static const MUSIC:Class;

        [Embed(source="Frame.png")]
        private static const FRAME_IMAGE:Class;

        private var musicStart:Sound = Sound(new MUSIC_START);
        private var music:Sound = Sound(new MUSIC);

        private var musicStartChannel:SoundChannel;
        private var musicChannel:SoundChannel;

        private var explosions:Vector.<Explosion> = new <Explosion>[];
        private var nextExplosion:int = 0;

        private var playfield:Playfield = new Playfield();

        public function GameWorld() {
            musicStartChannel = musicStart.play();
            musicStartChannel.soundTransform = new SoundTransform(MUSIC_VOLUME);
            musicChannel = music.play(0, int.MAX_VALUE);
            musicChannel.soundTransform = new SoundTransform(0);

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

        override public function update():void {
            if (musicChannel.soundTransform.volume == 0 && musicStartChannel.position >= music.length * 0.5) {
                var soundTransform:SoundTransform = musicStartChannel.soundTransform;
                musicStartChannel.soundTransform = musicChannel.soundTransform;
                musicChannel.soundTransform = soundTransform;
            }

            super.update();
        }
    }
}
