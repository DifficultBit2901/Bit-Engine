package editors;

import Character.CharacterGroupEntry;
import openfl.net.FileReference;
import haxe.Json;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUI;
import flixel.text.FlxText;
import flixel.FlxObject;
import flixel.addons.ui.FlxUIInputText;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxCamera;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUITabMenu;

class GroupEditorState extends MusicBeatState
{
    private var camEditor:FlxCamera;
	private var camHUD:FlxCamera;
	private var camMenu:FlxCamera;

    var leHealthIcon:HealthIcon;
	var characterList:Array<String> = [];

    var _file:FileReference;

	var cameraFollowPointer:FlxSprite;
	var healthBarBG:FlxSprite;

	var UI_box:FlxUITabMenu;
	var bgLayer:FlxTypedGroup<FlxSprite>;
	var charLayer:FlxTypedGroup<Character>;

    var groupOffset:Array<Float> = [0, 0];
    var camFollow:FlxObject;

	var blockPressWhileTypingOn:Array<FlxUIInputText> = [];

    var selectedChar:FlxText;

    public override function create()
    {
        super.create();

        camEditor = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camMenu = new FlxCamera();
		camMenu.bgColor.alpha = 0;

        FlxG.cameras.reset(camEditor);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camMenu, false);

        bgLayer = new FlxTypedGroup<FlxSprite>();
		add(bgLayer);

        var bg:BGSprite = new BGSprite('stageback', -600, -300, 0.9, 0.9);
        bgLayer.add(bg);

        var stageFront:BGSprite = new BGSprite('stagefront', -650, 500, 0.9, 0.9);
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        bgLayer.add(stageFront);

		charLayer = new FlxTypedGroup<Character>();
		add(charLayer);

		var pointer:FlxGraphic = FlxGraphic.fromClass(GraphicCursorCross);
		cameraFollowPointer = new FlxSprite().loadGraphic(pointer);
		cameraFollowPointer.setGraphicSize(40, 40);
		cameraFollowPointer.updateHitbox();
		cameraFollowPointer.color = FlxColor.WHITE;
		add(cameraFollowPointer);

        healthBarBG = new FlxSprite(30, FlxG.height - 75).loadGraphic(Paths.image('healthBar'));
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		healthBarBG.cameras = [camHUD];

		leHealthIcon = new HealthIcon('face', false);
		leHealthIcon.y = FlxG.height - 150;
		add(leHealthIcon);
		leHealthIcon.cameras = [camHUD];

        camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		var tipTextArray:Array<String> = "E/Q - Camera Zoom In/Out
		\nJKLI - Move Camera
		\nW/S - Previous/Next Character
		\nArrow Keys - Move Character Offset
		\nHold Shift to Move 10x faster\n".split('\n');

