package states;

import flixel.addons.transition.FlxTransitionableState;

class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	var logoBumpin:FlxSprite;
	var gfDanceTitle:FlxSprite;
	var titleEnter:FlxSprite;

	var blackScreen:FlxSprite;
	var transitioning:Bool = false;

	override function create()
	{
		FlxTransitionableState.skipNextTransIn  = true;
		FlxTransitionableState.skipNextTransOut = true;
		super.create();

		// Background
		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		// GF dancing on title
		gfDanceTitle = new FlxSprite(FlxG.width * 0.397, FlxG.height * 0.07);
		gfDanceTitle.frames = Paths.titleAtlas('gfDanceTitle');
		if (gfDanceTitle.frames != null)
		{
			gfDanceTitle.animation.addByIndices('danceLeft',  'gfDanceTitle', [30, 0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13, 14], '', 24, false);
			gfDanceTitle.animation.addByIndices('danceRight', 'gfDanceTitle', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '',      24, false);
			gfDanceTitle.animation.play('danceLeft');
		}
		gfDanceTitle.antialiasing = ClientPrefs.data.antialiasing;
		add(gfDanceTitle);

		// Logo
		logoBumpin = new FlxSprite(-150, -100);
		logoBumpin.frames = Paths.titleAtlas('logoBumpin');
		if (logoBumpin.frames != null)
		{
			logoBumpin.animation.addByPrefix('bump', 'logo bumpin', 24, false);
			logoBumpin.animation.play('bump');
		}
		logoBumpin.antialiasing = ClientPrefs.data.antialiasing;
		add(logoBumpin);

		// "Press Enter" text
		titleEnter = new FlxSprite(100, FlxG.height * 0.8);
		titleEnter.frames = Paths.titleAtlas('titleEnter');
		if (titleEnter.frames != null)
		{
			titleEnter.animation.addByPrefix('idle',    'ENTER IDLE',    24, true);
			titleEnter.animation.addByPrefix('pressed', 'ENTER PRESSED', 24, false);
			titleEnter.animation.play('idle');
		}
		titleEnter.antialiasing = ClientPrefs.data.antialiasing;
		add(titleEnter);

		#if mobile
		addTouchPad('NONE', 'A');
		addTouchPadCamera();
		#end

		Highscore.init();
		initialized = true;
	}

	var danced:Bool = false;
	override function beatHit()
	{
		super.beatHit();
		danced = !danced;
		if (gfDanceTitle != null && gfDanceTitle.frames != null)
			gfDanceTitle.animation.play(danced ? 'danceRight' : 'danceLeft');
		if (logoBumpin != null && logoBumpin.frames != null)
			logoBumpin.animation.play('bump', true);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music == null)
		{
			var mus = Paths.music('freakyMenu');
			if (mus != null)
			{
				FlxG.sound.playMusic(mus, 0);
				FlxG.sound.music.fadeIn(4, 0, 0.7);
			}
			Conductor.bpm = 102;
		}

		Conductor.songPosition = FlxG.sound.music != null ? FlxG.sound.music.time : 0;

		super.update(elapsed);

		if (!transitioning)
		{
			var press = controls.ACCEPT;
			#if mobile
			if (touchPad != null && touchPad.buttonA.justPressed) press = true;
			#end

			if (press)
			{
				transitioning = true;
				if (titleEnter != null && titleEnter.frames != null)
					titleEnter.animation.play('pressed');

				FlxG.sound.play(Paths.sound('confirmMenu'));
				new FlxTimer().start(1.0, function(_) {
					MusicBeatState.switchState(new MainMenuState());
				});
			}
		}
	}
}
