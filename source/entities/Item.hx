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

    public static var itemTypes = ["item", "mount", "pot"];

    public var velocity(default, null):Vector2;
    public var weightModifier(default, null):Float;
    private var sprite:Spritemap;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "item";
        mask = new Hitbox(10, 10);
        graphic = new ColoredRect(width, height, 0xAAFF00);
        velocity = new Vector2();
        weightModifier = 1;
    }

    private function movement() {
        if(isOnGround()) {
            velocity.x = MathUtil.approach(velocity.x, 0, FRICTION * HXP.elapsed * weightModifier);
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
        else if(getPlayer().riding != this) {
            movement();
        }
        super.update();
    }

    override public function moveCollideX(e:Entity) {
        velocity.x = -velocity.x / (2 * weightModifier);
        return true;
    }

    override public function moveCollideY(e:Entity) {
        velocity.y = -velocity.y / (2 * weightModifier);
        if(Math.abs(velocity.y) < 50) {
            velocity.y = 0;
        }
        return true;
    }
}
