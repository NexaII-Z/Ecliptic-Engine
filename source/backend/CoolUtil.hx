package backend;

class CoolUtil
{
	public static function boundTo(value:Float, min:Float, max:Float):Float
		return Math.max(min, Math.min(max, value));

	public static function smoothLerp(from:Float, to:Float, elapsed:Float, speed:Float):Float
		return from + (to - from) * (1 - Math.pow(Math.exp(-1), elapsed * speed));

	public static function coolTextFile(path:String):Array<String> {
		var daList:Array<String> = [];
		var text = Paths.getText(path);
		if (text != null) daList = text.split('\n');
		while (daList.length > 0 && daList[daList.length - 1] == '') daList.pop();
		return daList;
	}

	public static function getSavePath():String return 'ecliptic';

	public static function colorFromString(color:String):FlxColor {
		var hideChars = ~/[\t\n\r]/;
		var colorStr  = hideChars.split(color).join('').trim();
		var colorInt:Null<FlxColor> = null;
		if (colorStr != null && colorStr != '') {
			try { colorInt = cast FlxColor.fromString(colorStr); }
			catch (e:Dynamic) { trace('[ECLIPTIC] Invalid color: $colorStr'); }
		}
		return colorInt != null ? colorInt : FlxColor.WHITE;
	}

	public static function browserLoad(site:String) {
		#if linux Sys.command('/usr/bin/xdg-open', [site]);
		#elseif windows Sys.command('start', [site]);
		#elseif mac Sys.command('open', [site]);
		#else lime.app.Application.current.openURL(site); #end
	}
}
