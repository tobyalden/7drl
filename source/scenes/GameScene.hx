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

    public static var staticZones:Array<String> = ["pot"];
    public static var poppedScene:Bool = false;

    private var player:Player;
    private var levels:Array<Level>;
    private var maxCameraX:Float;
    private var zone:String;

    public function new(zone:String) {
        super();
        this.zone = zone;
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
        if(poppedScene) {
            if(Player.carrying != null) {
                player.addCarriedItem(new Vector2(
                    player.centerX - Math.floor(Player.carrying.width / 2),
                    player.y
                ));
            }
            player.exitPot();
            poppedScene = false;
        }
        if(DEBUG_MODE) {
            if(Key.pressed(Key.R)) {
                HXP.scene = new GameScene("earth");
            }
        }
        if(player.bottom < 0) {
            HXP.engine.popScene();
            player.removeCarriedItem();
            poppedScene = true;
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

    private function isStaticZone() {
        return staticZones.indexOf(zone) != -1;
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
