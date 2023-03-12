package scenes;

import entities.*;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.graphics.text.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import openfl.Assets;

class GameScene extends Scene
{
    public static inline var GAME_WIDTH = 320;
    public static inline var GAME_HEIGHT = 180;
    public static inline var EXTEND_LEVEL_BUFFER = 100;
    public static inline var HEAVEN_HEIGHT = 200;
    public static inline var LAIR_AND_EARTH_DEPTH = GAME_HEIGHT + 50;
    public static inline var SPECIAL_LEVEL_INTERVAL = 5;
    //public static inline var SPECIAL_LEVEL_INTERVAL = 2;

    public static var staticZones:Array<String> = ["pot", "bedroom", "lair", "swordroom"];
    public static var specialLevels:Array<String> = ["earth_nest", "heaven_shrine", "hell_ogre"];
    public static var exitedPot:Bool = false;
    public static var wokeUp:Bool = false;
    public static var dreamDepth:Int = 0;
    public static var bedDepths:Array<Int> = [];
    public static var totalTime:Float = 0;

    public static var debugMode:Bool = false;
    private var debugModeIndicator:Text;

    public static var sfx:Map<String, Sfx> = null;

    public var zone(default, null):String;
    private var player:Player;
    private var levels:Array<Level>;
    private var maxCameraX:Float;

    public function new(zone:String) {
        super();
        this.zone = zone;
        if(sfx == null) {
            sfx = [
                "chicken_alert" => new Sfx("audio/chicken_alert.ogg"),
                "chicken_lay" => new Sfx("audio/chicken_lay.ogg"),
                "jump" => new Sfx("audio/jump.ogg"),
                "eat" => new Sfx("audio/eat.ogg"),
                "dragonhatch" => new Sfx("audio/dragonhatch.ogg"),
                "dragonfly" => new Sfx("audio/dragonfly.ogg"),
                "takehit" => new Sfx("audio/takehit.ogg"),
                "flap" => new Sfx("audio/flap.ogg"),
                "run" => new Sfx("audio/run.ogg"),
                "potcrack" => new Sfx("audio/potcrack.ogg"),
                "potbreak" => new Sfx("audio/potbreak.ogg"),
                "fall" => new Sfx("audio/fall.ogg"),
                "land" => new Sfx("audio/land.ogg"),
                "whoosh" => new Sfx("audio/whoosh.ogg"),
                "spikeland" => new Sfx("audio/spikeland.ogg"),
                "ogre" => new Sfx("audio/ogre.ogg"),
                "enterpot" => new Sfx("audio/enterpot.ogg"),
                "exitpot" => new Sfx("audio/exitpot.ogg"),
                "satandeath" => new Sfx("audio/satandeath.ogg"),
                "shatter" => new Sfx("audio/shatter.ogg"),
                "pickup" => new Sfx("audio/pickup.ogg"),
                "pickupsword" => new Sfx("audio/pickupsword.ogg"),
                "toss" => new Sfx("audio/toss.ogg"),
                "die" => new Sfx("audio/die.ogg"),
                "wakeup" => new Sfx("audio/wakeup.ogg"),
                "dream" => new Sfx("audio/dream.ogg"),
                "enemydie" => new Sfx("audio/enemydie.ogg"),
                "mount" => new Sfx("audio/mount.ogg"),
                "dismount" => new Sfx("audio/dismount.ogg"),
                "spikeactivate" => new Sfx("audio/spikeactivate.ogg"),
                "spikedeactivate" => new Sfx("audio/spikedeactivate.ogg"),
                "spikewarning" => new Sfx("audio/spikewarning.ogg"),
                "music_earth1" => new Sfx("audio/music_earth1.ogg"),
                "music_earth1_alt" => new Sfx("audio/music_earth1_alt.ogg"),
                "music_earth2" => new Sfx("audio/music_earth2.ogg"),
                "music_earth3" => new Sfx("audio/music_earth3.ogg"),
                "music_earth4" => new Sfx("audio/music_earth4.ogg"),
                "music_hell" => new Sfx("audio/music_hell.ogg"),
                "music_heaven" => new Sfx("audio/music_heaven.ogg"),
                "music_satan" => new Sfx("audio/music_satan.ogg"),
                "bless" => new Sfx("audio/bless.ogg"),
                "cook" => new Sfx("audio/cook.ogg")
            ];
        }
    }

