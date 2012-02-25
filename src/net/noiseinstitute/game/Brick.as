package net.noiseinstitute.game {
    import flash.geom.Point;

    import net.flashpunk.Entity;
    import net.flashpunk.FP;

    public class Brick extends Entity {
        public static const I:uint = 0;
        public static const J:uint = 1;
        public static const L:uint = 2;
        public static const O:uint = 3;
        public static const S:uint = 4;
        public static const T:uint = 5;
        public static const Z:uint = 6;

        public static const shapes:Vector.<Vector.<Point>> = new <Vector.<Point>>[
                new <Point>[new Point(0, -2), new Point(0, -1), new Point(0, 0), new Point(0, 1)],
                new <Point>[new Point(0, -1), new Point(0, 0), new Point(0, 1), new Point(-1, 1)],
                new <Point>[new Point(0, -1), new Point(0, 0), new Point(0, 1), new Point(1, 1)],
                new <Point>[new Point(0, 0), new Point(1, 0), new Point(0, 1), new Point(1, 1)],
                new <Point>[new Point(0, 0), new Point(1, 0), new Point(-1, 1), new Point(0, 1)],
                new <Point>[new Point(-1, 0), new Point(0, 0), new Point(1, 0), new Point(0, 1)],
                new <Point>[new Point(-1, 0), new Point(0, 0), new Point(0, 1), new Point(1, 1)]];

        public var shape:uint;

        private var playfield:Playfield;
        private var brickGraphic:BrickGraphic;

        private var ticks:int = 0;

        public function Brick(playfield:Playfield) {
            this.playfield = playfield;
            brickGraphic = new BrickGraphic();
        }

        override public function update():void {
            if (++ticks == 15) {
                ++y;
                ticks = 0;
            }
        }

        override public function render():void {
            var camera:Point = FP.point2;
            camera.x = world ? world.camera.x : FP.camera.x;
            camera.y = world ? world.camera.y : FP.camera.y;

            brickGraphic.render(renderTarget ? renderTarget : FP.buffer,
                    x, y, shape, playfield.x, playfield.y, camera);
        }
    }
}
