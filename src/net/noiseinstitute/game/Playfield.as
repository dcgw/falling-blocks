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
        private static const EXPLODED_POINTS_MULTIPLIER:Number = 0.5;

        public var blocks:Vector.<Vector.<uint>> = new <Vector.<uint>>[];
        private var explodedBlocks:Vector.<Vector.<uint>> = new <Vector.<uint>>[];

        public var points:Vector.<Vector.<int>> = new <Vector.<int>>[];
        public var explodedPoints:Vector.<Vector.<int>> = new <Vector.<int>>[];

        private var clearingPosition:Vector.<int> = new <int>[];
        private var clearingMultiplier:int = 0;

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

                points[y] = new <int>[];
                explodedPoints[y] = new <int>[];

                for (var x:int = 0; x < COLUMNS; ++x) {
                    blocks[y][x] = Block.NONE;
                    explodedBlocks[y][x] = Block.NONE;

                    points[y][x] = 0;
                    explodedPoints[y][x] = 0;

                    explodingBlocks[x + y * COLUMNS] = new Point(-1, -1);
                }

                clearingPosition[y] = -1;
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
                                explodedPoints[newY][newX] = points[y][x] * EXPLODED_POINTS_MULTIPLIER;
                            }
                        } else {
                            explodedBlocks[y][x] = blocks[y][x];
                            explodedPoints[y][x] = points[y][x];
                        }
                    }
                }
            }

            for (y = 0; y < ROWS; ++y) {
                for (x = 0; x < COLUMNS; ++x) {
                    blocks[y][x] = explodedBlocks[y][x];
                    explodedBlocks[y][x] = Block.NONE;

                    points[y][x] = explodedPoints[y][x];
                    explodedPoints[y][x] = 0;
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
                if (clearingPosition[y] < 0) {
                    clearingPosition[y] = 0;
                    for (x = 0; x < COLUMNS; ++x) {
                        if (blocks[y][x] == Block.NONE) {
                            clearingPosition[y] = -1;
                            break;
                        }
                    }
                    if (clearingPosition[y] == 0) {
                        ++clearingMultiplier;
                        playClearSound = true;
                    }
                } else if (clearingPosition[y] < COLUMNS/2) {
                    blocks[y][clearingPosition[y]] = Block.NONE;
                    blocks[y][COLUMNS - clearingPosition[y] - 1] = Block.NONE;

                    score.points += clearingMultiplier * points[y][clearingPosition[y]];
                    if (COLUMNS - clearingPosition[y] - 1 != clearingPosition[y]) {
                        score.points += clearingMultiplier
                                * points[y][COLUMNS - clearingPosition[y] - 1];
                    }

                    points[y][clearingPosition[y]] = 0;
                    points[y][COLUMNS - clearingPosition[y] - 1] = 0;

                    ++clearingPosition[y];
                } else {
                    --clearingMultiplier;

                    for (var y2:int = y-1; y2 >= 0; --y2) {
                        for (x = 0; x < COLUMNS; ++x) {
                            blocks[y2+1][x] = blocks[y2][x];
                            points[y2+1][x] = points[y2][x];
                        }
                        clearingPosition[y2+1] = clearingPosition[y2];
                    }
                    for (x = 0; x < COLUMNS; ++x) {
                        blocks[0][x] = Block.NONE;
                        points[0][x] = 0;
                    }
                    clearingPosition[0] = -1;
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

                    points[y][x] = 0;
                    explodedPoints[y][x] = 0;

                    explodingBlocks[x + y * COLUMNS].x = -1;
                }
                clearingPosition[y] = -1;
            }

            clearingMultiplier = 0;
        }
    }
}
