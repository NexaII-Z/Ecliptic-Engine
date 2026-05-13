package backend;

import flixel.util.FlxSave;

typedef SongScore =
{
	var score:Int;
	var misses:Int;
	var accuracy:Float;
	var rating:String;
}

class Highscore
{
	static var _save:FlxSave;

	public static function init()
	{
		_save = new FlxSave();
		_save.bind('EclipticScores');
	}

	public static function saveScore(song:String, diff:String, score:Int, misses:Int, accuracy:Float)
	{
		var key = '${song}_$diff';
		var existing = getScore(song, diff);
		if (score > existing.score)
		{
			_save.data[key] = {score: score, misses: misses, accuracy: accuracy, rating: getRating(accuracy)};
			_save.flush();
		}
	}

	public static function getScore(song:String, diff:String):SongScore
	{
		var key = '${song}_$diff';
		var d = _save.data[key];
		if (d != null) return cast d;
		return {score: 0, misses: 0, accuracy: 0.0, rating: 'N/A'};
	}

	public static function getRating(accuracy:Float):String
	{
		if (accuracy >= 100) return 'Perfect!!';
		if (accuracy >= 96)  return 'Sick!';
		if (accuracy >= 80)  return 'Good';
		if (accuracy >= 70)  return 'Meh';
		return 'Bad';
	}
}