    private function stopAllLoopingSounds() {
        for(sfx in sfx) {
            if(sfx.looping) {
                sfx.stop();
            }
        }
    }

    private function startMusic() {
        if(zone == "earth") {
            var suffix = '${MathUtil.clamp(bedDepths.length, 1, 4)}';
            if(suffix == '1') {
                suffix = HXP.choose('1', '1_alt');
            }
            GameScene.sfx['music_earth${suffix}'].loop();
        }
        else if(zone == "hell") {
            GameScene.sfx["music_hell"].loop();
        }
        else if(zone == "heaven") {
            GameScene.sfx["music_heaven"].loop();
        }
        else if(zone == "lair") {
            GameScene.sfx["music_satan"].loop();
        }
    }

	override public function resume() {
        stopAllLoopingSounds();
        startMusic();
        if(Player.carrying != null) {
            player.addCarriedItem(new Vector2(
                player.centerX - Math.floor(Player.carrying.width / 2),
                player.y
            ));
        }
        player.addRiding();
        if(zone == "bedroom") {
            if(typeCount("egg") == 0) {
                add(new Egg(levels[0].eggStart.x, levels[0].eggStart.y));
            }
        }
        if(zone == "pot" && player.bottom < 0) {
            player.moveTo(levels[0].playerStart.x, levels[0].playerStart.y);
            player.velocity.setTo(0, 0);
        }
        if(GameScene.exitedPot) {
            player.exitPot();
            GameScene.exitedPot = false;
        }
        else if(GameScene.wokeUp) {
            player.wakeUp();
            GameScene.wokeUp = false;
        }
    }

    override public function begin() {
        debugModeIndicator = new Text("INVINCIBILITY ON");
        debugModeIndicator.scrollX = 0;
        addGraphic(debugModeIndicator, -99999);

        stopAllLoopingSounds();
        startMusic();
        if(zone == "earth") {
            var bgNum = MathUtil.clamp(bedDepths.length, 1, 4);
            var bg = new Backdrop('graphics/EARTH_BG0${bgNum}.png');
            bg.scrollX = 0.5;
            addGraphic(bg, 99);
        }
        else if(zone == "hell") {
            var bg = new Backdrop('graphics/HELL_BG.png');
            bg.scrollX = 0.5;
            addGraphic(bg, 99);
        }
        else if(zone == "heaven") {
            var bg = new Backdrop('graphics/HEAVEN_BG.png');
            bg.scrollX = 0.5;
            addGraphic(bg, 99);
        }
        else if(zone == "pot") {
            var bg = new Backdrop('graphics/INSIDE_POT_BG.png');
            addGraphic(bg, 99);
        }
        else if(zone == "bedroom") {
            var bg = new Backdrop('graphics/BEDROOM_BG.png');
            addGraphic(bg, 99);
        }
        else if(zone == "swordroom") {
            var bg = new Backdrop('graphics/swordroomBG.png');
            addGraphic(bg, 99);
        }
        levels = [];
        addLevel(zone);
    }

