package net.noiseinstitute.game {
    import net.flashpunk.Entity;

    public class Playfield extends Entity {
        private static const ROWS:int = 20;
        private static const COLUMNS:int = 10;

        private var blocks:Vector.<Vector.<uint>> = new <Vector.<uint>>[];

        public function Playfield() {
            for (var y:int = 0; y < ROWS; ++y) {
                blocks[y] = new <uint>[];
                for (var x:int = 0; x < COLUMNS; ++x) {
                    blocks[y][x] = Block.NONE;
                }
            }

            graphic = new PlayfieldGraphic(blocks);
        }
    }
}
