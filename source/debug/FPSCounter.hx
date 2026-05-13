package debug;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.events.Event;

class FPSCounter extends Sprite
{
	var textField:TextField;
	var times:Array<Float> = [];
	var memPeak:Float = 0;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0xFFFFFF)
	{
		super();
		this.x = x;
		this.y = y;

		textField = new TextField();
		textField.defaultTextFormat = new TextFormat("_sans", 14, color, true);
		textField.width  = 200;
		textField.height = 70;
		textField.selectable = false;
		addChild(textField);

		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	function onEnterFrame(e:Event)
	{
		var now = haxe.Timer.stamp();
		times.push(now);
		while (times[0] < now - 1) times.shift();

		var mem = Math.round(openfl.system.System.totalMemory / 1024 / 1024 * 10) / 10;
		if (mem > memPeak) memPeak = mem;

		if (visible && ClientPrefs.data.showFPS)
		{
			textField.text = 'FPS: ${times.length}\nMEM: ${mem} MB (Peak: ${memPeak} MB)';
		}
		else
		{
			textField.text = '';
		}
	}
}
