package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Ogre extends Enemy
{
    public static inline var SPEED = 50;
    public static inline var JUMP_POWER = 300;
    public static inline var ALERT_AWAKEN_THRESHOLD = 1.75;
    public static inline var ALERT_RANGE = 110;

    private var sprite:Spritemap;
    private var isAwake:Bool;
    private var alertness:Float;

    public function new(x:Float, y:Float) {
        super(x, y);
        mask = new Hitbox(30, 40);
        sprite = new Spritemap("graphics/ogre.png", width, height);
        sprite.add("asleep", [0]);
        sprite.add("alert", [1]);
        sprite.add("awake", [2, 3, 2, 4], 16);
        graphic = sprite;
        isAwake = false;
        alertness = 0;
    }

    private function jump() {
        velocity = new Vector2(
            (centerX > getPlayer().centerX ? -1 : 1) * SPEED,
            -JUMP_POWER
        );
    }

    override function die() {
        // He can't die!
    }

    override public function update() {
        if(distanceFrom(getPlayer(), true) < ALERT_RANGE) {
            alertness += HXP.elapsed;
        }
        else {
            alertness = Math.max(alertness - HXP.elapsed, 0);
        }
        if(alertness > ALERT_AWAKEN_THRESHOLD) {
            isAwake = true;
        }
        if(isAwake) {
            if(isOnGround()) {
                jump();
            }
            else {
                velocity.y += Player.GRAVITY * HXP.elapsed;
            }
            velocity.y = MathUtil.clamp(velocity.y, -Player.MAX_RISE_SPEED, Player.MAX_FALL_SPEED);
            sprite.play("awake");
        }
        else {
            if(alertness > 0) {
                sprite.play("alert");
            }
            else {
                sprite.play("asleep");
            }
        }
        moveBy(
            velocity.x * HXP.elapsed,
            velocity.y * HXP.elapsed,
            ["walls"].concat(MiniEntity.semiSolids)
        );
        super.update();
    }

    override public function moveCollideX(e:Entity) {
        if(MiniEntity.semiSolids.contains(e.type)) {
            return false;
        }
        velocity.x = -velocity.x;
        return true;
    }
}
