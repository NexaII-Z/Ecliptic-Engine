package mobile.backend;

import flixel.system.scaleModes.BaseScaleMode;

class MobileScaleMode extends BaseScaleMode
{
	public static var allowWideScreen(default, set):Bool = true;

	override function updateGameSize(Width:Int, Height:Int):Void {
		var ratio:Float = FlxG.width / FlxG.height;
		var realRatio:Float = Width / Height;
		var scaleY:Bool = realRatio < ratio;
		if (scaleY) { gameSize.x = Width; gameSize.y = Math.floor(gameSize.x / ratio); }
		else { gameSize.y = Height; gameSize.x = Math.floor(gameSize.y * ratio); }
	}

	override function updateGamePosition():Void { super.updateGamePosition(); }

	@:noCompletion private static function set_allowWideScreen(value:Bool):Bool {
		allowWideScreen = value;
		FlxG.scaleMode = new MobileScaleMode();
		return value;
	}
}
