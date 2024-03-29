package net.noiseinstitute.game {
    import net.flashpunk.Engine;
    import net.flashpunk.FP;
    import net.flashpunk.utils.Input;
    import net.flashpunk.utils.Key;

    [SWF(width="640", height="480", frameRate="60", backgroundColor="000000")]
    public class Main extends Engine {
        //noinspection JSUnusedLocalSymbols
        [Embed(source="Font.ttf", embedAsCFF="false", fontFamily="font")]
        private static const FONT:Class;

        public static const WIDTH:int = 640;
        public static const HEIGHT:int = 480;

        public static const LOGIC_FPS:int = 60;

        public static const LEFT:String = "left";
        public static const RIGHT:String = "right";
        public static const ROTATE_LEFT:String = "rotate-left";
        public static const ROTATE_RIGHT:String = "rotate-right";
        public static const DOWN:String = "down";
        public static const DROP:String = "drop";
        public static const START:String = "start";

        public function Main () {
            super(WIDTH, HEIGHT, LOGIC_FPS, true);

            Input.define(LEFT, Key.LEFT);
            Input.define(RIGHT, Key.RIGHT);
            Input.define(ROTATE_LEFT, Key.X);
            Input.define(ROTATE_RIGHT, Key.V, Key.UP);
            Input.define(DOWN, Key.DOWN);
            Input.define(DROP, Key.C);
            Input.define(START, Key.ENTER, Key.SPACE, Key.P);

            FP.screen.color = 0x444444;
            // FP.console.enable();

            FP.world = new GameWorld();
        }
    }
}
