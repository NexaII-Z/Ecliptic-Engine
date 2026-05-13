package backend;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;

@:structInit class SaveData
{
	// Gameplay
	public var downScroll:Bool   = false;
	public var middleScroll:Bool = false;
	public var ghostTapping:Bool = true;
	public var noteOffset:Int    = 0;
	public var noReset:Bool      = false;

	// Visual
	public var showFPS:Bool        = true;
	public var flashing:Bool       = true;
	public var antialiasing:Bool   = true;
	public var camZooms:Bool       = true;
	public var lowQuality:Bool     = false;
	public var framerate:Int       = 60;
	public var healthBarAlpha:Float = 1;

	// Audio
	public var hitsoundVolume:Float = 0;

	// Mobile
	public var controlsAlpha:Float = FlxG.onMobile ? 0.6 : 0;

	// Score
	public var timeBarType:String  = 'Time Left';
	public var scoreZoom:Bool      = true;
}

class ClientPrefs
{
	public static var data:SaveData = new SaveData();
	static var _save:FlxSave;

	// Keybinds  [primary, secondary]
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		'note_left'  => [D,    LEFT],
		'note_down'  => [F,    DOWN],
		'note_up'    => [J,    UP],
		'note_right' => [K,    RIGHT],
		'ui_left'    => [LEFT, A],
		'ui_down'    => [DOWN, S],
		'ui_up'      => [UP,   W],
		'ui_right'   => [RIGHT,D],
		'accept'     => [SPACE, ENTER],
		'back'       => [ESCAPE, BACKSPACE],
		'pause'      => [ENTER,  ESCAPE],
		'reset'      => [R,      NONE],
	];

	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys()
	{
		defaultKeys = keyBinds.copy();
		loadPrefs();
	}

	public static function loadPrefs()
	{
		_save = new FlxSave();
		_save.bind('EclipticPrefs');

		if (_save.data.downScroll   != null) data.downScroll   = _save.data.downScroll;
		if (_save.data.middleScroll != null) data.middleScroll = _save.data.middleScroll;
		if (_save.data.ghostTapping != null) data.ghostTapping = _save.data.ghostTapping;
		if (_save.data.noteOffset   != null) data.noteOffset   = _save.data.noteOffset;
		if (_save.data.showFPS      != null) data.showFPS      = _save.data.showFPS;
		if (_save.data.flashing     != null) data.flashing     = _save.data.flashing;
		if (_save.data.antialiasing != null) data.antialiasing = _save.data.antialiasing;
		if (_save.data.framerate    != null) data.framerate    = _save.data.framerate;
		if (_save.data.lowQuality   != null) data.lowQuality   = _save.data.lowQuality;

		FlxG.updateFramerate = data.framerate;
		FlxG.drawFramerate   = data.framerate;
	}

	public static function savePrefs()
	{
		_save.data.downScroll   = data.downScroll;
		_save.data.middleScroll = data.middleScroll;
		_save.data.ghostTapping = data.ghostTapping;
		_save.data.noteOffset   = data.noteOffset;
		_save.data.showFPS      = data.showFPS;
		_save.data.flashing     = data.flashing;
		_save.data.antialiasing = data.antialiasing;
		_save.data.framerate    = data.framerate;
		_save.data.lowQuality   = data.lowQuality;
		_save.flush();
	}
}
