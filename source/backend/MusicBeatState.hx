package backend;

import flixel.addons.transition.FlxTransitionableState;
import mobile.objects.TouchPad;

class MusicBeatState extends FlxUIState
{
	private var curSection:Int = 0;
	private var stepsToDo:Int  = 0;
	private var curStep:Int    = 0;
	private var curBeat:Int    = 0;
	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;

	public var controls(get, never):Controls;
	private function get_controls() return Controls.instance;

	public var touchPad:TouchPad;
	public var touchPadCam:FlxCamera;

	public function addTouchPad(dpad:String, action:String)
	{
		touchPad = new TouchPad(dpad, action);
		add(touchPad);
	}

	public function addTouchPadCamera(defaultDrawTarget:Bool = false)
	{
		if (touchPad != null)
		{
			touchPadCam = new FlxCamera();
			touchPadCam.bgColor.alpha = 0;
			FlxG.cameras.add(touchPadCam, defaultDrawTarget);
			touchPad.cameras = [touchPadCam];
		}
	}

	public function removeTouchPad()
	{
		if (touchPad != null)
		{
			remove(touchPad);
			touchPad = FlxDestroyUtil.destroy(touchPad);
		}
		if (touchPadCam != null)
		{
			FlxG.cameras.remove(touchPadCam);
			touchPadCam = FlxDestroyUtil.destroy(touchPadCam);
		}
	}

	override function destroy()
	{
		removeTouchPad();
		super.destroy();
	}

	public static var timePassedOnState:Float = 0;

	override function create()
	{
		var skip = FlxTransitionableState.skipNextTransOut;
		super.create();
		if (!skip)
			openSubState(new backend.CustomFadeTransition(0.6, true));
		FlxTransitionableState.skipNextTransOut = false;
		timePassedOnState = 0;
	}

	override function update(elapsed:Float)
	{
		var oldStep = curStep;
		timePassedOnState += elapsed;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if (curStep > 0) stepHit();
			if (PlayState.SONG != null)
			{
				if (oldStep < curStep) updateSection();
				else rollbackSection();
			}
		}

		super.update(elapsed);
	}

	private function updateSection()
	{
		if (stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while (curStep >= stepsToDo)
		{
			curSection++;
			stepsToDo += Math.round(getBeatsOnSection() * 4);
			sectionHit();
		}
	}

	private function rollbackSection()
	{
		if (curStep < 0) return;
		var lastSection = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if (stepsToDo > curStep) break;
				curSection++;
			}
		}
		if (curSection > lastSection) sectionHit();
	}

	private function updateBeat() { curBeat = Math.floor(curStep / 4); curDecBeat = curDecStep / 4; }

	private function updateCurStep()
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);
		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep    = lastChange.stepTime + Math.floor(shit);
	}

	public static function switchState(nextState:FlxState = null)
	{
		if (nextState == null) nextState = FlxG.state;
		if (nextState == FlxG.state) { resetState(); return; }
		if (FlxTransitionableState.skipNextTransIn) FlxG.switchState(nextState);
		else startTransition(nextState);
		FlxTransitionableState.skipNextTransIn = false;
	}

	public static function resetState()
	{
		if (FlxTransitionableState.skipNextTransIn) FlxG.resetState();
		else startTransition();
		FlxTransitionableState.skipNextTransIn = false;
	}

	public static function startTransition(nextState:FlxState = null)
	{
		if (nextState == null) nextState = FlxG.state;
		FlxG.state.openSubState(new backend.CustomFadeTransition(0.6, false));
		if (nextState == FlxG.state)
			backend.CustomFadeTransition.finishCallback = function() FlxG.resetState();
		else
			backend.CustomFadeTransition.finishCallback = function() FlxG.switchState(nextState);
	}

	public function stepHit() { if (curStep % 4 == 0) beatHit(); }
	public function beatHit() {}
	public function sectionHit() {}

	function getBeatsOnSection():Float
	{
		var val:Null<Float> = 4;
		if (PlayState.SONG != null && PlayState.SONG.notes[curSection] != null)
			val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
