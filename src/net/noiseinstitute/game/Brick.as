package net.noiseinstitute.game {
    import flash.geom.Point;

    import net.flashpunk.Entity;
    import net.flashpunk.FP;
    import net.flashpunk.utils.Input;
    import net.noiseinstitute.basecode.Range;

    public class Brick extends Entity {
        private static const FALL_INTERVAL_TICKS:int = 15;

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

        public static const SHAPE_COLOURS:Vector.<uint> = new <uint>[
                Block.RED,
                Block.ORANGE,
                Block.YELLOW,
                Block.GREEN,
                Block.CYAN,
                Block.BLUE,
                Block.PURPLE];

        public var shape:uint;
        public var rotation:int;

        private var playfield:Playfield;
        private var brickGraphic:BrickGraphic;

        private var ticks:int = 0;

        public static const rotationMatrix:Vector.<Vector.<Point>> = new <Vector.<Point>>[
            new <Point>[new Point(1, 0), new Point(0, 1)],
            new <Point>[new Point(0, -1), new Point(1, 0)],
            new <Point>[new Point(-1, 0), new Point(0, -1)],
            new <Point>[new Point(0, 1), new Point(-1, 0)]];

        public function Brick(playfield:Playfield) {
            this.playfield = playfield;
            brickGraphic = new BrickGraphic();
        }

        override public function update():void {
            if (Input.pressed(Main.LEFT) && !Input.pressed(Main.RIGHT)) {
                if (!collides(x-1, y, rotation)) {
                    --x;
                }
            } else if (Input.pressed(Main.RIGHT)) {
                if (!collides(x+1, y, rotation)) {
                    ++x;
                }
            }

            var newRotation:int = -1;
            if (Input.pressed(Main.ROTATE_LEFT) && !Input.pressed(Main.ROTATE_RIGHT)) {
                newRotation = Range.wrap(rotation - 1, 0, 3);
            } else if (Input.pressed(Main.ROTATE_RIGHT)) {
                newRotation = Range.wrap(rotation + 1, 0, 3);
            }

            if (newRotation != -1) {
                if (!collides(x, y, newRotation)) {
                    rotation = newRotation;
                } else if (!collides(x-1, y, newRotation)) {
                    rotation = newRotation;
                    --x;
                } else if (!collides(x+1, y, newRotation)) {
                    rotation = newRotation;
                    ++x;
                }
            }

            if (Input.pressed(Main.DROP)) {
                ticks = FALL_INTERVAL_TICKS - 1;
                while (!collides(x, y+1, rotation)) {
                    ++y;
                }
            }

            if (Input.pressed(Main.DOWN) || ++ticks == FALL_INTERVAL_TICKS) {
                if (collides(x, y+1, rotation)) {
                    var shapeDefinition:Vector.<Point> = shapes[shape];
                    for each (var block:Point in shapeDefinition) {
                        var blockX:int = calculateBlockX(x, block, rotation);
                        var blockY:int = calculateBlockY(y, block, rotation);
                        playfield.blocks[blockY][blockX] = SHAPE_COLOURS[shape];
                    }

                    newBrick();
                } else {
                    ++y;
                }
                ticks = 0;
            }
        }

        public function newBrick():void {
            x = Math.floor(Playfield.COLUMNS * 0.5);
            y = -2;
            shape = Math.floor(Math.random() * 7);
            rotation = Math.floor(Math.random() * 4);
        }

        private function collides(x:int, y:int, rotation:int):Boolean {
            var shapeDefinition:Vector.<Point> = shapes[shape];
            for each (var block:Point in shapeDefinition) {
                var blockX:int = calculateBlockX(x, block, rotation);
                var blockY:int = calculateBlockY(y, block, rotation);
                if (blockX >= Playfield.COLUMNS
                        || blockX < 0
                        || blockY >= Playfield.ROWS
                        || (blockY >= 0 && playfield.blocks[blockY][blockX] != Block.NONE)) {
                    return true;
                }
            }

            return false;
        }

        public static function calculateBlockX (brickX:int, block:Point, rotation:int):int {
            return brickX + (block.x * Brick.rotationMatrix[rotation][0].x) + (block.y * rotationMatrix[rotation][0].y);
        }

        public static function calculateBlockY (brickY:int, block:Point, rotation:int):int {
            return brickY + (block.x * Brick.rotationMatrix[rotation][1].x) + (block.y * rotationMatrix[rotation][1].y);
        }

        override public function render():void {
            var camera:Point = FP.point2;
            camera.x = world ? world.camera.x : FP.camera.x;
            camera.y = world ? world.camera.y : FP.camera.y;

            brickGraphic.render(renderTarget ? renderTarget : FP.buffer,
                    x, y, shape, rotation, playfield.x, playfield.y, camera);
        }
    }
}
