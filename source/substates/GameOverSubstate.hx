package substates;

class GameOverSubstate extends MusicBeatSubstate
{
	var boyfriend:objects.Character;

	public function new(x:Float, y:Float, ?char:String = 'bf-dead')
	{
		super();
		boyfriend = new objects.Character(x, y, char, false);
	}

	override function create()
	{
		super.create();
		add(boyfriend);

		var t = new FlxText(0, 0, FlxG.width, "GAME OVER\n[R] Retry  [ESC] Exit");
		t.setFormat(Paths.font('vcr.ttf'), 28, FlxColor.WHITE, CENTER);
		t.screenCenter();
		add(t);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (controls.BACK) MusicBeatState.switchState(new states.FreeplayState());
		if (controls.RESET)
		{
			FlxG.sound.music.stop();
			MusicBeatState.switchState(new states.PlayState());
		}
	}
}
