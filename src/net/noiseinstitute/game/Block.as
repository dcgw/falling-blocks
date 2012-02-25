package net.noiseinstitute.game {
    import flash.display.BitmapData;

    import net.noiseinstitute.basecode.Static;

    public class Block {
        public static const WIDTH:int = 20;
        public static const HEIGHT:int = 20;

        public static const NONE:uint = 0;
        public static const RED:uint = 1;
        public static const ORANGE:uint = 2;
        public static const YELLOW:uint = 3;
        public static const GREEN:uint = 4;
        public static const CYAN:uint = 5;
        public static const BLUE:uint = 6;
        public static const PURPLE:uint = 7;

        private static const colours:Vector.<uint> = new <uint>[
                0x000000,
                0xff0000,
                0xff8800,
                0xffff00,
                0x00ff00,
                0x00ffff,
                0x0000ff,
                0xff00ff];

        public static function draw(target:BitmapData, block:uint, x:Number, y:Number):void {
            if (block != NONE) {
                Static.rect.x = x;
                Static.rect.y = y;
                Static.rect.width = WIDTH;
                Static.rect.height = HEIGHT;
                target.fillRect(Static.rect, colours[block]);
            }
        }
    }
}
