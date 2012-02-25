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
                rotation:int, playfieldX:Number, playfieldY:Number, camera:Point):void {
            var shapeDefinition:Vector.<Point> = Brick.shapes[shape];
            for each (var p:Point in shapeDefinition) {
                var blockX:int = Brick.calculateBlockX(x, p, rotation);
                var blockY:int = Brick.calculateBlockY(y, p, rotation);
                var renderX:Number = playfieldX + blockX * Block.WIDTH - camera.x;
                var renderY:Number = playfieldY + blockY * Block.HEIGHT - camera.y;
                Block.draw(target, shapeColours[shape], renderX, renderY);
            }
        }
    }
}
