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

        public function render(target:BitmapData, x:Number, y:Number, shape:uint,
                playfieldX:Number, playfieldY:Number, camera:Point):void {
            var shapeDefinition:Vector.<Point> = Brick.shapes[shape];
            for each (var p:Point in shapeDefinition) {
                var rx:Number = playfieldX + (x + p.x) * Block.WIDTH - camera.x;
                var ry:Number = playfieldY + (y + p.y) * Block.HEIGHT - camera.y;
                Block.draw(target, shapeColours[shape], rx, ry);
            }
        }
    }
}
