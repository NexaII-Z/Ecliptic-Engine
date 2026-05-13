package states;

class StoryMenuState extends MusicBeatState
{
	override function create()
	{
		super.create();
		var t = new FlxText(0, 0, FlxG.width, "STORY MODE\n[Coming Soon]");
		t.setFormat(Paths.font('vcr.ttf'), 36, FlxColor.WHITE, CENTER);
		t.screenCenter();
		add(t);
	}
	override function update(elapsed:Float) {
		super.update(elapsed);
		if (controls.BACK) MusicBeatState.switchState(new MainMenuState());
	}
}
