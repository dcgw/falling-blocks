package net.noiseinstitute.game {
    import flash.display.BitmapData;
    import flash.geom.Point;

    import net.flashpunk.Graphic;

    public class PlayfieldGraphic extends Graphic {
        private var blocks:Vector.<Vector.<uint>>;

        public function PlayfieldGraphic(blocks:Vector.<Vector.<uint>>) {
            this.blocks = blocks;
        }

        override public function render(target:BitmapData, point:Point, camera:Point):void {
            for (var y:int = 0; y < blocks.length; ++y) {
                var row:Vector.<uint> = blocks[y];
                for (var x:int = 0; x < row.length; ++x) {
                    var block:uint = row[x];
                    Block.draw(target, block, point.x - camera.x + x * Block.WIDTH, point.y - camera.y + y * Block.HEIGHT);
                }
            }
        }
    }
}
