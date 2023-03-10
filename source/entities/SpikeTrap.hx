package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class SpikeTrap extends MiniEntity
{
    public static inline var ACTIVATE_DELAY = 0.25;
    public static inline var DEACTIVATE_DELAY = 0.75;

    private var sprite:Spritemap;
    private var activateTimer:Alarm;
    private var deactivateTimer:Alarm;

    public function new(x:Float, y:Float) {
        super(x, y);
        layer = -40;
        type = "not_hazard";
        sprite = new Spritemap("graphics/spiketrap.png", 10, 20);
        sprite.add("idle", [0]);
        sprite.add("active", [2]);
        sprite.add("retracting", [1, 0], 12, false);
        sprite.play("idle");
        sprite.alpha = 0.5;
        sprite.y = -10;
        graphic = sprite;
        mask = new Hitbox(10, 5, 0, -5);
        activateTimer = new Alarm(ACTIVATE_DELAY, function() {
            sprite.play("active");
            GameScene.sfx["spikeactivate"].play();
            type = "hazard";
            deactivateTimer.start();
        });
        addTween(activateTimer);
        deactivateTimer = new Alarm(DEACTIVATE_DELAY, function() {
            sprite.play("retracting");
            GameScene.sfx["spikedeactivate"].play();
            type = "not_hazard";
        });
        addTween(deactivateTimer);
    }

    override public function update() {
        if(collideWith(getPlayer(), x, y) != null && getPlayer().isOnGround()) {
            if(!activateTimer.active && !deactivateTimer.active) {
                activateTimer.start();
                GameScene.sfx["spikewarning"].play();
            }
        }
        super.update();
    }
}

