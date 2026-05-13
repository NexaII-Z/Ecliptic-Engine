package backend;

import flixel.input.keyboard.FlxKey;

class Controls
{
	static var _instance:Controls;
	public static var instance(get, never):Controls;
	static function get_instance():Controls
	{
		if (_instance == null) _instance = new Controls();
		return _instance;
	}

	// ── Pressed (just) ──────────────────────
	public var NOTE_LEFT_P(get,  never):Bool;
	public var NOTE_DOWN_P(get,  never):Bool;
	public var NOTE_UP_P(get,    never):Bool;
	public var NOTE_RIGHT_P(get, never):Bool;
	public var UI_LEFT_P(get,    never):Bool;
	public var UI_DOWN_P(get,    never):Bool;
	public var UI_UP_P(get,      never):Bool;
	public var UI_RIGHT_P(get,   never):Bool;
	public var ACCEPT(get,       never):Bool;
	public var BACK(get,         never):Bool;
	public var PAUSE(get,        never):Bool;
	public var RESET(get,        never):Bool;

	// ── Held ────────────────────────────────
	public var NOTE_LEFT(get,  never):Bool;
	public var NOTE_DOWN(get,  never):Bool;
	public var NOTE_UP(get,    never):Bool;
	public var NOTE_RIGHT(get, never):Bool;

	// ── Released ────────────────────────────
	public var NOTE_LEFT_R(get,  never):Bool;
	public var NOTE_DOWN_R(get,  never):Bool;
	public var NOTE_UP_R(get,    never):Bool;
	public var NOTE_RIGHT_R(get, never):Bool;

	function get_NOTE_LEFT_P()  return justPressed('note_left');
	function get_NOTE_DOWN_P()  return justPressed('note_down');
	function get_NOTE_UP_P()    return justPressed('note_up');
	function get_NOTE_RIGHT_P() return justPressed('note_right');
	function get_UI_LEFT_P()    return justPressed('ui_left');
	function get_UI_DOWN_P()    return justPressed('ui_down');
	function get_UI_UP_P()      return justPressed('ui_up');
	function get_UI_RIGHT_P()   return justPressed('ui_right');
	function get_ACCEPT()       return justPressed('accept');
	function get_BACK()         return justPressed('back');
	function get_PAUSE()        return justPressed('pause');
	function get_RESET()        return justPressed('reset');

	function get_NOTE_LEFT()  return pressed('note_left');
	function get_NOTE_DOWN()  return pressed('note_down');
	function get_NOTE_UP()    return pressed('note_up');
	function get_NOTE_RIGHT() return pressed('note_right');

	function get_NOTE_LEFT_R()  return released('note_left');
	function get_NOTE_DOWN_R()  return released('note_down');
	function get_NOTE_UP_R()    return released('note_up');
	function get_NOTE_RIGHT_R() return released('note_right');

	public function justPressed(key:String):Bool
	{
		var keys = ClientPrefs.keyBinds.get(key);
		if (keys == null) return false;
		for (k in keys)
			if (FlxG.keys.checkStatus(k, JUST_PRESSED)) return true;
		return false;
	}

	public function pressed(key:String):Bool
	{
		var keys = ClientPrefs.keyBinds.get(key);
		if (keys == null) return false;
		for (k in keys)
			if (FlxG.keys.checkStatus(k, PRESSED)) return true;
		return false;
	}

	public function released(key:String):Bool
	{
		var keys = ClientPrefs.keyBinds.get(key);
		if (keys == null) return false;
		for (k in keys)
			if (FlxG.keys.checkStatus(k, JUST_RELEASED)) return true;
		return false;
	}
}
