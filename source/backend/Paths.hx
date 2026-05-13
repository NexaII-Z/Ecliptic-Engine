package backend;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;
import flash.media.Sound;
import haxe.Json;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	// ─── Asset root paths ───────────────────────────────────────────
	// Mains: core engine assets (notes, characters, stage week1, ui)
	// Funkin: song data, icons, menu images, songs
	// weeks/weekX: per-week assets

	inline static public function mainPath(file:String)
		return 'assets/Mains/$file';

	inline static public function funkinPath(file:String)
		return 'assets/Funkin/$file';

	// ─── Characters ─────────────────────────────────────────────────
	// JSON:  assets/Mains/characters/<name>.json
	// Sheet: assets/Mains/images/characters/<name>.png+xml
	inline static public function characterJson(name:String)
		return mainPath('characters/$name.json');

	inline static public function characterAtlas(name:String)
		return getSparrowAtlas(mainPath('images/characters/$name'));

	// ─── Notes ──────────────────────────────────────────────────────
	// assets/Mains/images/NOTE_assets.png
	inline static public function noteAtlas()
		return getSparrowAtlas(mainPath('images/NOTE_assets'));

	// ─── Stage images ────────────────────────────────────────────────
	// assets/Mains/week1/images/<file>
	inline static public function stageImage(weekFolder:String, file:String)
		return image(mainPath('$weekFolder/images/$file'));

	inline static public function stageAtlas(weekFolder:String, file:String)
		return getSparrowAtlas(mainPath('$weekFolder/images/$file'));

	// ─── Stage data JSON ─────────────────────────────────────────────
	// assets/Funkin/data/stages/<name>.json
	inline static public function stageJson(name:String)
		return funkinPath('data/stages/$name.json');

	// ─── Charts ──────────────────────────────────────────────────────
	// assets/Funkin/songs/<Song>/Chart/<song>-<diff>.json
	static public function chartPath(song:String, diff:String):String
	{
		var s = formatToSongPath(song);
		return funkinPath('songs/$s/Chart/$s-$diff.json');
	}

	// ─── Song audio ──────────────────────────────────────────────────
	// assets/Funkin/songs/<Song>/Song/Inst.ogg
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

	// ─── Icons ───────────────────────────────────────────────────────
	// assets/Funkin/images/icons/icon-<name>.png
	inline static public function icon(name:String):FlxGraphic
		return image(funkinPath('images/icons/icon-$name'));

	// ─── Menu items ──────────────────────────────────────────────────
	// assets/Mains/images/menuitems/menu_<name>.png+xml
	inline static public function menuItemAtlas(name:String)
		return getSparrowAtlas(mainPath('images/menuitems/menu_$name'));

	// ─── Menu BG / objects ───────────────────────────────────────────
	inline static public function menuBG(key:String = 'menuBG')
		return image(funkinPath('images/objects/$key'));

	// ─── Numbers ─────────────────────────────────────────────────────
	// assets/Mains/images/nums/num<n>.png
	inline static public function numImage(n:Int)
		return image(mainPath('images/nums/num$n'));

	// ─── Judgements ──────────────────────────────────────────────────
	// assets/Mains/images/judgements/<name>.png
	inline static public function judgement(name:String)
		return image(mainPath('images/judgements/$name'));

	// ─── Title screen assets ─────────────────────────────────────────
	// assets/Funkin/images/states/title/<file>
	inline static public function titleAtlas(key:String)
		return getSparrowAtlas(funkinPath('images/states/title/$key'));

	inline static public function titleImage(key:String)
		return image(funkinPath('images/states/title/$key'));

	// ─── Alphabet ────────────────────────────────────────────────────
	inline static public function alphabetAtlas()
		return getSparrowAtlas(funkinPath('images/objects/alphabet'));

	// ─── Generic sound / music ───────────────────────────────────────
	// Sounds: assets/Funkin/sounds/<key>.ogg
	// Music:  assets/Funkin/music/<key>.ogg
	static public function sound(key:String):Sound
		return OpenFlAssets.getSound(funkinPath('sounds/$key.$SOUND_EXT'));

	static public function music(key:String):Sound
		return OpenFlAssets.getSound(funkinPath('music/$key.$SOUND_EXT'));

	// ─── Fonts ───────────────────────────────────────────────────────
	inline static public function font(key:String)
		return 'assets/fonts/$key';

	// ─── Helpers ─────────────────────────────────────────────────────
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
		trace('[ECLIPTIC] Sparrow atlas not found: $path');
		return null;
	}

	public static function formatToSongPath(path:String):String
	{
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[.,'"%?!]/;
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
