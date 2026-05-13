package options;

class OptionsState extends MusicBeatState
{
	public static var onPlayState:Bool = false;

	override function create()
	{
		super.create();
		var t = new FlxText(0, 0, FlxG.width, "OPTIONS\n[Coming Soon]");
		t.setFormat(Paths.font('vcr.ttf'), 36, FlxColor.WHITE, CENTER);
		t.screenCenter();
		add(t);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (controls.BACK)
		{
			ClientPrefs.savePrefs();
			if (onPlayState) MusicBeatState.switchState(new PlayState());
			else MusicBeatState.switchState(new MainMenuState());
		}
	}
}
