package net.noiseinstitute.game {
    import flash.geom.Point;

    import net.flashpunk.Entity;
    import net.flashpunk.FP;
    import net.flashpunk.utils.Input;
    import net.noiseinstitute.basecode.Range;

    public class Brick extends Entity {
        private static const FALL_INTERVAL_TICKS_AT_START:int = 25;
        private static const TICKS_BETWEEN_SPEED_INCREASES:int = 600;

        private static const START_BLOCKS_ABOVE_PLAYFIELD:int = 2;

        public static const SHAPES:Vector.<Vector.<Point>> = new <Vector.<Point>>[
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


        public var onGameOver:Function;

        public var shape:uint;
        public var rotation:int;

        private var playfield:Playfield;
        private var score:Score;

        private var brickGraphic:BrickGraphic;

        private var gameTicks:int = 0;
        private var fallTicks:int = 0;

        private var dropping:Boolean = false;

        private var pointMultiplier:int = 0;
        private var pointValue:int = 0;

        public static const rotationMatrix:Vector.<Vector.<Point>> = new <Vector.<Point>>[
            new <Point>[new Point(1, 0), new Point(0, 1)],
            new <Point>[new Point(0, -1), new Point(1, 0)],
            new <Point>[new Point(-1, 0), new Point(0, -1)],
            new <Point>[new Point(0, 1), new Point(-1, 0)]];

        public function Brick(playfield:Playfield, score:Score) {
            this.playfield = playfield;
            this.score = score;
            brickGraphic = new BrickGraphic();
            active = false;
            visible = false;
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
                dropping = true;
            }

            var down:Boolean = Input.pressed(Main.DOWN);

            var settled:Boolean = false;

            var fallIntervalTicks:int = FALL_INTERVAL_TICKS_AT_START
                    - Math.floor(gameTicks / TICKS_BETWEEN_SPEED_INCREASES);

            if (dropping || down || ++fallTicks >= fallIntervalTicks) {
                if (collides(x, y+1, rotation)) {
                    settled = true;
                } else {
                    ++y;
                }
                fallTicks = 0;

                if (!dropping && !down) {
                    --pointValue;
                }
            }

            var shapeDefinition:Vector.<Point> = SHAPES[shape];
            var block:Point;
            var blockX:int;
            var blockY:int;

            var exploding:Boolean = explodes(x, y, rotation);

            if (settled || exploding) {
                for each (block in shapeDefinition) {
                    blockX = calculateBlockX(x, block, rotation);
                    blockY = calculateBlockY(y, block, rotation);
                    if (blockY < 0) {
                        if (settled) {
                            active = false;
                            if (onGameOver != null) {
                                onGameOver();
                            }
                        }
                    } else {
                        playfield.blocks[blockY][blockX] = SHAPE_COLOURS[shape];
                        playfield.points[blockY][blockX] = pointMultiplier * pointValue;
                    }
                }

                if (!exploding && active) {
                    score.points += pointMultiplier * pointValue;
                }
            }

            if (exploding) {
                for each (block in shapeDefinition) {
                    blockX = calculateBlockX(x, block, rotation);
                    blockY = calculateBlockY(y, block, rotation);
                    if (blockX >= 0 && blockX < Playfield.COLUMNS && blockY >= 0 && blockY < Playfield.ROWS) {
                        playfield.explode(blockX, blockY);
                        break;
                    }
                }
            }

            if (active && (settled || exploding)) {
                newBrick();
            }

            ++gameTicks;
        }

        public function newGame():void {
            gameTicks = 0;
            newBrick();
        }

        public function newBrick():void {
            active = true;
            visible = true;
            x = Math.floor(Playfield.COLUMNS * 0.5);
            y = -START_BLOCKS_ABOVE_PLAYFIELD;
            shape = Math.floor(Math.random() * 7);
            rotation = Math.floor(Math.random() * 4);
            dropping = false;
            fallTicks = 0;
            pointMultiplier = Math.floor(gameTicks / TICKS_BETWEEN_SPEED_INCREASES) + 1;
            pointValue = Playfield.ROWS + START_BLOCKS_ABOVE_PLAYFIELD;
        }

        private function collides(x:int, y:int, rotation:int):Boolean {
            var shapeDefinition:Vector.<Point> = SHAPES[shape];
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

        private function explodes (x:Number, y:Number, rotation:int):Boolean {
            var shapeDefinition:Vector.<Point> = SHAPES[shape];
            var colour:uint = SHAPE_COLOURS[shape];
            for each (var block:Point in shapeDefinition) {
                var blockX:int = calculateBlockX(x, block, rotation);
                var blockY:int = calculateBlockY(y, block, rotation);
                for each (var point:Point in Playfield.ADJACENT_POINTS) {
                    var adjacentX:int = blockX + point.x;
                    var adjacentY:int = blockY + point.y;
                    if (adjacentX >= 0 && adjacentX < Playfield.COLUMNS && adjacentY >= 0 && adjacentY < Playfield.ROWS
                            && playfield.blocks[adjacentY][adjacentX] == colour) {
                        return true;
                    }
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
