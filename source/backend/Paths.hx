package backend;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import flash.media.Sound;
import haxe.Json;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	inline static public function mainPath(file:String)   return 'assets/Mains/$file';
	inline static public function funkinPath(file:String) return 'assets/Funkin/$file';

	// ── FONTS ────────────────────────────────────────────────────────
	// HTML5: returns Google Font name (loaded via index.html)
	// Desktop/mobile: returns local ttf path
	inline static public function font(key:String):String
	{
		#if html5
		return switch (key)
		{
			case 'vcr.ttf':         'VT323';
			case 'pixel-latin.ttf': 'Press Start 2P';
			default:                'VT323';
		}
		#else
		return mainPath('fonts/$key');
		#end
	}

	// ── CHARACTERS ───────────────────────────────────────────────────
	inline static public function characterJson(name:String)
		return mainPath('characters/$name.json');

	// ── NOTES ────────────────────────────────────────────────────────
	inline static public function noteAtlas()
		return getSparrowAtlas(mainPath('images/NOTE_assets'));

	// ── STAGE IMAGES ─────────────────────────────────────────────────
	inline static public function stageImage(weekFolder:String, file:String)
		return image(mainPath('$weekFolder/images/$file'));

	// ── STAGE JSON ───────────────────────────────────────────────────
	inline static public function stageJson(name:String)
		return funkinPath('data/stages/$name.json');

	// ── CHARTS ───────────────────────────────────────────────────────
	static public function chartPath(song:String, diff:String):String
	{
		var s = formatToSongPath(song);
		return funkinPath('songs/$s/Chart/$s-$diff.json');
	}

	// ── AUDIO ────────────────────────────────────────────────────────
	inline static public function inst(song:String):Sound
	{
		var s = formatToSongPath(song);
		return OpenFlAssets.getSound(funkinPath('songs/$s/Song/Inst.$SOUND_EXT'));
	}

	inline static public function voices(song:String):Sound
	{
		var s = formatToSongPath(song);
		return OpenFlAssets.getSound(funkinPath('songs/$s/Song/Voices.$SOUND_EXT'));
	}

	// ── ICONS ────────────────────────────────────────────────────────
	inline static public function icon(name:String):FlxGraphic
		return image(funkinPath('images/icons/icon-$name'));

	// ── MENU ITEMS ───────────────────────────────────────────────────
	inline static public function menuItemAtlas(name:String)
		return getSparrowAtlas(mainPath('images/menuitems/menu_$name'));

	// ── MENU BG ──────────────────────────────────────────────────────
	inline static public function menuBG(key:String = 'menuBG')
		return image(funkinPath('images/objects/$key'));

	// ── TITLE ────────────────────────────────────────────────────────
	inline static public function titleAtlas(key:String)
		return getSparrowAtlas(funkinPath('images/states/title/$key'));

	inline static public function titleImage(key:String)
		return image(funkinPath('images/states/title/$key'));

	// ── ALPHABET ─────────────────────────────────────────────────────
	inline static public function alphabetAtlas()
		return getSparrowAtlas(funkinPath('images/objects/alphabet'));

	// ── SOUNDS / MUSIC ───────────────────────────────────────────────
	static public function sound(key:String):Sound
		return OpenFlAssets.getSound(funkinPath('sounds/$key.$SOUND_EXT'));

	static public function music(key:String):Sound
		return OpenFlAssets.getSound(funkinPath('music/$key.$SOUND_EXT'));

	// ── MOBILE ───────────────────────────────────────────────────────
	inline static public function getSharedPath(file:String = '')
		return mainPath('mobile/$file');

	// ── HELPERS ──────────────────────────────────────────────────────
	static public function image(path:String):FlxGraphic
	{
		var fullPath = '$path.png';
		if (OpenFlAssets.exists(fullPath, IMAGE))
			return FlxGraphic.fromAssetKey(fullPath);
		trace('[ECLIPTIC] Image not found: $fullPath');
		return null;
	}

	static public function getSparrowAtlas(path:String):FlxAtlasFrames
	{
		var png = '$path.png';
		var xml = '$path.xml';
		if (OpenFlAssets.exists(png) && OpenFlAssets.exists(xml))
			return FlxAtlasFrames.fromSparrow(image(path), xml);
		trace('[ECLIPTIC] Atlas not found: $path');
		return null;
	}

	static public function readDirectory(folder:String):Array<String>
	{
		var list = OpenFlAssets.list();
		var result = [];
		for (f in list)
			if (f.startsWith(folder))
				result.push(f);
		return result;
	}

	public static function formatToSongPath(path:String):String
	{
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars    = ~/[.,'"%?!]/;
		var p = invalidChars.split(path.replace(' ', '-')).join('-');
		return hideChars.split(p).join('').toLowerCase();
	}

	public static function getText(path:String):String
	{
		if (OpenFlAssets.exists(path, TEXT))
			return OpenFlAssets.getText(path);
		return null;
	}
}
