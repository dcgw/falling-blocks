package net.noiseinstitute.game {
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;

    import net.flashpunk.FP;
    import net.flashpunk.World;
    import net.flashpunk.graphics.Image;
    import net.flashpunk.utils.Input;
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

        private var brick:Brick;
        private var playfield:Playfield = new Playfield();

        private var message:Message = new Message();

        private var paused:Boolean = false;

        public function GameWorld() {
            musicStartChannel = musicStart.play();
            musicStartChannel.soundTransform = new SoundTransform(MUSIC_VOLUME);
            musicChannel = music.play(0, int.MAX_VALUE);
            musicChannel.soundTransform = new SoundTransform(0);

            playfield.x = Math.floor((Main.WIDTH - Playfield.WIDTH) * 0.5);
            playfield.y = Math.floor((Main.HEIGHT - Playfield.HEIGHT) * 0.5);
            add(playfield);

            brick = new Brick(playfield);
            brick.onGameOver = onGameOver;
            add(brick);

            for (var i:int = 0; i<MAX_EXPLOSIONS; ++i) {
                explosions[i] = new Explosion();
                addGraphic(explosions[i]);
            }

            playfield.onExplosion = onExplosion;

            addGraphic(new Image(FRAME_IMAGE));

            message.text = "CLICK\nHERE";
            add(message);
        }

        private function onExplosion(x:int, y:int, magnitude:Number):void {
            x = playfield.x + x * Block.WIDTH;
            y = playfield.y + y * Block.HEIGHT;
            magnitude *= Block.WIDTH;

            explosions[nextExplosion].start(x, y, magnitude);
            nextExplosion = Range.wrap(nextExplosion+1, 0, MAX_EXPLOSIONS-1);
        }

        private function onGameOver():void {
            message.text = "GAME\nOVER";
        }

        override public function begin():void {
            FP.stage.addEventListener(MouseEvent.MOUSE_DOWN, onFocus);
            FP.stage.addEventListener(Event.ACTIVATE, onFocus);
            FP.stage.addEventListener(Event.DEACTIVATE, onBlur);
        }

        private function onBlur(event:Event):void {
            if (brick.active) {
                pause();
            }
            message.text = "CLICK\nHERE";
        }

        private function onFocus(event:Event):void {
            if (paused) {
                message.text = "PAUSED";
            } else {
                message.text = "PRESS\nSPACE";
            }
        }

        private function pause():void {
            paused = true;
            brick.active = brick.visible = false;
            playfield.active = playfield.visible = false;
            message.text = "PAUSED";
        }

        private function unpause():void {
            paused = false;
            brick.active = brick.visible = true;
            playfield.active = playfield.visible = true;
            message.text = "";
        }

        override public function update():void {
            if (musicChannel.soundTransform.volume == 0 && musicStartChannel.position >= music.length * 0.5) {
                var soundTransform:SoundTransform = musicStartChannel.soundTransform;
                musicStartChannel.soundTransform = musicChannel.soundTransform;
                musicChannel.soundTransform = soundTransform;
            }

            if (Input.pressed(Main.START)) {
                if (brick.active) {
                    pause();
                } else if (paused) {
                    unpause();
                } else {
                    message.text = "";
                    playfield.clear();
                    brick.newBrick();
                }
            }

            super.update();
        }
    }
}
