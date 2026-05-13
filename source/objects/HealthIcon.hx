package objects;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var char:String = 'face';
	public var isPlayer:Bool = false;
	public var iconOffsets:Array<Float> = [0, 0];

	public function new(char:String = 'face', isPlayer:Bool = false)
	{
		super();
		this.char     = char;
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	public function changeIcon(char:String)
	{
		this.char = char;
		// icons live at assets/Funkin/images/icons/icon-<char>.png
		var graphic = Paths.icon(char);
		if (graphic == null)
		{
			trace('[ECLIPTIC] Icon not found for: $char — using face');
			graphic = Paths.icon('face');
		}
		if (graphic != null)
		{
			loadGraphic(graphic, true, Math.floor(graphic.width / 2), Std.int(graphic.height));
			animation.add('idle', [0], 0, false, isPlayer);
			animation.add('losing', [1], 0, false, isPlayer);
			animation.play('idle');
		}
		antialiasing = ClientPrefs.data.antialiasing;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
