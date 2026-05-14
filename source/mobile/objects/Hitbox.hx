package mobile.objects;

import openfl.display.BitmapData;
import openfl.display.Shape;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxSignal.FlxTypedSignal;
import openfl.geom.Matrix;
import mobile.input.MobileInputManager;
import mobile.input.MobileInputID;
import mobile.objects.IMobileControls;
import mobile.objects.TouchButton;

class Hitbox extends MobileInputManager implements IMobileControls
{
	final offsetFir:Int = 0;
	final offsetSec:Int = Std.int(FlxG.height / 4);

	public var buttonLeft:TouchButton   = new TouchButton(0, 0, [MobileInputID.HITBOX_LEFT,  MobileInputID.NOTE_LEFT]);
	public var buttonDown:TouchButton   = new TouchButton(0, 0, [MobileInputID.HITBOX_DOWN,  MobileInputID.NOTE_DOWN]);
	public var buttonUp:TouchButton     = new TouchButton(0, 0, [MobileInputID.HITBOX_UP,    MobileInputID.NOTE_UP]);
	public var buttonRight:TouchButton  = new TouchButton(0, 0, [MobileInputID.HITBOX_RIGHT, MobileInputID.NOTE_RIGHT]);
	public var buttonExtra:TouchButton  = new TouchButton(0, 0, [MobileInputID.EXTRA_1]);
	public var buttonExtra2:TouchButton = new TouchButton(0, 0, [MobileInputID.EXTRA_2]);

	public var instance:MobileInputManager;
	public var onButtonDown:FlxTypedSignal<TouchButton->Void> = new FlxTypedSignal<TouchButton->Void>();
	public var onButtonUp:FlxTypedSignal<TouchButton->Void>   = new FlxTypedSignal<TouchButton->Void>();

	var storedButtonsIDs:Map<String, Array<MobileInputID>> = new Map();

