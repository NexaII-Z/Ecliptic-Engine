package backend;

import backend.Song;

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
	@:optional var stepCrochet:Float;
}

class Conductor
{
	public static var bpm(default, set):Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000);
	public static var stepCrochet:Float = crochet / 4;
	public static var songPosition:Float = 0;
	public static var offset:Float = 0;
	public static var safeZoneOffset:Float = 0;
	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static function getBPMFromSeconds(time:Float):BPMChangeEvent
	{
		var lastChange:BPMChangeEvent = {stepTime: 0, songTime: 0, bpm: bpm, stepCrochet: stepCrochet};
		for (i in 0...bpmChangeMap.length)
			if (time >= bpmChangeMap[i].songTime)
				lastChange = bpmChangeMap[i];
		return lastChange;
	}

	public static function getBPMFromStep(step:Float):BPMChangeEvent
	{
		var lastChange:BPMChangeEvent = {stepTime: 0, songTime: 0, bpm: bpm, stepCrochet: stepCrochet};
		for (i in 0...bpmChangeMap.length)
			if (bpmChangeMap[i].stepTime <= step)
				lastChange = bpmChangeMap[i];
		return lastChange;
	}

	public static function getStep(time:Float):Float
	{
		var lastChange = getBPMFromSeconds(time);
		return lastChange.stepTime + (time - lastChange.songTime) / lastChange.stepCrochet;
	}

	public static function getStepRounded(time:Float):Float
	{
		var lastChange = getBPMFromSeconds(time);
		return lastChange.stepTime + Math.floor(time - lastChange.songTime) / lastChange.stepCrochet;
	}

	public static function getBeat(time:Float):Float return getStep(time) / 4;
	public static function getBeatRounded(time:Float):Int return Math.floor(getStepRounded(time) / 4);

	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];
		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				bpmChangeMap.push({stepTime: totalSteps, songTime: totalPos, bpm: curBPM, stepCrochet: calculateCrochet(curBPM) / 4});
			}
			var deltaSteps:Int = Math.round(getSectionBeats(song, i) * 4);
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
	}

	static function getSectionBeats(song:SwagSong, section:Int):Float
	{
		var val:Null<Float> = null;
		if (song.notes[section] != null) val = song.notes[section].sectionBeats;
		return val != null ? val : 4;
	}

	inline public static function calculateCrochet(bpm:Float):Float return (60 / bpm) * 1000;

	public static function set_bpm(newBPM:Float):Float
	{
		bpm = newBPM;
		crochet = calculateCrochet(bpm);
		stepCrochet = crochet / 4;
		return bpm = newBPM;
	}
}
