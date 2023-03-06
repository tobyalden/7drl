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
    public static inline var DEBUG_MODE = true;
    public static inline var HEAVEN_HEIGHT = 50;

    public static var staticZones:Array<String> = ["pot", "bedroom"];
    public static var exitedPot:Bool = false;
    public static var wokeUp:Bool = false;
    public static var dreamDepth:Int = 0;
    public static var bedDepths:Array<Int> = [];

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
        levels = [];
        var level = addLevel();
        level.offsetEntities();
        for(entity in level.entities) {
            add(entity);
            if(entity.name == "player") {
                player = cast(entity, Player);
                if(Player.carrying != null) {
                    player.addCarriedItem(new Vector2(
                        player.centerX - Math.floor(Player.carrying.width / 2),
                        player.y - Player.carrying.height
                    ));
                }
            }
        }
    }

    override public function update() {
        if(DEBUG_MODE) {
            if(Key.pressed(Key.P)) {
            }
        }

        if(zone == "pot" && player.bottom < 0) {
            HXP.engine.popScene();
            player.removeCarriedItem();
            GameScene.exitedPot = true;
        }
        else if(zone == "earth" && player.bottom < -HEAVEN_HEIGHT) {
            player.y = -player.height;
            player.removeCarriedItem();
            HXP.engine.pushScene(new GameScene("heaven"));
        }
        else if(zone == "heaven" && player.y > GAME_HEIGHT) {
            HXP.engine.popScene();
            player.removeCarriedItem();
        }
        super.update();
        if(!isStaticZone()) {
            camera.x = Math.max(player.centerX - GAME_WIDTH / 3, maxCameraX);
            maxCameraX = Math.max(camera.x, maxCameraX);
            if(camera.x + GAME_WIDTH > getTotalWidthOfLevels()) {
                addLevel();
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
            }
            GameScene.wokeUp = true;
        });
    }

    private function isStaticZone() {
        return staticZones.contains(zone);
    }

    private function addLevel() {
        var level = new Level(zone);
        level.x += getTotalWidthOfLevels();
        add(level);
        levels.push(level);
        return level;
    }

    private function getTotalWidthOfLevels() {
        var totalWidth = 0;
        for(level in levels) {
            totalWidth += level.width;
        }
        return totalWidth;
    }
}
