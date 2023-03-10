package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Angel extends Enemy
{
    public static inline var CHASE_RANGE = 80;
    public static inline var CHASE_ACCEL = 100;
    public static inline var MAX_CHASE_SPEED = 100;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "angel";
        layer = -15;
        mask = new Hitbox(15, 20);
        graphic = new Image("graphics/angel.png");
    }

    override public function update() {
        if(distanceFrom(getPlayer(), true) < CHASE_RANGE) {
            var towardsPlayer = new Vector2(getPlayer().centerX - centerX, getPlayer().centerY - centerY);
            towardsPlayer.normalize(CHASE_ACCEL * HXP.elapsed);
            velocity.add(towardsPlayer);
            if(velocity.length > MAX_CHASE_SPEED) {
                velocity.normalize(MAX_CHASE_SPEED);
            }
        }
        else {
            velocity.x = MathUtil.approach(velocity.x, 0, CHASE_ACCEL * HXP.elapsed);
            velocity.y = MathUtil.approach(velocity.y, 0, CHASE_ACCEL * HXP.elapsed);
        }
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
        super.update();
    }
}



