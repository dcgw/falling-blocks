package net.noiseinstitute.game {
    import flashx.textLayout.formats.TextAlign;

    import net.flashpunk.Entity;
    import net.flashpunk.graphics.Text;

    public class Score extends Entity {
        [Embed(source = "Score.ttf", embedAsCFF="false", fontFamily = "score")]
        private static const FONT:Class;

        public var points:Number = 0;

        private var text:Text;

        public function Score() {
            text = new Text("");
            text.font = "score";
            text.size = 16;
            text.color = 0xffffff;
            text.align = TextAlign.RIGHT;
            text.width = 72;

            graphic = text;
        }

        override public function update():void {
            text.text = points.toString();
        }
    }
}
