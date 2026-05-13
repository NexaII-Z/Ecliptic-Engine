package states;

import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public static var eclipticVersion:String = '0.1.0';
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var magenta:FlxSprite;
	var camFollow:FlxObject;

	// Must match the menu item file names in assets/Mains/images/menuitems/
	// e.g. menu_story_mode.png+xml, menu_freeplay.png+xml, etc.
	var optionShit:Array<String> = ['story_mode', 'freeplay', 'credits', 'options'];

	override function create()
	{
		transIn  = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		persistentUpdate = persistentDraw = true;

		// BG
		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg = new FlxSprite(-80).loadGraphic(Paths.menuBG('menuBG'));
		if (bg.graphic != null)
		{
			bg.antialiasing = ClientPrefs.data.antialiasing;
			bg.scrollFactor.set(0, yScroll);
			bg.setGraphicSize(Std.int(bg.width * 1.175));
			bg.updateHitbox();
			bg.screenCenter();
		}
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.menuBG('menuDesat'));
		if (magenta.graphic != null)
		{
			magenta.antialiasing = ClientPrefs.data.antialiasing;
			magenta.scrollFactor.set(0, yScroll);
			magenta.setGraphicSize(Std.int(magenta.width * 1.175));
			magenta.updateHitbox();
			magenta.screenCenter();
			magenta.visible = false;
			magenta.color = 0xFFfd719b;
		}
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem = new FlxSprite(0, (i * 140) + offset);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;

			// Load from Mains/images/menuitems/menu_<name>.png+xml
			var atlas = Paths.menuItemAtlas(optionShit[i]);
			if (atlas != null)
			{
				menuItem.frames = atlas;
				menuItem.animation.addByPrefix('idle',     optionShit[i] + ' basic', 24);
				menuItem.animation.addByPrefix('selected', optionShit[i] + ' white', 24);
				menuItem.animation.play('idle');
			}
			else
			{
				// Fallback: colored rectangle
				menuItem.makeGraphic(400, 100, [0xFF6B3FA0, 0xFF3F6BA0, 0xFF3FA06B, 0xFFA06B3F][i % 4]);
			}

			menuItem.updateHitbox();
			menuItem.screenCenter(X);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItems.add(menuItem);
		}

		var verTxt = new FlxText(12, FlxG.height - 24, 0, 'Ecliptic Engine v$eclipticVersion', 12);
		verTxt.scrollFactor.set();
		verTxt.setFormat('VCR OSD Mono', 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(verTxt);

		changeItem();

		#if mobile
		addTouchPad('UP_DOWN', 'A_B');
		addTouchPadCamera();
		#end

		super.create();
		FlxG.camera.follow(camFollow, null, 9);
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		// Fade menu music back in
		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * elapsed;

		if (!selectedSomethin)
		{
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

			if (up)   changeItem(-1);
			if (down) changeItem(1);

			if (back)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (accept)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				selectedSomethin = true;

				if (ClientPrefs.data.flashing && magenta.graphic != null)
					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

				FlxFlicker.flicker(menuItems.members[curSelected], 1.0, 0.06, false, false, function(_)
				{
					switch (optionShit[curSelected])
					{
						case 'story_mode':  MusicBeatState.switchState(new StoryMenuState());
						case 'freeplay':    MusicBeatState.switchState(new FreeplayState());
						case 'credits':     MusicBeatState.switchState(new CreditsState());
						case 'options':
							OptionsState.onPlayState = false;
							MusicBeatState.switchState(new OptionsState());
					}
				});

				for (i in 0...menuItems.members.length)
				{
					if (i == curSelected) continue;
					FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(_) { menuItems.members[i].kill(); }
					});
				}
			}
		}

		super.update(elapsed);
	}

	function changeItem(change:Int = 0)
	{
		if (menuItems.members[curSelected] != null)
		{
			if (menuItems.members[curSelected].frames != null)
			{
				menuItems.members[curSelected].animation.play('idle');
				menuItems.members[curSelected].updateHitbox();
			}
			menuItems.members[curSelected].screenCenter(X);
		}

		curSelected += change;
		if (curSelected >= menuItems.length) curSelected = 0;
		if (curSelected < 0) curSelected = menuItems.length - 1;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		if (menuItems.members[curSelected] != null)
		{
			if (menuItems.members[curSelected].frames != null)
			{
				menuItems.members[curSelected].animation.play('selected');
				menuItems.members[curSelected].centerOffsets();
			}
			menuItems.members[curSelected].screenCenter(X);
			camFollow.setPosition(
				menuItems.members[curSelected].getGraphicMidpoint().x,
				menuItems.members[curSelected].getGraphicMidpoint().y
			);
		}
	}
}
