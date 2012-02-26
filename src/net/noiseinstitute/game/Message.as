package net.noiseinstitute.game {
    import flashx.textLayout.formats.TextAlign;

    import net.flashpunk.Entity;
    import net.flashpunk.FP;
    import net.flashpunk.graphics.Graphiclist;
    import net.flashpunk.graphics.Text;

    public class Message extends Entity {
        private var textGraphic:Text;
        private var outline1:Text;
        private var outline2:Text;
        private var outline3:Text;
        private var outline4:Text;

        private static const COLOUR_TICKS:int = 120;

        private var tick:int = 0;

        private static const SATURATION:Number = 0.25;
        private static const VALUE:Number = 1;

        private static const MOVE_HEIGHT:Number = 280;

        private static const MOVE_TICKS:int = 180;

        public function Message() {
            x = Main.WIDTH * 0.5;

            textGraphic = new Text("");
            textGraphic.font = "font";
            textGraphic.size = 24;
            textGraphic.color = FP.getColorHSV(0, SATURATION, VALUE);
            textGraphic.align = TextAlign.CENTER;

            outline1 = new Text("");
            outline2 = new Text("");
            outline3 = new Text("");
            outline4 = new Text("");
            outline1.font = outline2.font = outline3.font = outline4.font = textGraphic.font;
            outline1.size = outline2.size = outline3.size=  outline4.size = textGraphic.size;
            outline1.color = outline2.color = outline3.color = outline4.color = 0x000000;
            outline1.align = outline2.align = outline3.align = outline4.align = textGraphic.align;

            outline1.x = outline3.y = -2;
            outline2.y = outline4.x = 2;

            graphic = new Graphiclist(outline1, outline2, outline3, outline4, textGraphic);
        }

        public function set text(text:String):void {
            textGraphic.width = textGraphic.height = outline1.width = outline1.height = outline2.width
                    = outline2.height = outline3.width = outline3.height = outline4.width = outline4.height = 0;
            textGraphic.text = outline1.text = outline2.text = outline3.text = outline4.text = text;
            textGraphic.centerOrigin();
            outline1.originX = outline2.originX = outline3.originX = outline4.originX = textGraphic.originX;
            outline1.originY = outline2.originY = outline3.originY = outline4.originY = textGraphic.originY;
        }

        override public function update():void {
            textGraphic.color = FP.getColorHSV((tick / COLOUR_TICKS) % 1, SATURATION, VALUE);

            var moveHeight:Number = MOVE_HEIGHT - textGraphic.height;

            y = (Main.HEIGHT + Math.sin(tick * Math.PI * 2 / MOVE_TICKS) * MOVE_HEIGHT) * 0.5;

            ++tick;
        }
    }
}
