package;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;

class SubtitleText extends FlxText
{
    public var formats:Array<FlxTextFormatMarkerPair> = [];

    public function new() {
        super(10, FlxG.height * 0.75, FlxG.width - 20, '', 32);
        borderColor = 0xFF000000;
        borderStyle = OUTLINE;
        borderQuality = 1;
        borderSize = 2;
        alignment = CENTER;
        font = Paths.font('vcr.ttf');

        // color formats
        add_format(FlxColor.BLACK, null, null, '#BLACK');
        add_format(FlxColor.GRAY, null, null, '#GRAY');
        add_format(FlxColor.WHITE, null, null, '#WHITE');
        add_format(FlxColor.GREEN, null, null, '#GREEN');
        add_format(FlxColor.BLUE, null, null, '#BLUE');
        add_format(FlxColor.BROWN, null, null, '#BROWN');
        add_format(FlxColor.LIME, null, null, '#LIME');
        add_format(FlxColor.CYAN, null, null, '#CYAN');
        add_format(FlxColor.RED, null, null, '#RED');
        add_format(FlxColor.PINK, null, null, '#PINK');
        add_format(FlxColor.PURPLE, null, null, '#PURPLE');
        add_format(FlxColor.MAGENTA, null, null, '#MAGENTA');
        add_format(FlxColor.ORANGE, null, null, '#ORANGE');
        add_format(FlxColor.YELLOW, null, null, '#YELLOW');

        // font style formats
        add_format(null, true, null, '$$BOLD');
        add_format(null, null, true, '$$ITALIC');
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        if(text == '')
            visible = false;
        else
            visible = true;
    }

    public function setSubtitles(newText:String)
    {
        applyMarkup(newText, formats);
    }

    private function add_format(?color:FlxColor, ?bold:Bool, ?italic:Bool, name:String)
    {
        var form = new FlxTextFormat(color, bold, italic, 0x000000);
        var format = new FlxTextFormatMarkerPair(form, '<$name>');
        formats.push(format);
    }
}