package states;

class CreditsState extends MusicBeatState
{
	override function create()
	{
		super.create();
		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(8, 4, 20));
		add(bg);
		var t = new FlxText(0, 0, FlxG.width, "ECLIPTIC ENGINE\nby NexaII-Z\nv0.1.0");
		t.setFormat(Paths.font('vcr.ttf'), 36, FlxColor.fromRGB(180, 140, 255), CENTER);
		t.screenCenter();
		add(t);
	}
	override function update(elapsed:Float) {
		super.update(elapsed);
		if (controls.BACK) MusicBeatState.switchState(new MainMenuState());
	}
}
