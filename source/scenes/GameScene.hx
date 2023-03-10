package scenes;

import entities.*;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
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
    public static inline var DEBUG_MODE = true;
    public static inline var HEAVEN_HEIGHT = 200;
    public static inline var LAIR_AND_EARTH_DEPTH = GAME_HEIGHT + 50;

    public static var staticZones:Array<String> = ["pot", "bedroom", "lair", "swordroom"];
    public static var specialLevels:Array<String> = ["earth_nest", "heaven_shrine", "hell_ogre"];
    public static var exitedPot:Bool = false;
    public static var wokeUp:Bool = false;
    public static var dreamDepth:Int = 0;
    public static var bedDepths:Array<Int> = [];
    public static var totalTime:Float = 0;

    public var zone(default, null):String;
    private var player:Player;
    private var levels:Array<Level>;
    private var maxCameraX:Float;

    public function new(zone:String) {
        super();
        this.zone = zone;
    }

	override public function resume() {
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
        levels = [];
        addLevel(zone);
    }

    override public function update() {
        GameScene.totalTime += HXP.elapsed;
        if(DEBUG_MODE) {
            if(Key.pressed(Key.P)) {
                trace(bedDepths);
            }
        }

        if(zone == "pot" && player.bottom < 0) {
            player.removeCarriedItem();
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
        super.update();
        if(!isStaticZone()) {
            camera.x = Math.max(player.centerX - GAME_WIDTH / 3, maxCameraX);
            maxCameraX = Math.max(camera.x, maxCameraX);
            if(camera.x + GAME_WIDTH + EXTEND_LEVEL_BUFFER > getTotalWidthOfLevels()) {
                //addLevel("earth_nest");
                //addLevel("heaven_shrine");
                //addLevel("hell_ogre");
                //addLevel("earth");
                addLevel(zone);
            }
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
                GameScene.totalTime = 0;
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
            trace('adding enemies');
        }
        level.offsetEntities();
        levels.push(level);
        for(entity in level.entities) {
            if(entity.name == "player") {
                if(getInstance("player") == null) {
                    player = cast(entity, Player);
                    add(player);
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
        for(entity in level.entities) {
            for(otherEntity in level.entities) {
                if(
                    entity != otherEntity
                    && entity.collideWith(otherEntity, entity.x, entity.y) != null
                    && entity.type != "lava"
                    && otherEntity.type != "lava"
                ) {
                    trace('removing overlapping enemies');
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
