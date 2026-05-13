package substates;

class PauseSubState extends MusicBeatSubstate
{
	var menuItems:Array<String> = ['Resume', 'Restart', 'Exit'];
	var curSelected:Int = 0;
	var texts:Array<FlxText> = [];
	var bg:FlxSprite;

	override function create()
	{
		super.create();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		for (i in 0...menuItems.length)
		{
			var t = new FlxText(0, 250 + i * 80, FlxG.width, menuItems[i]);
			t.setFormat(Paths.font('vcr.ttf'), 36, FlxColor.WHITE, CENTER);
			t.scrollFactor.set();
			texts.push(t);
			add(t);
		}

		updateSelection(0);

		#if mobile
		addTouchPad('UP_DOWN', 'A_B');
		addTouchPadCamera();
		#end
	}

	function updateSelection(change:Int)
	{
		curSelected = (curSelected + change + menuItems.length) % menuItems.length;
		for (i in 0...texts.length)
			texts[i].color = i == curSelected ? FlxColor.fromRGB(180, 140, 255) : FlxColor.WHITE;
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var up = controls.UI_UP_P;
		var down = controls.UI_DOWN_P;
		var accept = controls.ACCEPT;
		var back = controls.BACK;

		#if mobile
		if (touchPad != null)
		{
			if (touchPad.buttonUp.justPressed)   up     = true;
			if (touchPad.buttonDown.justPressed) down   = true;
			if (touchPad.buttonA.justPressed)    accept = true;
			if (touchPad.buttonB.justPressed)    back   = true;
		}
		#end

		if (up)   updateSelection(-1);
		if (down) updateSelection(1);

		if (back || (accept && curSelected == 0))
		{
			// Resume
			if (FlxG.sound.music != null) FlxG.sound.music.resume();
			cast(FlxG.state, states.PlayState).paused = false;
			close();
		}
		else if (accept)
		{
			switch (curSelected)
			{
				case 1: // Restart
					FlxG.sound.music.stop();
					MusicBeatState.switchState(new states.PlayState());
				case 2: // Exit
					FlxG.sound.music.stop();
					MusicBeatState.switchState(states.PlayState.isStoryMode ? new states.StoryMenuState() : new states.FreeplayState());
			}
		}
	}
}
