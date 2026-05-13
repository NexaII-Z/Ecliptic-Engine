package backend;

import flixel.addons.transition.FlxTransitionableState;

class CustomFadeTransition extends FlxSubState
{
	public static var finishCallback:Void->Void;

	var isTransIn:Bool;
	var duration:Float;
	var elapsed:Float = 0;
	var overlay:FlxSprite;

	public function new(duration:Float, isTransIn:Bool)
	{
		super();
		this.duration  = duration;
		this.isTransIn = isTransIn;
	}

	override function create()
	{
		super.create();
		overlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		overlay.scrollFactor.set();
		overlay.alpha = isTransIn ? 1 : 0;
		add(overlay);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		this.elapsed += elapsed;
		var ratio = Math.min(this.elapsed / duration, 1.0);
		overlay.alpha = isTransIn ? (1 - ratio) : ratio;
		if (this.elapsed >= duration)
		{
			if (isTransIn)
				close();
			else
			{
				if (finishCallback != null)
				{
					var cb = finishCallback;
					finishCallback = null;
					cb();
				}
			}
		}
	}
}
