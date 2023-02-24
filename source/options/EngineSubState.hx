package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class EngineSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Engine and Custom';
		rpcTitle = 'Engine & Custom Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Judgement Counter',
			"Displays a judgement counter if checked",
			'judgementCounter',
			'bool',
			true);
		addOption(option);

		#if MODS_ALLOWED
		var disabledMods:Array<String> = [];
		var modsListPath:String = 'modsList.txt';
		var directories:Array<String> = [Paths.mods()];
		var originalLength:Int = directories.length;
		if(sys.FileSystem.exists(modsListPath))
		{
			var stuff:Array<String> = CoolUtil.coolTextFile(modsListPath);
			for (i in 0...stuff.length)
			{
				var splitName:Array<String> = stuff[i].trim().split('|');
				if(splitName[1] == '0') // Disable mod
				{
					disabledMods.push(splitName[0]);
				}
				else // Sort mod loading order based on modsList.txt file
				{
					var path = haxe.io.Path.join([Paths.mods(), splitName[0]]);
					//trace('trying to push: ' + splitName[0]);
					if (sys.FileSystem.isDirectory(path) && !Paths.ignoreModFolders.contains(splitName[0]) && !disabledMods.contains(splitName[0]) && !directories.contains(path + '/'))
					{
						directories.push(path + '/');
						trace('pushed Directory: ' + splitName[0]);
					}
				}
			}
		}

		var modsDirectories:Array<String> = Paths.getModDirectories();
		for (folder in modsDirectories)
		{
			var pathThing:String = haxe.io.Path.join([Paths.mods(), folder]) + '/';
			if (!disabledMods.contains(folder) && !directories.contains(pathThing))
			{
				directories.push(pathThing);
				trace('pushed Directory: ' + folder);
			}
		}

		for (i in 0...directories.length)
		{
			var path = directories[i] + '/data/options.json';
			if(!sys.FileSystem.exists(path))
			{
				trace(directories[i] + ' doesn\'t have options');
				continue;
			}
			var jsonRaw = sys.io.File.getContent(path);
			var jsonMods:CustomOptionList = Json.parse(jsonRaw);
			
			for (opt in jsonMods.options)
			{
				var folderPath = directories[i].split('/');
				var folderName = folderPath[1];
				trace(folderName);
				
				var option:Option = new Option(opt.name,
				opt.description,
				opt.variable,
				opt.type,
				opt.value,
				opt.options,
				folderName);

				if(!ClientPrefs.customSettings.exists(folderName))
					ClientPrefs.customSettings.set(folderName, new Map<String, Dynamic>());

				var map = ClientPrefs.customSettings.get(folderName);
				if(!map.exists(opt.variable))
					map.set(opt.variable, opt.value);

				addOption(option);
			}
		}
		#end

		super();
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)));

		changedMusic = true;
	}

	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end
}

typedef CustomOptions = {
	name:String,
	description:String,
	variable:String,
	type:String,
	value:Dynamic,
	options:Null<Array<String>>,
}

typedef CustomOptionList = {
	options:Array<CustomOptions>
}