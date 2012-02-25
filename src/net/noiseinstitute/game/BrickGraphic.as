package net.noiseinstitute.game {
    import flash.display.BitmapData;
    import flash.geom.Point;

    public class BrickGraphic {
        public static const shapeColours:Vector.<uint> = new <uint>[
                Block.RED,
                Block.ORANGE,
                Block.YELLOW,
                Block.GREEN,
                Block.CYAN,
                Block.BLUE,
                Block.PURPLE];

        public static const rotationMatrix:Vector.<Vector.<Point>> = new <Vector.<Point>>[
                new <Point>[new Point(1, 0), new Point(0, 1)],
                new <Point>[new Point(0, -1), new Point(1, 0)],
                new <Point>[new Point(-1, 0), new Point(0, -1)],
                new <Point>[new Point(0, 1), new Point(-1, 0)]];

        public function render(target:BitmapData, x:Number, y:Number, shape:uint,
                rotation:uint, playfieldX:Number, playfieldY:Number, camera:Point):void {
            var shapeDefinition:Vector.<Point> = Brick.shapes[shape];
            for each (var p:Point in shapeDefinition) {
                var rx:Number = playfieldX + (x + (p.x * rotationMatrix[rotation][0].x) + (p.y * rotationMatrix[rotation][0].y)) * Block.WIDTH - camera.x;
                var ry:Number = playfieldY + (y + (p.x * rotationMatrix[rotation][1].x) + (p.y * rotationMatrix[rotation][1].y)) * Block.HEIGHT - camera.y;
                Block.draw(target, shapeColours[shape], rx, ry);
            }
        }
    }
}
