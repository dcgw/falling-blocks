package net.noiseinstitute.game {
    import net.flashpunk.Entity;
    import net.flashpunk.FP;
    import net.flashpunk.graphics.Graphiclist;
    import net.flashpunk.graphics.Text;

    public class Message extends Entity {
        private var text:Text;
        private var outline1:Text;
        private var outline2:Text;
        private var outline3:Text;
        private var outline4:Text;

        private static const COLOUR_TICKS:int = 120;

        private var tick:int = 0;

        private static const SATURATION:Number = 1;
        private static const VALUE:Number = 1;

        public function Message() {
            text = new Text("PRESS\nSPACE");
            text.font = "font";
            text.size = 16;
            text.color = FP.getColorHSV(0, SATURATION, VALUE);

            outline1 = new Text("");
            outline2 = new Text("");
            outline3 = new Text("");
            outline4 = new Text("");
            outline1.text = outline2.text = outline3.text = outline4.text = text.text;
            outline1.font = outline2.font = outline3.font = outline4.font = text.font;
            outline1.size = outline2.size = outline3.size=  outline4.size = text.size;
            outline1.color = outline2.color = outline3.color = outline4.color = 0x000000;

            outline1.x = outline1.y = outline2.y = outline4.x = -1;
            outline2.x = outline3.x = outline3.y = outline4.y = 1;

            graphic = new Graphiclist(outline1, outline2, outline3, outline4, text);
        }

        override public function update():void {
            text.color = FP.getColorHSV((tick / COLOUR_TICKS) % 1, SATURATION, VALUE);
            ++tick;
        }
    }
}
