package mobile.input;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import mobile.input.MobileInputID;
import mobile.objects.TouchButton;

class MobileInputManager extends FlxTypedSpriteGroup<TouchButton>
{
	public var trackedButtons:Map<MobileInputID, TouchButton> = new Map<MobileInputID, TouchButton>();

	public function new() { super(); updateTrackedButtons(); }

	public inline function buttonPressed(b:MobileInputID):Bool return anyPressed([b]);
	public inline function buttonJustPressed(b:MobileInputID):Bool return anyJustPressed([b]);
	public inline function buttonJustReleased(b:MobileInputID):Bool return anyJustReleased([b]);
	public inline function buttonReleased(b:MobileInputID):Bool return anyReleased([b]);
	public inline function anyPressed(b:Array<MobileInputID>):Bool return checkButtonArrayState(b, PRESSED);
	public inline function anyJustPressed(b:Array<MobileInputID>):Bool return checkButtonArrayState(b, JUST_PRESSED);
	public inline function anyJustReleased(b:Array<MobileInputID>):Bool return checkButtonArrayState(b, JUST_RELEASED);
	public inline function anyReleased(b:Array<MobileInputID>):Bool return checkButtonArrayState(b, RELEASED);

	public function checkStatus(button:MobileInputID, state:ButtonsStates = JUST_PRESSED):Bool {
		switch (button) {
			case MobileInputID.ANY:
				for (b in trackedButtons.keys()) if (checkStatusUnsafe(b, state)) return true;
			case MobileInputID.NONE: return false;
			default: if (trackedButtons.exists(button)) return checkStatusUnsafe(button, state);
		}
		return false;
	}

	function checkButtonArrayState(buttons:Array<MobileInputID>, state:ButtonsStates = JUST_PRESSED):Bool {
		if (buttons == null) return false;
		for (b in buttons) if (checkStatus(b, state)) return true;
		return false;
	}

	function checkStatusUnsafe(button:MobileInputID, state:ButtonsStates):Bool {
		return switch (state) {
			case RELEASED: trackedButtons.get(button).released;
			case JUST_RELEASED: trackedButtons.get(button).justReleased;
			case PRESSED: trackedButtons.get(button).pressed;
			case JUST_PRESSED: trackedButtons.get(button).justPressed;
		}
	}

	public function updateTrackedButtons() {
		trackedButtons.clear();
		forEachExists(function(button:TouchButton) {
			if (button.IDs != null)
				for (id in button.IDs)
					if (!trackedButtons.exists(id))
						trackedButtons.set(id, button);
		});
	}
}

enum ButtonsStates { PRESSED; JUST_PRESSED; RELEASED; JUST_RELEASED; }