	public function new(?extraMode:ExtraActions = NONE)
	{
		super();

		for (button in Reflect.fields(this)) {
			var field = Reflect.field(this, button);
			if (Std.isOfType(field, TouchButton))
				storedButtonsIDs.set(button, Reflect.getProperty(field, 'IDs'));
		}

		switch (extraMode) {
			case NONE:
				add(buttonLeft  = createHint(0,                         0, Std.int(FlxG.width / 4), FlxG.height, 0xFFC24B99));
				add(buttonDown  = createHint(FlxG.width / 4,            0, Std.int(FlxG.width / 4), FlxG.height, 0xFF00FFFF));
				add(buttonUp    = createHint(FlxG.width / 2,            0, Std.int(FlxG.width / 4), FlxG.height, 0xFF12FA05));
				add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, Std.int(FlxG.width / 4), FlxG.height, 0xFFF9393F));
			case SINGLE:
				add(buttonLeft  = createHint(0,                         offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFFC24B99));
				add(buttonDown  = createHint(FlxG.width / 4,            offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF00FFFF));
				add(buttonUp    = createHint(FlxG.width / 2,            offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF12FA05));
				add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFFF9393F));
				add(buttonExtra = createHint(0, offsetFir, FlxG.width, Std.int(FlxG.height / 4), 0xFF0066FF));
			case DOUBLE:
				add(buttonLeft   = createHint(0,                         offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFFC24B99));
				add(buttonDown   = createHint(FlxG.width / 4,            offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF00FFFF));
				add(buttonUp     = createHint(FlxG.width / 2,            offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF12FA05));
				add(buttonRight  = createHint((FlxG.width / 2) + (FlxG.width / 4), offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFFF9393F));
				add(buttonExtra2 = createHint(Std.int(FlxG.width / 2), offsetFir, Std.int(FlxG.width / 2), Std.int(FlxG.height / 4), 0xA6FF00));
				add(buttonExtra  = createHint(0, offsetFir, Std.int(FlxG.width / 2), Std.int(FlxG.height / 4), 0xFF0066FF));
		}

		for (button in Reflect.fields(this))
			if (Std.isOfType(Reflect.field(this, button), TouchButton))
				Reflect.setProperty(Reflect.getProperty(this, button), 'IDs', storedButtonsIDs.get(button));

		storedButtonsIDs.clear();
		scrollFactor.set();
		updateTrackedButtons();
		instance = this;
	}

	override function destroy() {
		super.destroy();
		onButtonUp.destroy();
		onButtonDown.destroy();
		for (fieldName in Reflect.fields(this)) {
			var field = Reflect.field(this, fieldName);
			if (Std.isOfType(field, TouchButton))
				Reflect.setField(this, fieldName, FlxDestroyUtil.destroy(field));
		}
	}

	private function createHint(X:Float, Y:Float, Width:Int, Height:Int, Color:Int = 0xFFFFFF):TouchButton {
		var hint = new TouchButton(X, Y);
		hint.statusAlphas = [];
		hint.statusIndicatorType = NONE;
		hint.loadGraphic(createHintGraphic(Width, Height));
		hint.label = new FlxSprite();
		hint.labelStatusDiff = ClientPrefs.data.controlsAlpha;
		hint.label.loadGraphic(createHintGraphic(Width, Math.floor(Height * 0.035), true));
		hint.label.offset.y += (hint.height - hint.label.height) / 2;

		var hintTween:FlxTween = null;
		var hintLaneTween:FlxTween = null;

		hint.onDown.callback = function() {
			onButtonDown.dispatch(hint);
			if (hintTween != null) hintTween.cancel();
			if (hintLaneTween != null) hintLaneTween.cancel();
			hintTween = FlxTween.tween(hint, {alpha: ClientPrefs.data.controlsAlpha}, ClientPrefs.data.controlsAlpha / 100, {ease: FlxEase.circInOut, onComplete: (_) -> hintTween = null});
			hintLaneTween = FlxTween.tween(hint.label, {alpha: 0.00001}, ClientPrefs.data.controlsAlpha / 10, {ease: FlxEase.circInOut, onComplete: (_) -> hintLaneTween = null});
		};
		hint.onOut.callback = hint.onUp.callback = function() {
			onButtonUp.dispatch(hint);
			if (hintTween != null) hintTween.cancel();
			if (hintLaneTween != null) hintLaneTween.cancel();
			hintTween = FlxTween.tween(hint, {alpha: 0.00001}, ClientPrefs.data.controlsAlpha / 10, {ease: FlxEase.circInOut, onComplete: (_) -> hintTween = null});
			hintLaneTween = FlxTween.tween(hint.label, {alpha: ClientPrefs.data.controlsAlpha}, ClientPrefs.data.controlsAlpha / 100, {ease: FlxEase.circInOut, onComplete: (_) -> hintLaneTween = null});
		};

		hint.immovable = hint.multiTouch = true;
		hint.solid = hint.moves = false;
		hint.alpha = 0.00001;
		hint.label.alpha = ClientPrefs.data.controlsAlpha;
		hint.canChangeLabelAlpha = false;
		hint.label.antialiasing = hint.antialiasing = ClientPrefs.data.antialiasing;
		hint.color = Color;
		return hint;
	}

	function createHintGraphic(Width:Int, Height:Int, ?isLane:Bool = false):FlxGraphic {
		var shape:Shape = new Shape();
		shape.graphics.lineStyle(3, 0xFFFFFF, 1);
		shape.graphics.drawRect(0, 0, Width, Height);
		shape.graphics.lineStyle(0, 0, 0);
		shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
		shape.graphics.endFill();
		if (isLane) shape.graphics.beginFill(0xFFFFFF);
		else shape.graphics.beginGradientFill(RADIAL, [0xFFFFFF, FlxColor.TRANSPARENT], [1, 0], [0, 255], null, null, null, 0.5);
		shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
		shape.graphics.endFill();
		var bitmap:BitmapData = new BitmapData(Width, Height, true, 0);
		bitmap.draw(shape);
		return FlxG.bitmap.add(bitmap);
	}
}
