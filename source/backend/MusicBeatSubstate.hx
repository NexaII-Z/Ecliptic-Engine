package backend;

import flixel.addons.ui.FlxUISubState;
import mobile.objects.TouchPad;

class MusicBeatSubstate extends FlxUISubState
{
	private var curStep:Int  = 0;
	private var curBeat:Int  = 0;
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

	override function update(elapsed:Float)
	{
		var oldStep = curStep;
		updateCurStep();
		curBeat    = Math.floor(curStep / 4);
		curDecBeat = curDecStep / 4;
		if (oldStep != curStep && curStep > 0) stepHit();
		super.update(elapsed);
	}

	private function updateCurStep()
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);
		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep    = lastChange.stepTime + Math.floor(shit);
	}

	public function stepHit() { if (curStep % 4 == 0) beatHit(); }
	public function beatHit() {}
}