    override public function update() {
        if(zone == "bedroom") {
            player.maxOutHealth();
            GameScene.totalTime = 0;
        }
        else {
            GameScene.totalTime += HXP.elapsed;
        }

        debugModeIndicator.alpha = debugMode ? 1 : 0;
        if(Key.pressed(Key.P)) {
            //debugMode = !debugMode;
        }
        super.update();

        if(!isStaticZone()) {
            camera.x = Math.max(player.centerX - GAME_WIDTH / 3, maxCameraX);
            maxCameraX = Math.max(camera.x, maxCameraX);
            if(camera.x + GAME_WIDTH + EXTEND_LEVEL_BUFFER > getTotalWidthOfLevels()) {
                //addLevel("earth_nest");
                //addLevel("heaven_shrine");
                //addLevel("hell_ogre");
                //addLevel("earth");
                if(levels.length % SPECIAL_LEVEL_INTERVAL == 0) {
                    var specialLevel = [
                        "earth" => "earth_nest",
                        "hell" => "hell_ogre",
                        "heaven" => "heaven_shrine"
                    ][zone];
                    addLevel(specialLevel);
                }
                else {
                    addLevel(zone);
                }
            }
        }
        camera.y = zone == "pot" ? GameScene.GAME_HEIGHT : 0;

        if(zone == "pot" && player.bottom < GameScene.GAME_HEIGHT) {
            player.removeCarriedItem();
            player.x = GameScene.GAME_WIDTH / 2 - player.width / 2;
            player.y = GameScene.GAME_HEIGHT;
            player.velocity.x = 0;
            player.velocity.y = 0;
            GameScene.exitedPot = true;
            HXP.engine.popScene();
        }
        else if(zone == "earth" && player.bottom < -HEAVEN_HEIGHT) {
            player.y = -player.height;
            if(Player.riding != null) {
                Player.riding.y = -Player.riding.height;
            }
            player.removeCarriedItem();
            player.removeRiding();
            HXP.engine.pushScene(new GameScene("heaven"));
        }
        else if(zone == "heaven" && player.y > LAIR_AND_EARTH_DEPTH) {
            player.removeCarriedItem();
            player.removeRiding();
            HXP.engine.popScene();
        }
        else if(zone == "hell" && player.y > LAIR_AND_EARTH_DEPTH) {
            player.y = -player.height;
            if(Player.riding != null) {
                Player.riding.y = -Player.riding.height;
            }
            player.removeCarriedItem();
            player.removeRiding();
            HXP.engine.pushScene(new GameScene("lair"));
        }
    }

    public function onDeath() {
        HXP.alarm(2, function() {
            var lastBedDepth = GameScene.bedDepths.length > 0 ? GameScene.bedDepths.pop() : 0;
            var popNum = GameScene.dreamDepth - lastBedDepth;
            for(i in 0...popNum) {
                HXP.engine.popScene();
            }
            player.removeCarriedItem();
            if(lastBedDepth == 0) {
                // You can't carry items from dreams into the real world
                player.destroyCarriedItem();
            }
            GameScene.wokeUp = true;
        });
    }

    private function isStaticZone() {
        return staticZones.contains(zone);
    }

    private function addLevel(levelName:String) {
        var level = new Level(levelName);
        level.x += getTotalWidthOfLevels();
        add(level);
        if(levels.length > 0 && !GameScene.specialLevels.contains(levelName)) {
            level.addEnemies();
        }
        level.offsetEntities();
        levels.push(level);
        for(entity in level.entities) {
            if(entity.name == "player") {
                if(getInstance("player") == null) {
                    player = cast(entity, Player);
                    add(player);
                    for(head in player.heads) {
                        add(head);
                    }
                    if(Player.carrying != null) {
                        player.addCarriedItem(new Vector2(
                            player.centerX - Math.floor(Player.carrying.width / 2),
                            player.y - Player.carrying.height
                        ));
                    }
                    player.addRiding();
                }
            }
            else {
                add(entity);
            }
        }
        var safeToLeaveTypes = Item.itemTypes.concat(["lava"]);
        for(entity in level.entities) {
            for(otherEntity in level.entities) {
                if(
                    entity != otherEntity
                    && entity.collideWith(otherEntity, entity.x, entity.y) != null
                    && !safeToLeaveTypes.contains(entity.type)
                    && !safeToLeaveTypes.contains(otherEntity.type)
                ) {
                    remove(entity);
                }
            }
        }
    }

    private function getTotalWidthOfLevels() {
        var totalWidth = 0;
        for(level in levels) {
            totalWidth += level.width;
        }
        return totalWidth;
    }
}
