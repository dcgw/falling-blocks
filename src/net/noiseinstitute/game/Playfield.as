package net.noiseinstitute.game {
    import flash.geom.Point;
    import flash.media.Sound;

    import net.flashpunk.Entity;
    import net.noiseinstitute.basecode.Static;
    import net.noiseinstitute.basecode.VectorMath;

    public class Playfield extends Entity {
        [Embed(source="Explosion.mp3")]
        private static const EXPLOSION_SOUND:Class;

        [Embed(source="Clear.mp3")]
        private static const CLEAR_SOUND:Class;

        public static const WIDTH:int = COLUMNS * Block.WIDTH;
        public static const HEIGHT:int = ROWS * Block.HEIGHT;

        public static const ROWS:int = 20;
        public static const COLUMNS:int = 10;

        private static const EXPLOSION_CENTRE_Y_BIAS:Number = 0.6;
        private static const EXPLOSION_MAGNITUDE_MULTIPLIER:Number = 1.8;
        private static const EXPLOSION_PERTURB_RANDOMNESS:Number = 0.25;
        private static const EXPLOSION_ANGLE_RANDOMNESS:Number = 10;

        public var blocks:Vector.<Vector.<uint>> = new <Vector.<uint>>[];
        private var explodedBlocks:Vector.<Vector.<uint>> = new <Vector.<uint>>[];

        private var clearingState:Vector.<int> = new <int>[];

        public var onExplosion:Function;

        private var explodingBlocks:Vector.<Point> = new <Point>[];
        private var explodingBlocksCount:int = 0;
        private var explosionCentre:Point = new Point();

        private var explosionSound:Sound = Sound(new EXPLOSION_SOUND);
        private var clearSound:Sound = Sound(new CLEAR_SOUND);

        private var score:Score;

        public static const ADJACENT_POINTS:Vector.<Point> = new <Point>[
            new Point(0, -1), new Point(1, 0), new Point(0, 1), new Point(-1, 0)];

        public function Playfield(score:Score) {
            for (var y:int = 0; y < ROWS; ++y) {
                blocks[y] = new <uint>[];
                explodedBlocks[y] = new <uint>[];
                for (var x:int = 0; x < COLUMNS; ++x) {
                    blocks[y][x] = Block.NONE;
                    explodedBlocks[y][x] = Block.NONE;
                    explodingBlocks[x + y * COLUMNS] = new Point(-1, -1);
                }
                clearingState[y] = -1;
            }

            graphic = new PlayfieldGraphic(blocks);

            this.score = score;
        }

        public function explode(blockX:int, blockY:int):void {
            explosionSound.play();

            var i:int;

            for (i=0; i<explodingBlocks.length; ++i) {
                explodingBlocks[i].x = -1;
                explodingBlocks[i].y = -1;
            }

            explodingBlocksCount = 0;
            explosionCentre.x = 0;
            explosionCentre.y = 0;
            explodeRecurse(blockX, blockY);

            var magnitude:Number = 0;
            for (i=0; i<explodingBlocks.length && explodingBlocks[i].x != -1; ++i) {
                Static.point.x = explodingBlocks[i].x - explosionCentre.x;
                Static.point.y = explodingBlocks[i].y - explosionCentre.y;
                var m:Number = VectorMath.magnitude(Static.point);
                if (m > magnitude) {
                    magnitude = m;
                }
            }

            var unbiasedExplosionCentreY:Number = explosionCentre.y;
            explosionCentre.y += magnitude * EXPLOSION_CENTRE_Y_BIAS;

            magnitude *= EXPLOSION_MAGNITUDE_MULTIPLIER;

            if (onExplosion != null) {
                onExplosion(explosionCentre.x, unbiasedExplosionCentreY, magnitude);
            }

            var y:int;
            var x:int;
            for (y = 0; y < ROWS; ++y) {
                for (x = 0; x < COLUMNS; ++x) {
                    Static.point.x = x - explosionCentre.x;
                    Static.point.y = y - explosionCentre.y;
                    var distance:Number = VectorMath.magnitude(Static.point);
                    if (distance != 0) {
                        if (distance < magnitude) {
                            var perturb:Number = magnitude - distance;
                            perturb += perturb * (Math.random() * 2 - 1) * EXPLOSION_PERTURB_RANDOMNESS;
                            VectorMath.scaleInPlace(Static.point, perturb / distance);

                            var angleRandom:Number = (Math.random() * 2 - 1) * EXPLOSION_ANGLE_RANDOMNESS;
                            VectorMath.rotateInPlace(Static.point, angleRandom);

                            Static.point.x += x;
                            Static.point.y += y;

                            var newX:int = Math.round(Static.point.x);
                            var newY:int = Math.round(Static.point.y);

                            while (newX < 0 || newX >= COLUMNS) {
                                if (newX < 0) {
                                    newX = -newX;
                                }
                                if (newX >= COLUMNS) {
                                    newX = COLUMNS - (newX - COLUMNS) - 1;
                                }
                            }

                            if (newY >= ROWS) {
                                newY = ROWS - (newY - ROWS) - 1;
                            }

                            if (newY >= 0) {
                                explodedBlocks[newY][newX] = blocks[y][x];
                            }
                        } else {
                            explodedBlocks[y][x] = blocks[y][x];
                        }
                    }
                }
            }

            for (y = 0; y < ROWS; ++y) {
                for (x = 0; x < COLUMNS; ++x) {
                    blocks[y][x] = explodedBlocks[y][x];
                    explodedBlocks[y][x] = Block.NONE;
                }
            }
        }

        private function explodeRecurse(blockX:int, blockY:int):void {
            var i:int = 0;
            while (i<explodingBlocks.length && explodingBlocks[i].x != -1) {
                if (explodingBlocks[i].x == blockX && explodingBlocks[i].y == blockY) {
                    return;
                } else {
                    ++i;
                }
            }

            explosionCentre.x = (explosionCentre.x * explodingBlocksCount + blockX) / (explodingBlocksCount + 1);
            explosionCentre.y = (explosionCentre.y * explodingBlocksCount + blockY) / (explodingBlocksCount + 1);
            ++explodingBlocksCount;

            explodingBlocks[i].x = blockX;
            explodingBlocks[i].y = blockY;

            var colour:uint = blocks[blockY][blockX];
            for each (var adjacent:Point in ADJACENT_POINTS) {
                var adjacentX:int = blockX + adjacent.x;
                var adjacentY:int = blockY + adjacent.y;
                if (adjacentX >= 0 && adjacentX < COLUMNS && adjacentY >= 0 && adjacentY < ROWS
                        && blocks[adjacentY][adjacentX] == colour) {
                    explodeRecurse(adjacentX, adjacentY);
                }
            }
        }

        override public function update():void {
            var playClearSound:Boolean = false;

            var x:int;
            for (var y:int = ROWS-1; y >= 0; --y) {
                if (clearingState[y] < 0) {
                    clearingState[y] = 0;
                    for (x = 0; x < COLUMNS; ++x) {
                        if (blocks[y][x] == Block.NONE) {
                            clearingState[y] = -1;
                            break;
                        }
                    }
                    if (clearingState[y] == 0) {
                        playClearSound = true;
                    }
                } else if (clearingState[y] < COLUMNS/2) {
                    blocks[y][clearingState[y]] = Block.NONE;
                    blocks[y][COLUMNS - clearingState[y] - 1] = Block.NONE;
                    ++clearingState[y];
                } else {
                    for (var y2:int = y-1; y2 >= 0; --y2) {
                        for (x = 0; x < COLUMNS; ++x) {
                            blocks[y2+1][x] = blocks[y2][x];
                        }
                        clearingState[y2+1] = clearingState[y2];
                    }
                    for (x = 0; x < COLUMNS; ++x) {
                        blocks[0][x] = Block.NONE;
                    }
                    clearingState[0] = -1;
                }
            }

            if (playClearSound) {
                clearSound.play();
            }
        }

        public function clear ():void {
            for (var y:int = 0; y < ROWS; ++y) {
                for (var x:int = 0; x < COLUMNS; ++x) {
                    blocks[y][x] = Block.NONE;
                    explodedBlocks[y][x] = Block.NONE;
                    explodingBlocks[x + y * COLUMNS].x = -1;
                }
                clearingState[y] = -1;
            }
        }
    }
}