		for (i in 0...tipTextArray.length-1)
		{
			var tipText:FlxText = new FlxText(FlxG.width - 320, FlxG.height - 15 - 16 * (tipTextArray.length - i), 300, tipTextArray[i], 12);
			tipText.cameras = [camHUD];
			tipText.setFormat(null, 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
			tipText.scrollFactor.set();
			tipText.borderSize = 1;
			add(tipText);
		}

        selectedChar = new FlxText(0, 0, FlxG.width, 'None (0)', 12);
        selectedChar.setFormat(null, 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
        selectedChar.cameras = [camHUD];
        selectedChar.scrollFactor.set();
        selectedChar.borderSize = 1;
        add(selectedChar);

		FlxG.camera.follow(camFollow);

		var tabs = [
			//{name: 'Offsets', label: 'Offsets'},
			{name: 'Character', label: 'Character'},
            {name: 'Settings', label: 'Settings'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.cameras = [camMenu];

		UI_box.resize(320, 200);
		UI_box.x = 25;
		UI_box.y = 25;
		UI_box.scrollFactor.set();

		add(UI_box);

        createCharacterUI();
        createSettingsUI();

        FlxG.mouse.visible = true;
    }

	var charName:FlxUIInputText;
    var check_player:FlxUICheckBox;

    function createCharacterUI()
    {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Character";

        charName = new FlxUIInputText(10, 25, 300, '', 12, 0xFF000000, 0xFFFFFFFF);
        var addCharButton = new FlxUIButton(charName.x, charName.y + 25, 'Add Char', function(){
            var char = new Character(0, 0, charName.text, check_player.checked);
            charLayer.add(char);
        });

        var removeCharButton = new FlxUIButton(addCharButton.x + 100, addCharButton.y, 'Remove Char', function(){
            if(charLayer.length < 1) return;
            var char = charLayer.members[curChar];
            charLayer.remove(char, true);
            changeChar(-1);
        });
        
        check_player = new FlxUICheckBox(removeCharButton.x + 100, addCharButton.y, null, null, "Playable Group", 100);
		check_player.checked = false;
		check_player.callback = function()
		{
            charLayer.forEach(function(char:Character){
                char.isPlayer = !char.isPlayer;
            });
		};

        blockPressWhileTypingOn.push(charName);

        tab_group.add(new FlxText(charName.x, charName.y - 20, 0, 'Character Name:', 12));

        tab_group.add(charName);
        tab_group.add(addCharButton);
        tab_group.add(removeCharButton);
        tab_group.add(check_player);

        UI_box.addGroup(tab_group);
    }

    var healthColorStepperR:FlxUINumericStepper;
    var healthColorStepperG:FlxUINumericStepper;
    var healthColorStepperB:FlxUINumericStepper;
    var healthIconInputText:FlxUIInputText;

    var camOffsetXStepper:FlxUINumericStepper;
    var camOffsetYStepper:FlxUINumericStepper;
    function createSettingsUI()
    {
        var tab_group = new FlxUI(null, UI_box);
        tab_group.name = "Settings";

        var decideIconColor:FlxUIButton = new FlxUIButton(10, 20, "Get Icon Color", function()
			{
				var coolColor = FlxColor.fromInt(CoolUtil.dominantColor(leHealthIcon));
				healthColorStepperR.value = coolColor.red;
				healthColorStepperG.value = coolColor.green;
				healthColorStepperB.value = coolColor.blue;
				getEvent(FlxUINumericStepper.CHANGE_EVENT, healthColorStepperR, null);
				getEvent(FlxUINumericStepper.CHANGE_EVENT, healthColorStepperG, null);
				getEvent(FlxUINumericStepper.CHANGE_EVENT, healthColorStepperB, null);
			});

		healthIconInputText = new FlxUIInputText(decideIconColor.x + 100, decideIconColor.y, 75, '', 12);
        blockPressWhileTypingOn.push(healthIconInputText);

        healthColorStepperR = new FlxUINumericStepper(decideIconColor.x, decideIconColor.y + 40, 20, 0, 0, 255, 0);
		healthColorStepperG = new FlxUINumericStepper(decideIconColor.x + 65, healthColorStepperR.y, 20, 0, 0, 255, 0);
		healthColorStepperB = new FlxUINumericStepper(decideIconColor.x + 130, healthColorStepperR.y, 20, 0, 0, 255, 0);

        camOffsetXStepper = new FlxUINumericStepper(decideIconColor.x, healthColorStepperR.y + 40, 1, 0, -1000, 1000, 2);
        camOffsetYStepper = new FlxUINumericStepper(decideIconColor.x + 65, healthColorStepperR.y + 40, 1, 0, -1000, 1000, 2);

        var saveCharacterButton:FlxUIButton = new FlxUIButton(camOffsetXStepper.x, camOffsetXStepper.y + 40, "Save Group", function() {
			saveCharacter();
		});

        tab_group.add(new FlxText(healthColorStepperR.x, healthColorStepperR.y - 20, 0, 'Health Bar Color (RGB):', 12));
        tab_group.add(new FlxText(healthIconInputText.x, healthIconInputText.y - 20, 0, 'Group Icon:', 12));
        tab_group.add(new FlxText(camOffsetXStepper.x, camOffsetXStepper.y - 20, 0, 'Camera Offset:', 12));

        tab_group.add(healthColorStepperR);
        tab_group.add(healthColorStepperG);
        tab_group.add(healthColorStepperB);
        tab_group.add(healthIconInputText);
        tab_group.add(decideIconColor);
        tab_group.add(camOffsetYStepper);
        tab_group.add(camOffsetXStepper);
        tab_group.add(saveCharacterButton);

        UI_box.addGroup(tab_group);
    }

    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
        if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
        {
            if([healthColorStepperB, healthColorStepperG, healthColorStepperR].contains(sender))
            {
				healthBarBG.color = FlxColor.fromRGB(Std.int(healthColorStepperR.value), Std.int(healthColorStepperG.value), Std.int(healthColorStepperB.value));
            }
            else if([camOffsetXStepper, camOffsetYStepper].contains(sender))
            {
                groupOffset = [camOffsetXStepper.value, camOffsetYStepper.value];
            }
        }
        else if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
			if(sender == healthIconInputText) {
				leHealthIcon.changeIcon(healthIconInputText.text);
			}
        }
    }

    function saveCharacter()
    {
        if(charLayer.length < 1) return;
        var json = {
            "group": [],
            "icon": leHealthIcon.getCharacter(),
            "healthBarColors": [Std.int(healthColorStepperR.value), Std.int(healthColorStepperG.value), Std.int(healthColorStepperB.value)],
            "cam_offset": [camOffsetXStepper.value, camOffsetYStepper.value]
		};

        charLayer.forEach(function(char:Character){
            var entry:CharacterGroupEntry = {
                "name": char.curCharacter,
                "position": [char.x, char.y]
            }
            json.group.push(entry);
        });

		var data:String = Json.stringify(json, "\t");

        if (data.length > 0)
        {
            _file = new FileReference();
            _file.addEventListener(Event.COMPLETE, onSaveComplete);
            _file.addEventListener(Event.CANCEL, onSaveCancel);
            _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file.save(data, charLayer.members[0].curCharacter + "-group.json");
        }
    }

    override function update(elapsed:Float)
    {
        var charName = charLayer.length < 1 ? 'None' : charLayer.members[curChar].curCharacter;
        selectedChar.text = '$charName ($curChar)';
        
        var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn) {
			if(inputText.hasFocus) {
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				blockInput = true;

				if(FlxG.keys.justPressed.ENTER) inputText.hasFocus = false;
				break;
			}
		}

		if(!blockInput) {
			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
            var shiftMult = FlxG.keys.pressed.SHIFT ? 10 : 1;
			if(FlxG.keys.justPressed.ESCAPE) {
				MusicBeatState.switchState(new editors.MasterEditorMenu());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
            else if(FlxG.keys.justPressed.W)
                changeChar(1);
            else if(FlxG.keys.justPressed.S)
                changeChar(-1);
            if(FlxG.keys.pressed.J)
                camFollow.x -= shiftMult;
            if(FlxG.keys.pressed.L)
                camFollow.x += shiftMult;
            if(FlxG.keys.pressed.I)
                camFollow.y -= shiftMult;
            if(FlxG.keys.pressed.K)
                camFollow.y += shiftMult;
            if(FlxG.keys.pressed.Q)
                camEditor.zoom -= 0.01 * shiftMult;
            if(FlxG.keys.pressed.E)
                camEditor.zoom += 0.01 * shiftMult;
            if(charLayer.length > 0)
            {
                var char = charLayer.members[curChar];
                if(FlxG.keys.justPressed.LEFT)
                    char.x -= shiftMult;
                if(FlxG.keys.justPressed.UP)
                    char.y -= shiftMult;
                if(FlxG.keys.justPressed.DOWN)
                    char.y += shiftMult;
                if(FlxG.keys.justPressed.RIGHT)
                    char.x += shiftMult;
            }
		}

        super.update(elapsed);

        updatePointerPos();
    }

    override function beatHit()
    {
        super.beatHit();

        charLayer.forEach(function(char:Character){
            if(curBeat % char.danceEveryNumBeats == 0)
                char.dance();
        });
    }

    function updatePointerPos() {
        if(charLayer.length < 1)
            return;
            
        var char = charLayer.members[0];
		var x:Float = char.getMidpoint().x;
		var y:Float = char.getMidpoint().y;
		if(!char.isPlayer) {
			x += 150 + char.cameraPosition[0];
		} else {
			x -= 100 + char.cameraPosition[0];
		}
		y -= 100 - char.cameraPosition[1];

		x -= cameraFollowPointer.width / 2;
		y -= cameraFollowPointer.height / 2;
        x += groupOffset[0];
        y += groupOffset[1];
		cameraFollowPointer.setPosition(x, y);
	}

    var curChar = 0;
    function changeChar(change:Int)
    {
        if(charLayer.length < 1)
            return;
        curChar += change;
        if(curChar >= charLayer.length)
            curChar = 0;
        else if(curChar < 0)
            curChar = charLayer.length - 1;
    }

    function onSaveComplete(_):Void
        {
            _file.removeEventListener(Event.COMPLETE, onSaveComplete);
            _file.removeEventListener(Event.CANCEL, onSaveCancel);
            _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file = null;
            FlxG.log.notice("Successfully saved file.");
        }
    
        /**
            * Called when the save file dialog is cancelled.
            */
        function onSaveCancel(_):Void
        {
            _file.removeEventListener(Event.COMPLETE, onSaveComplete);
            _file.removeEventListener(Event.CANCEL, onSaveCancel);
            _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file = null;
        }
    
        /**
            * Called if there is an error while saving the gameplay recording.
            */
        function onSaveError(_):Void
        {
            _file.removeEventListener(Event.COMPLETE, onSaveComplete);
            _file.removeEventListener(Event.CANCEL, onSaveCancel);
            _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file = null;
            FlxG.log.error("Problem saving file");
        }
}