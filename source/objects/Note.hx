package objects;

class Note extends FlxSprite
{
	public static var swagWidth:Float = 160 * 0.7;
	public static final NOTE_DATA_SIZE:Int = 4;

	public var strumTime:Float = 0;
	public var noteData:Int    = 0;
	public var mustPress:Bool  = false;
	public var wasGoodHit:Bool = false;
	public var tooLate:Bool    = false;
	public var isSustain:Bool  = false;
	public var isSustainEnd:Bool = false;
	public var sustainLength:Float = 0;
	public var prevNote:Note;
	public var animSuffix:String = '';
	public var noAnimation:Bool  = false;
	public var noteSplash:Bool   = true;

	static final defaultColors:Array<String> = ['purple', 'blue', 'green', 'red'];

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, isSustain:Bool = false, ?inEditor:Bool = false)
	{
		super();
		this.strumTime = strumTime;
		this.noteData  = noteData;
		this.prevNote  = prevNote;
		this.isSustain = isSustain;

		// Load frames from Mains note atlas
		frames = Paths.noteAtlas();
		if (frames != null)
		{
			var dir = noteData % NOTE_DATA_SIZE;
			var colorName = defaultColors[dir];

			if (!isSustain)
			{
				animation.addByPrefix('idle', '${colorName}0', 24, false);
				animation.addByPrefix('hit',  '${colorName} confirm', 24, false);
				animation.play('idle');
			}
			else
			{
				animation.addByPrefix('sustain', '${colorName} hold piece', 24, true);
				animation.addByPrefix('sustainEnd', '${colorName} hold end',  24, false);
				animation.play(isSustainEnd ? 'sustainEnd' : 'sustain');
				alpha = 0.6;
			}
		}
		else
		{
			// Fallback: colored rectangles
			var fallbackColors = [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F];
			var col = fallbackColors[noteData % 4];
			makeGraphic(Std.int(swagWidth) - 2, isSustain ? 24 : Std.int(swagWidth) - 2, col);
		}

		antialiasing = ClientPrefs.data.antialiasing;

		setGraphicSize(Std.int(swagWidth));
		updateHitbox();

		if (isSustain && prevNote != null)
			updateSustainPosition();
	}

	function updateSustainPosition()
	{
		if (prevNote.isSustain)
			prevNote.scale.y += 1 / prevNote.frameHeight;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (tooLate && !wasGoodHit) alpha = 0.3;
	}
}
