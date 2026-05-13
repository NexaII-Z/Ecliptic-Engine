package states;

class FreeplayState extends MusicBeatState
{
	public static var vocals:flixel.sound.FlxSound = null;

	override function create()
	{
		super.create();
		var t = new FlxText(0, 0, FlxG.width, "FREEPLAY\n[Coming Soon]");
		t.setFormat(Paths.font('vcr.ttf'), 36, FlxColor.WHITE, CENTER);
		t.screenCenter();
		add(t);
	}
	override function update(elapsed:Float) {
		super.update(elapsed);
		if (controls.BACK) MusicBeatState.switchState(new MainMenuState());
	}
}
