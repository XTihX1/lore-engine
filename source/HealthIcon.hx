package;

import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.math.FlxMath;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	public var isPlayer:Bool = false;
	private var char:String = '';
	public var afterNew:Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false, ?hasVictory:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char, hasVictory);
		scrollFactor.set();
		afterNew = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	private var iconOffsets:Array<Float> = [0, 0];
	private var initHeight:Float;
	public function changeIcon(char:String, ?hasVictory:Bool = false) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			var file:Dynamic = Paths.image(name);

			loadGraphic(file); //Load stupidly first for getting the file size
			loadGraphic(file, true, Math.floor(hasVictory ? width / 3 : width / 2), Math.floor(height)); //Then load it fr

			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (width - 150) / 2;
			initHeight = height / (afterNew && PlayState.inPlayState ? PlayState.instance.iconSize : 1);

			updateHitbox();

			animation.add(char, (hasVictory ? [0, 1, 2] : [0, 1]), 0, false, isPlayer);
			animation.play(char);
			this.char = char;

			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel')) {
				antialiasing = false;
			}
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = (ClientPrefs.bopStyle != "PSYCH-OLD" ? iconOffsets[1] : ((initHeight * (PlayState.inPlayState ? PlayState.instance.iconSize : 1) / 2) - (height / 2)));
	}
	

	public function runScaleUpdate(elapsed:Float):Void {
		var _modifier:Float = (ClientPrefs.bopStyle == "PSYCH-OLD" ? 30 / 9 : 1);
		var multx:Float = FlxMath.lerp(PlayState.instance.iconSize, scale.x, CoolUtil.boundTo(1 - (elapsed * (9 * _modifier * PlayState.instance.headBopSpeed)), 0, 1));
		var multy:Float = FlxMath.lerp(PlayState.instance.iconSize, scale.y, CoolUtil.boundTo(1 - (elapsed * (9 * _modifier * PlayState.instance.headBopSpeed)), 0, 1));
		scale.set(multx, multy);
		updateHitbox();
	}

	public function bopIcon(?beatMod:Bool = false, cname:String):Void {
		var ret:Array<Dynamic> = [PlayState.instance.callOnLuas('onHeadBop', [cname]), PlayState.instance.callOnHaxes('onHeadBop', [cname])];
		if (!ret.contains(FunkinLua.Function_Stop) && !ClientPrefs.optimization && PlayState.instance.headsBop) switch (ClientPrefs.bopStyle) {
			case "LORE":
				if(!beatMod) scale.set(PlayState.instance.iconSize * 1.2, PlayState.instance.iconSize * 1.2) else scale.set(PlayState.instance.iconSize * 0.8, PlayState.instance.iconSize * 0.8);
				updateHitbox();
			case "PSYCH" | "REACTIVE" | "PSYCH-OLD":
				scale.set(PlayState.instance.iconSize * 1.2, PlayState.instance.iconSize * 1.2);
				updateHitbox();
		}
	}

	public function getCharacter():String {
		return char;
	}
}
