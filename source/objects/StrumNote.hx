package objects;

class StrumNote extends FlxSprite
{
	public var noteData:Int = 0;
	public var player:Int   = 0;
	public var sustainReduce:Bool = true;

	static final colorNames:Array<String> = ['purple', 'blue', 'green', 'red'];

	public function new(x:Float, y:Float, noteData:Int, player:Int)
	{
		super(x, y);
		this.noteData = noteData;
		this.player   = player;

		frames = Paths.noteAtlas();
		if (frames != null)
		{
			var colorName = colorNames[noteData % 4];
			animation.addByPrefix('static',   '${colorName}0',                   24, false);
			animation.addByPrefix('pressed',  '${colorName} press',              24, false);
			animation.addByPrefix('confirm',  '${colorName} confirm',            24, false);
			animation.play('static');
		}
		else
		{
			var fallbackColors = [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F];
			makeGraphic(Std.int(Note.swagWidth) - 2, Std.int(Note.swagWidth) - 2, fallbackColors[noteData % 4]);
			alpha = 0.35;
		}

		setGraphicSize(Std.int(Note.swagWidth));
		updateHitbox();
		antialiasing = ClientPrefs.data.antialiasing;
	}

	public function playAnim(anim:String, force:Bool = false)
	{
		if (frames == null) return;
		animation.play(anim, force);
		if (anim == 'static') alpha = 1;
		else if (anim == 'pressed') alpha = 1;
		else if (anim == 'confirm') alpha = 1;
		centerOffsets();
		centerOrigin();
	}
}
