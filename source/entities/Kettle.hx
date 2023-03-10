package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Kettle extends Item
{
    public static inline var MAX_HEAT = 5;
    public static inline var STEAM_SPAWN_INTERVAL = 1;

    private var heat:Float;
    private var steamSpawner:Alarm;

    public function new(x:Float, y:Float) {
        super(x, y - 10);
        type = "kettle";
        mask = new Hitbox(20, 20);
        graphic = new Image("graphics/kettle.png");
        heat = 0;
        steamSpawner = new Alarm(STEAM_SPAWN_INTERVAL, function() {
            spawnSteam();
        }, TweenType.Looping);
        addTween(steamSpawner);
    }

    private function spawnSteam() {
        HXP.scene.add(new Steam(x, y - height));
    }

    override public function update() {
        if(collide("lava", x, y) != null) {
            heat = MAX_HEAT;
        }
        else {
            heat = Math.max(heat - HXP.elapsed, 0);
        }
        if(heat > 0) {
            if(!steamSpawner.active) {
                steamSpawner.start();
            }
        }
        else {
            steamSpawner.active = false;
        }
        super.update();
    }
}
