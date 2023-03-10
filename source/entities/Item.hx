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

    public static var itemTypes = ["item", "mount", "pot", "bed", "egg", "kettle", "sword"];

    public var velocity(default, null):Vector2;
    public var weightModifier(default, null):Float;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "item";
        mask = new Hitbox(20, 20);
        graphic = new Image("graphics/apple.png");
        velocity = new Vector2();
        weightModifier = 1;
    }

    private function movement() {
        if(isOnGround()) {
            velocity.x = MathUtil.approach(velocity.x, 0, FRICTION * HXP.elapsed * weightModifier);
            velocity.y = 0;
        }
        else {
            var gravity:Float = Player.GRAVITY;
            if(collide("water", x, y) != null) {
                gravity *= 0.25;
            }
            velocity.y += gravity * HXP.elapsed;
        }
        var maxFallSpeed:Float = Player.MAX_FALL_SPEED;
        if(collide("water", x, y) != null) {
            maxFallSpeed *= 0.33;
        }
        velocity.y = Math.min(velocity.y, maxFallSpeed);
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
        if(velocity.length > 20) {
            var fallingSpikes = [];
            HXP.scene.getClass(FallingSpike, fallingSpikes);
            for(fallingSpike in fallingSpikes) {
                if(
                    Math.abs(fallingSpike.centerX - centerX) < FallingSpike.FALL_RANGE
                    && HXP.scene.collideLine(
                        "walls",
                        Std.int(fallingSpike.centerX), Std.int(fallingSpike.centerY),
                        Std.int(centerX), Std.int(centerY)
                    ) == null
                ) {
                    cast(fallingSpike, FallingSpike).fall();
                }
            }
        }
        if(Player.carrying == this) {
            velocity.x = 0;
            velocity.y = 0;
        }
        else if(Player.riding != this) {
            if(!(Type.getClass(this) == Mount && cast(this, Mount).isDragon)) {
                movement();
            }
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
