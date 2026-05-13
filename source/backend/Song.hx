package backend;

import haxe.Json;
import openfl.utils.Assets;

// Ecliptic chart format
typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;
	@:optional var gameOverChar:String;
	@:optional var arrowSkin:String;
}

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var sectionBeats:Float;
	var mustHitSection:Bool;
	@:optional var changeBPM:Bool;
	@:optional var bpm:Float;
	@:optional var altAnim:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var events:Array<Dynamic>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;
	public var stage:String;
	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';

	public function new(song:String, notes:Array<SwagSection>, bpm:Float)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	// Converts Ecliptic chart format (sections[]) to SwagSong (notes[])
	static function convertEclipticFormat(raw:Dynamic):Dynamic
	{
		if (raw.ecliptic_chart == true && raw.sections != null)
		{
			var notes:Array<Dynamic> = [];
			for (sec in cast(raw.sections, Array<Dynamic>))
			{
				notes.push({
					sectionNotes: sec.notes != null ? sec.notes : [],
					sectionBeats: sec.beats != null ? sec.beats : 4,
					mustHitSection: sec.mustHitSection == true,
					changeBPM: sec.bpmChange == true,
					bpm: sec.bpm != null ? sec.bpm : raw.bpm,
					altAnim: false
				});
			}
			return {
				song: {
					song:         raw.song,
					notes:        notes,
					events:       raw.events != null ? raw.events : [],
					bpm:          raw.bpm,
					needsVoices:  raw.needsVoices == true,
					speed:        raw.speed != null ? raw.speed : 1,
					player1:      raw.player1 != null ? raw.player1 : 'bf',
					player2:      raw.player2 != null ? raw.player2 : 'dad',
					gfVersion:    raw.gf != null ? raw.gf : 'gf',
					stage:        raw.stage != null ? raw.stage : 'stage'
				}
			};
		}
		return raw;
	}

	public static function loadFromJson(songName:String, ?difficulty:String = 'normal'):SwagSong
	{
		var path = Paths.chartPath(songName, difficulty);
		var rawJson:String = null;

		#if sys
		if (sys.FileSystem.exists(path))
			rawJson = sys.io.File.getContent(path).trim();
		else
		#end
		if (Assets.exists(path, TEXT))
			rawJson = Assets.getText(path).trim();

		if (rawJson == null)
		{
			trace('[ECLIPTIC] Chart not found: $path');
			return getDefaultSong(songName);
		}

		// trim trailing garbage
		while (!rawJson.endsWith('}'))
			rawJson = rawJson.substr(0, rawJson.length - 1);

		var parsed:Dynamic = Json.parse(rawJson);
		parsed = convertEclipticFormat(parsed);

		var songData:SwagSong = cast (parsed.song != null ? parsed.song : parsed);

		// Fill missing gfVersion from older format
		if (songData.gfVersion == null)
		{
			var dyn:Dynamic = cast songData;
			songData.gfVersion = dyn.player3 != null ? dyn.player3 : 'gf';
		}

		if (songData.events == null) songData.events = [];

		return songData;
	}

	static function getDefaultSong(name:String):SwagSong
	{
		return {
			song:        name,
			notes:       [],
			events:      [],
			bpm:         150,
			needsVoices: false,
			speed:       1.0,
			player1:     'bf',
			player2:     'dad',
			gfVersion:   'gf',
			stage:       'stage'
		};
	}
}
