package states;

import flixel.addons.transition.FlxTransitionableState;
import objects.Character;
import objects.Note;
import objects.StrumNote;
import objects.HealthIcon;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState;
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyDifficulty:Int = 1;
	public static var storyWeek:Int = 0;
	public static var stageUI:String = 'normal';

	// Cameras
	var camGame:FlxCamera;
	var camHUD:FlxCamera;
	var camOther:FlxCamera;

	// Characters
	var boyfriend:Character;
	var dad:Character;
	var gf:Character;

	// Strums
	var opponentStrums:FlxTypedGroup<StrumNote>;
	var playerStrums:FlxTypedGroup<StrumNote>;
	var grpNoteSplashes:FlxTypedGroup<FlxSprite>;

	// Notes
	var notes:FlxTypedGroup<Note>;
	var unspawnNotes:Array<Note> = [];

	// Health
	var health:Float     = 1.0;
	var maxHealth:Float  = 2.0;

	// Health bar
	var healthBarBG:FlxSprite;
	var healthBar:FlxBar;
	var iconP1:HealthIcon;
	var iconP2:HealthIcon;

	// Score
	var songScore:Int    = 0;
	var songMisses:Int   = 0;
	var songHits:Int     = 0;
	var totalNotes:Int   = 0;
	var combo:Int        = 0;
	var accuracy:Float   = 0;

	// UI text
	var scoreTxt:FlxText;

	// State
	var startingSong:Bool = true;
	var paused:Bool       = false;
	var generatedMusic:Bool = false;
	var inCutscene:Bool   = false;
	var songSpeed:Float   = 1.0;

	override function create()
	{
		instance = this;
		FlxTransitionableState.skipNextTransIn  = true;
		FlxTransitionableState.skipNextTransOut = true;

		super.create();

		if (SONG == null) SONG = Song.loadFromJson('test', 'normal');

		// ── Cameras ──────────────────────────────────────────────
		camGame  = new FlxCamera();
		camHUD   = new FlxCamera(); camHUD.bgColor.alpha = 0;
		camOther = new FlxCamera(); camOther.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD,   false);
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		// ── Stage background (week1) ──────────────────────────────
		var stageback = new FlxSprite(-600, -200).loadGraphic(Paths.stageImage('week1', 'stageback'));
		if (stageback.graphic != null) { stageback.scrollFactor.set(0.9, 0.9); stageback.antialiasing = ClientPrefs.data.antialiasing; add(stageback); }

		var stagefront = new FlxSprite(-650, 600).loadGraphic(Paths.stageImage('week1', 'stagefront'));
		if (stagefront.graphic != null) { stagefront.scrollFactor.set(0.9, 0.9); stagefront.setGraphicSize(Std.int(stagefront.width * 1.1)); stagefront.updateHitbox(); stagefront.antialiasing = ClientPrefs.data.antialiasing; add(stagefront); }

		// ── Characters ───────────────────────────────────────────
		gf = new Character(400, 130, SONG.gfVersion != null ? SONG.gfVersion : 'gf', false);
		gf.scrollFactor.set(0.95, 0.95);
		add(gf);

		dad = new Character(100, 350, SONG.player2, false);
		add(dad);

		boyfriend = new Character(770, 450, SONG.player1, true);
		add(boyfriend);

		var stagecurtains = new FlxSprite(-500, -300).loadGraphic(Paths.stageImage('week1', 'stagecurtains'));
		if (stagecurtains.graphic != null) { stagecurtains.scrollFactor.set(1.3, 1.3); stagecurtains.setGraphicSize(Std.int(stagecurtains.width * 0.9)); stagecurtains.updateHitbox(); stagecurtains.antialiasing = ClientPrefs.data.antialiasing; add(stagecurtains); }

		// ── Note groups ──────────────────────────────────────────
		notes          = new FlxTypedGroup<Note>();
		grpNoteSplashes = new FlxTypedGroup<FlxSprite>();
		notes.cameras          = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		add(notes);
		add(grpNoteSplashes);

		// ── Strumlines ───────────────────────────────────────────
		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums   = new FlxTypedGroup<StrumNote>();
		opponentStrums.cameras = [camHUD];
		playerStrums.cameras   = [camHUD];
		add(opponentStrums);
		add(playerStrums);

		generateStrums();
		generateSong();

		// ── Health bar ───────────────────────────────────────────
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image(Paths.funkinPath('images/objects/healthBar')));
		if (healthBarBG.graphic == null) healthBarBG.makeGraphic(600, 20, FlxColor.BLACK);
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.cameras = [camHUD];
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, maxHealth);
		healthBar.createFilledBar(
			(dad != null && dad.healthColorArray.length >= 3) ? FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]) : FlxColor.RED,
			(boyfriend != null && boyfriend.healthColorArray.length >= 3) ? FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]) : FlxColor.LIME
		);
		healthBar.scrollFactor.set();
		healthBar.cameras = [camHUD];
		add(healthBar);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.cameras = [camHUD];
		iconP1.scrollFactor.set();
		iconP1.y = healthBarBG.y - 30;
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.cameras = [camHUD];
		iconP2.scrollFactor.set();
		iconP2.y = healthBarBG.y - 30;
		add(iconP2);

		// ── Score text ───────────────────────────────────────────
		scoreTxt = new FlxText(FlxG.width / 2 - 300, healthBarBG.y + 30, 600, '', 20);
		scoreTxt.setFormat('VCR OSD Mono', 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.cameras = [camHUD];
		add(scoreTxt);
		updateScoreText();

		// ── Mobile ───────────────────────────────────────────────
		#if mobile
		addTouchPad('NONE', 'A_B');
		addTouchPadCamera();
		#end

		// ── Start countdown ──────────────────────────────────────
		startCountdown();
	}

	function generateStrums()
	{
		var strumY:Float = ClientPrefs.data.downScroll ? FlxG.height - 150 : 50;

		for (i in 0...4)
		{
			var noteX = ClientPrefs.data.middleScroll ? (FlxG.width / 2 - Note.swagWidth * 2 + Note.swagWidth * i)
				: (56 + Note.swagWidth * i);
			var strumNote = new StrumNote(noteX, strumY, i, 0);
			strumNote.scrollFactor.set();
			opponentStrums.add(strumNote);
			// Intro tween
			var strum = strumNote;
			strum.y -= 10;
			strum.alpha = 0;
			FlxTween.tween(strum, {y: strumY, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
		}

		for (i in 0...4)
		{
			var noteX = ClientPrefs.data.middleScroll ? (FlxG.width / 2 - Note.swagWidth * 2 + Note.swagWidth * i)
				: (FlxG.width - 570 + Note.swagWidth * i);
			var strumNote = new StrumNote(noteX, strumY, i, 1);
			strumNote.scrollFactor.set();
			playerStrums.add(strumNote);
			var strum = strumNote;
			strum.y -= 10;
			strum.alpha = 0;
			FlxTween.tween(strum, {y: strumY, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * (i + 4))});
		}
	}

	function generateSong()
	{
		songSpeed = SONG.speed;
		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;

		for (sec in SONG.notes)
		{
			for (songNotes in sec.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int    = Std.int(songNotes[1] % 4);
				var daSus:Float       = songNotes[2];
				var gottaHitNote:Bool = sec.mustHitSection;

				// Player notes: 0-3 on mustHit=true, or 4-7 always
				if (songNotes[1] > 3) gottaHitNote = !sec.mustHitSection;

				var note = new Note(daStrumTime, daNoteData);
				note.mustPress     = gottaHitNote;
				note.sustainLength = daSus;
				note.scrollFactor.set();
				unspawnNotes.push(note);
			}
		}
		unspawnNotes.sort(function(a, b) return Std.int(a.strumTime - b.strumTime));
		generatedMusic = true;
	}

	var countdownTimer:FlxTimer;
	var startedCountdown:Bool = false;

	function startCountdown()
	{
		startedCountdown = true;
		Conductor.songPosition = -(Conductor.crochet * 5);

		var swagCounter:Int = 0;
		countdownTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			switch (swagCounter)
			{
				case 2: // "ready"
					var ready = new FlxSprite().loadGraphic(Paths.image(Paths.funkinPath('images/objects/ready')));
					if (ready.graphic != null) { ready.screenCenter(); ready.cameras = [camHUD]; ready.scrollFactor.set(); add(ready); FlxTween.tween(ready, {alpha: 0}, Conductor.crochet / 1000, {onComplete: function(_) ready.destroy()}); }
				case 3: // "set"
					var set = new FlxSprite().loadGraphic(Paths.image(Paths.funkinPath('images/objects/set')));
					if (set.graphic != null) { set.screenCenter(); set.cameras = [camHUD]; set.scrollFactor.set(); add(set); FlxTween.tween(set, {alpha: 0}, Conductor.crochet / 1000, {onComplete: function(_) set.destroy()}); }
				case 4: // "go"
					var go = new FlxSprite().loadGraphic(Paths.image(Paths.funkinPath('images/objects/go')));
					if (go.graphic != null) { go.screenCenter(); go.cameras = [camHUD]; go.scrollFactor.set(); add(go); FlxTween.tween(go, {alpha: 0}, Conductor.crochet / 1000, {onComplete: function(_) go.destroy()}); }
					startSong();
			}
			swagCounter++;
		}, 5);
	}

	function startSong()
	{
		startingSong = false;
		var inst = Paths.inst(SONG.song);
		if (inst != null)
			FlxG.sound.playMusic(inst, 1, false);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (startedCountdown && !paused)
		{
			if (startingSong)
				Conductor.songPosition += elapsed * 1000;
			else
				Conductor.songPosition = FlxG.sound.music != null ? FlxG.sound.music.time + ClientPrefs.data.noteOffset : Conductor.songPosition;
		}

		// Spawn notes
		if (generatedMusic && unspawnNotes.length > 0)
		{
			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < 2000)
			{
				var dunNote = unspawnNotes.shift();
				notes.add(dunNote);
			}
		}

		// Move and hit/miss notes
		notes.forEachAlive(function(daNote:Note)
		{
			var strumGroup = daNote.mustPress ? playerStrums : opponentStrums;
			var strumX = strumGroup.members[daNote.noteData].x;
			var strumY = strumGroup.members[daNote.noteData].y;

			var noteDiff = daNote.strumTime - Conductor.songPosition;
			var scrollDir:Float = ClientPrefs.data.downScroll ? 1 : -1;
			daNote.y = strumY + (scrollDir * (-0.45 * noteDiff * songSpeed));
			daNote.x = strumX;

			// Auto-play opponent
			if (!daNote.mustPress && noteDiff <= 0 && !daNote.wasGoodHit)
			{
				opponentNoteHit(daNote);
			}

			// Player miss if too late
			var safeZone = Conductor.safeZoneOffset > 0 ? Conductor.safeZoneOffset : 180;
			if (daNote.mustPress && noteDiff < -safeZone && !daNote.wasGoodHit)
			{
				noteMiss(daNote.noteData);
				daNote.tooLate = true;
				daNote.wasGoodHit = true;
			}

			// Kill when off screen
			if (daNote.wasGoodHit && (ClientPrefs.data.downScroll ? daNote.y > FlxG.height + 200 : daNote.y < -200))
				daNote.kill();
		});

		// Player input
		if (!paused) playerInput();

		// Icon health animation
		var iconP1HealthLerp = FlxMath.lerp(iconP1.x, healthBar.x + (healthBar.width * (health / maxHealth)) - 26, CoolUtil.boundTo(elapsed * 9, 0, 1));
		iconP1.x = iconP1HealthLerp;
		iconP2.x = healthBar.x + (healthBar.width * (health / maxHealth)) - (iconP2.width - 26);

		// ESC = pause
		var shouldPause = controls.PAUSE;
		#if mobile
		if (touchPad != null && touchPad.buttonB.justPressed) shouldPause = true;
		#end
		if (shouldPause) openPauseMenu();

		// End song
		if (FlxG.sound.music != null && !FlxG.sound.music.playing && !startingSong && !paused)
			endSong();
	}

	function playerInput()
	{
		var keys = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
		var held  = [controls.NOTE_LEFT,  controls.NOTE_DOWN,  controls.NOTE_UP,  controls.NOTE_RIGHT];
		var rel   = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];

		for (i in 0...4)
		{
			if (keys[i]) playerStrums.members[i].playAnim('pressed');
			if (rel[i])  playerStrums.members[i].playAnim('static');
		}

		notes.forEachAlive(function(daNote:Note)
		{
			if (!daNote.mustPress || daNote.wasGoodHit || daNote.tooLate) return;
			var safeZone = Conductor.safeZoneOffset > 0 ? Conductor.safeZoneOffset : 180;
			var noteDiff = Math.abs(daNote.strumTime - Conductor.songPosition);

			if (noteDiff < safeZone && keys[daNote.noteData])
				goodNoteHit(daNote);
		});

		if (!ClientPrefs.data.ghostTapping)
		{
			for (i in 0...4)
			{
				var pressedWithNoNote = keys[i];
				if (pressedWithNoNote)
				{
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.mustPress && !daNote.wasGoodHit && daNote.noteData == i)
							pressedWithNoNote = false;
					});
					if (pressedWithNoNote) noteMiss(i);
				}
			}
		}
	}

	function goodNoteHit(note:Note)
	{
		if (note.wasGoodHit) return;
		note.wasGoodHit = true;

		health = Math.min(health + 0.023, maxHealth);
		songScore += 350;
		combo++;
		songHits++;
		totalNotes++;

		playerStrums.members[note.noteData].playAnim('confirm', true);
		boyfriend.playAnim('sing' + ['LEFT', 'DOWN', 'UP', 'RIGHT'][note.noteData], true);
		boyfriend.holdTimer = 0;

		note.kill();
		updateScoreText();
	}

	function opponentNoteHit(note:Note)
	{
		note.wasGoodHit = true;
		dad.playAnim('sing' + ['LEFT', 'DOWN', 'UP', 'RIGHT'][note.noteData], true);
		dad.holdTimer = 0;
		note.kill();
	}

	function noteMiss(noteData:Int)
	{
		health = Math.max(health - 0.0475, 0);
		songMisses++;
		combo = 0;
		totalNotes++;

		if (boyfriend != null && boyfriend.hasMissAnimations)
			boyfriend.playAnim('sing' + ['LEFT', 'DOWN', 'UP', 'RIGHT'][noteData] + 'miss', true);

		updateScoreText();
	}

	function updateScoreText()
	{
		accuracy = totalNotes > 0 ? Math.round((songHits / totalNotes) * 10000) / 100 : 0;
		scoreTxt.text = 'Score: $songScore | Misses: $songMisses | Accuracy: $accuracy%';
	}

	override function beatHit()
	{
		super.beatHit();
		if (boyfriend != null && curBeat % boyfriend.danceEveryNumBeats == 0) boyfriend.dance();
		if (dad != null && curBeat % dad.danceEveryNumBeats == 0) dad.dance();
		if (gf != null && curBeat % gf.danceEveryNumBeats == 0) gf.dance();
	}

	function openPauseMenu()
	{
		paused = true;
		if (FlxG.sound.music != null) FlxG.sound.music.pause();
		openSubState(new substates.PauseSubState());
	}

	function endSong()
	{
		Highscore.saveScore(SONG.song, 'normal', songScore, songMisses, accuracy);
		if (isStoryMode) MusicBeatState.switchState(new StoryMenuState());
		else MusicBeatState.switchState(new FreeplayState());
	}
}
