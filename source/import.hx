package;

// FlxG and core
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.FlxBasic;
import flixel.FlxObject;

// Groups
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

// UI
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;

// Math / Tweens
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSave;
import flixel.util.FlxStringUtil;

// Effects
import flixel.effects.FlxFlicker;

// Sound
import flixel.sound.FlxSound;

// Addons
import flixel.addons.display.FlxRuntimeShader;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUISubState;

// OpenFL
import openfl.display.BlendMode;

// Sys (desktop/android only)
#if sys
import sys.io.File;
import sys.FileSystem;
#end

// Ecliptic backend
import backend.ClientPrefs;
import backend.Conductor;
import backend.CoolUtil;
import backend.Paths;
import backend.Song;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.Controls;

// Ecliptic states
import states.PlayState;
