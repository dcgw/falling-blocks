package net.noiseinstitute.game {
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.geom.Point;

    import net.flashpunk.Graphic;

    public class Explosion extends Graphic {
        private static const FADE_TICKS:int = 15;
        private static const GROWTH_PER_TICK:Number = 2;

        private var centreX:Number = 0;
        private var centreY:Number = 0;
        private var tick:int = -1;
        private var magnitude:Number = 0;

        private var sprite:Sprite = new Sprite();

        public function Explosion() {
            active = true;
        }

        public function start(x:Number, y:Number, magnitude:Number):void {
            tick = 0;
            this.centreX = x;
            this.centreY = y;
            this.magnitude = magnitude;
        }

        override public function update():void {
            if (tick >= 0) {
                ++tick;
            }
        }

        override public function render(target:BitmapData, point:Point, camera:Point):void {
            if (tick < 0 || tick > FADE_TICKS) {
                return;
            }

            var graphics:Graphics = sprite.graphics;
            graphics.clear();
            graphics.beginFill(0xffffff, 1 - (tick / FADE_TICKS));
            graphics.drawCircle(centreX, centreY, magnitude + GROWTH_PER_TICK*tick);
            graphics.endFill();

            target.draw(sprite, null, null, BlendMode.ADD, null, true);
        }
    }
}
