package backend;

class CoolUtil
{
	public static function boundTo(value:Float, min:Float, max:Float):Float
		return Math.max(min, Math.min(max, value));

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		var text = Paths.getText(path);
		if (text != null)
			daList = text.split('\n');
		while (daList.length > 0 && daList[daList.length - 1] == '')
			daList.pop();
		return daList;
	}

	public static function browserLoad(site:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#elseif windows
		Sys.command('start', [site]);
		#elseif mac
		Sys.command('open', [site]);
		#else
		lime.ui.Gamepad;
		lime.app.Application.current.openURL(site);
		#end
	}

	// Lerp that feels smooth on any framerate
	public static function smoothLerp(from:Float, to:Float, elapsed:Float, speed:Float):Float
		return from + (to - from) * (1 - Math.pow(Math.exp(-1), elapsed * speed));
}
