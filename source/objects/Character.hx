package objects;

import haxe.Json;
import openfl.utils.Assets;
import backend.Song;

typedef CharacterFile =
{
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;
	var position:Array<Float>;
	var camera_position:Array<Float>;
	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
	@:optional var vocals_file:String;
	@:optional var is_gf:Bool;
}

typedef AnimArray =
{
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	public static final DEFAULT_CHARACTER:String = 'bf';

	public var animOffsets:Map<String, Array<Dynamic>> = [];
	public var isPlayer:Bool  = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var holdTimer:Float  = 0;
	public var heyTimer:Float   = 0;
	public var specialAnim:Bool = false;
	public var stunned:Bool     = false;
	public var singDuration:Float = 4;
	public var idleSuffix:String  = '';
	public var danceIdle:Bool   = false;
	public var skipDance:Bool   = false;
	public var danced:Bool      = false;
	public var danceEveryNumBeats:Int = 2;

	public var healthIcon:String     = 'face';
	public var animationsArray:Array<AnimArray> = [];
	public var positionArray:Array<Float>  = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];
	public var healthColorArray:Array<Int> = [255, 0, 0];
	public var hasMissAnimations:Bool = false;
	public var vocalsFile:String      = '';

	public var imageFile:String    = '';
	public var jsonScale:Float     = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool  = false;
	public var isGF:Bool           = false;

	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false)
	{
		super(x, y);
		animOffsets = new Map();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var characterPath = Paths.characterJson(curCharacter);
		var raw:String = null;

		#if sys
		if (sys.FileSystem.exists(characterPath))
			raw = sys.io.File.getContent(characterPath);
		else
		#end
		if (Assets.exists(characterPath, TEXT))
			raw = Assets.getText(characterPath);

		if (raw == null)
		{
			trace('[ECLIPTIC] Character not found: $characterPath — using default');
			curCharacter = DEFAULT_CHARACTER;
			color = FlxColor.BLACK;
			alpha = 0.6;
			var fallback = Paths.characterJson(DEFAULT_CHARACTER);
			if (Assets.exists(fallback, TEXT)) raw = Assets.getText(fallback);
		}

		if (raw != null)
		{
			try { loadCharacterFile(Json.parse(raw)); }
			catch (e:Dynamic) { trace('[ECLIPTIC] Failed parsing character: $curCharacter — $e'); }
		}

		if (isPlayer) flipX = !flipX;
		recalculateDanceIdle();
		dance();
	}

	function loadCharacterFile(data:CharacterFile)
	{
		imageFile       = data.image;
		jsonScale       = data.scale;
		singDuration    = data.sing_duration;
		healthIcon      = data.healthicon;
		positionArray   = data.position != null ? data.position : [0, 0];
		cameraPosition  = data.camera_position != null ? data.camera_position : [0, 0];
		originalFlipX   = data.flip_x;
		noAntialiasing  = data.no_antialiasing;
		healthColorArray = data.healthbar_colors != null ? data.healthbar_colors : [255, 0, 0];
		if (data.vocals_file != null) vocalsFile = data.vocals_file;
		if (data.is_gf == true) isGF = true;
		animationsArray = data.animations;

		// Load the spritesheet from Mains/images/characters/<image>
		var atlasFull = 'assets/Mains/images/${imageFile}';
		if (Assets.exists('$atlasFull.png') && Assets.exists('$atlasFull.xml'))
			frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromAssetKey('$atlasFull.png'), '$atlasFull.xml');
		else
		{
			trace('[ECLIPTIC] Missing spritesheet: $atlasFull');
			makeGraphic(150, 150, FlxColor.MAGENTA);
		}

		for (anim in animationsArray)
		{
			if (anim.indices != null && anim.indices.length > 0)
				animation.addByIndices(anim.anim, anim.name, anim.indices, '', anim.fps, anim.loop);
			else
				animation.addByPrefix(anim.anim, anim.name, anim.fps, anim.loop);

			if (anim.offsets != null && anim.offsets.length >= 2)
				addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
		}

		if (jsonScale != 1)
		{
			setGraphicSize(Std.int(width * jsonScale));
			updateHitbox();
		}

		flipX          = originalFlipX;
		antialiasing   = !noAntialiasing && ClientPrefs.data.antialiasing;
		hasMissAnimations = animOffsets.exists('singLEFTmiss') || animOffsets.exists('singDOWNmiss')
			|| animOffsets.exists('singUPmiss') || animOffsets.exists('singRIGHTmiss');
	}

	public function dance()
	{
		if (!skipDance && !specialAnim)
		{
			if (danceIdle)
			{
				danced = !danced;
				playAnim(danced ? 'danceRight' + idleSuffix : 'danceLeft' + idleSuffix);
			}
			else if (animOffsets.exists('idle' + idleSuffix))
				playAnim('idle' + idleSuffix);
		}
	}

	public function playAnim(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0)
	{
		specialAnim = false;
		animation.play(animName, force, reversed, frame);
		if (animOffsets.exists(animName))
		{
			var off = animOffsets.get(animName);
			offset.set(off[0], off[1]);
		}
		// GF sing tracking
		if (isGF || curCharacter == 'gf' || curCharacter.startsWith('gf-'))
		{
			if (animName == 'singLEFT') danced = true;
			else if (animName == 'singRIGHT') danced = false;
			if (animName == 'singUP' || animName == 'singDOWN') danced = !danced;
		}
	}

	public function recalculateDanceIdle()
	{
		danceIdle = animOffsets.exists('danceLeft' + idleSuffix) && animOffsets.exists('danceRight' + idleSuffix);
		danceEveryNumBeats = danceIdle ? 1 : 2;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
		animOffsets[name] = [x, y];
}
