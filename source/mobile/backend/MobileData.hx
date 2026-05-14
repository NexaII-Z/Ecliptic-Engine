package mobile.backend;

import haxe.Json;
import haxe.io.Path;
import openfl.utils.Assets;
import flixel.util.FlxSave;
import mobile.objects.TouchPad;
import mobile.objects.TouchButton;
import mobile.input.MobileInputID;

class MobileData
{
	public static var actionModes:Map<String, TouchButtonsData> = new Map();
	public static var dpadModes:Map<String, TouchButtonsData>   = new Map();
	public static var extraActions:Map<String, ExtraActions>    = new Map();

	public static var mode(get, set):Int;
	public static var forcedMode:Null<Int>;
	public static var save:FlxSave;

	// Ecliptic mobile data paths
	static final DPAD_PATH   = 'assets/Mains/mobile/DPadModes/';
	static final ACTION_PATH = 'assets/Mains/mobile/ActionModes/';

	public static function init()
	{
		save = new FlxSave();
		save.bind('EclipticMobile');

		readAssetDirectory(DPAD_PATH,   dpadModes);
		readAssetDirectory(ACTION_PATH, actionModes);

		for (data in ExtraActions.createAll())
			extraActions.set(data.getName(), data);
	}

	static function readAssetDirectory(folder:String, map:Map<String, TouchButtonsData>)
	{
		var list = Assets.list();
		for (path in list) {
			if (path.startsWith(folder) && path.endsWith('.json')) {
				var raw = Assets.getText(path);
				if (raw == null) continue;
				var json:TouchButtonsData = cast Json.parse(raw);
				var key = Path.withoutExtension(Path.withoutDirectory(path));
				map.set(key, json);
			}
		}
	}

	public static function setTouchPadCustom(touchPad:TouchPad):Void {
		if (save.data.buttons == null) {
			save.data.buttons = new Array();
			for (buttons in touchPad) save.data.buttons.push(FlxPoint.get(buttons.x, buttons.y));
		} else {
			var tempCount:Int = 0;
			for (buttons in touchPad) { save.data.buttons[tempCount] = FlxPoint.get(buttons.x, buttons.y); tempCount++; }
		}
		save.flush();
	}

	public static function getTouchPadCustom(touchPad:TouchPad):TouchPad {
		var tempCount:Int = 0;
		if (save.data.buttons == null) return touchPad;
		for (buttons in touchPad) {
			if (save.data.buttons[tempCount] != null) { buttons.x = save.data.buttons[tempCount].x; buttons.y = save.data.buttons[tempCount].y; }
			tempCount++;
		}
		return touchPad;
	}

	public static function setButtonsColors(buttonsInstance:Dynamic):Dynamic {
		for (i => button in [buttonsInstance.buttonLeft, buttonsInstance.buttonDown, buttonsInstance.buttonUp, buttonsInstance.buttonRight]) {
			var colors = [[0xFFC24B99, 0xFFC24B99], [0xFF00FFFF, 0xFF00FFFF], [0xFF12FA05, 0xFF12FA05], [0xFFF9393F, 0xFFF9393F]];
			button.color = colors[i][0];
		}
		return buttonsInstance;
	}

	static function set_mode(mode:Int = 3):Int { save.data.mobileControlsMode = mode; save.flush(); return mode; }

	static function get_mode():Int {
		if (forcedMode != null) return forcedMode;
		if (save.data.mobileControlsMode == null) { save.data.mobileControlsMode = 3; save.flush(); }
		return save.data.mobileControlsMode;
	}
}

typedef TouchButtonsData = { buttons:Array<ButtonsData> }
typedef ButtonsData = { button:String, graphic:String, x:Float, y:Float, color:String }

enum ExtraActions { SINGLE; DOUBLE; NONE; }
