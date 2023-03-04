package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Item extends MiniEntity
{
    public static inline var FRICTION = 500;

    private var velocity:Vector2;
    private var sprite:Spritemap;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "item";
        mask = new Hitbox(10, 10);
        graphic = new ColoredRect(width, height, 0xAAFF00);
        velocity = new Vector2();
    }

    private function movement() {
        if(isOnGround()) {
            velocity.x = MathUtil.approach(velocity.x, 0, FRICTION * HXP.elapsed);
        }
        velocity.y += Player.GRAVITY * HXP.elapsed;
        velocity.y = Math.min(velocity.y, Player.MAX_FALL_SPEED);
        moveBy(
            velocity.x * HXP.elapsed,
            velocity.y * HXP.elapsed,
            ["walls"]
        );
    }

    public function toss(velocityX, velocityY) {
        velocity.x = velocityX;
        velocity.y = velocityY;
    }

    override public function update() {
        if(getPlayer().carrying == this) {
            velocity.x = 0;
            velocity.y = 0;
        }
        else {
            movement();
        }
        super.update();
    }

    override public function moveCollideX(e:Entity) {
        velocity.x = -velocity.x / 2;
        return true;
    }

    override public function moveCollideY(e:Entity) {
        velocity.y = -velocity.y / 2;
        if(Math.abs(velocity.y) < 50) {
            velocity.y = 0;
        }
        return true;
    }
}