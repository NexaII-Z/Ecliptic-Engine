package;

import flixel.FlxGame;
import openfl.display.Sprite;
import backend.ClientPrefs;
import backend.Highscore;
import states.TitleState;
import debug.FPSCounter;

class Main extends Sprite
{
	public static final game = {
		width: 1280,
		height: 720,
		initialState: TitleState,
		framerate: 60,
		skipSplash: true,
		startFullscreen: false
	};

	public static var fpsCounter:FPSCounter;

	public function new()
	{
		super();

		ClientPrefs.loadDefaultKeys();

		var gameObj = new FlxGame(game.width, game.height, game.initialState, #if (flixel < "5.0.0") game.framerate, game.framerate, #end game.skipSplash, game.startFullscreen);
		addChild(gameObj);

		fpsCounter = new FPSCounter(10, 3, 0xFFFFFFFF);
		addChild(fpsCounter);
	}
}
