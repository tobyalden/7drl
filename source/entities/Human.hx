package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Human extends Enemy
{
    public static inline var SPEED = 60;

    private var sprite:Image;

    public function new(x:Float, y:Float) {
        super(x, y);
        mask = new Hitbox(15, 25);
        sprite = new Image("graphics/human.png");
        sprite.flipX = true;
        graphic = sprite;
        velocity = new Vector2(-SPEED, 0);
    }

    override public function update() {
        if(isOnGround()) {
            velocity.y = 0;
        }
        else {
            velocity.y += Player.GRAVITY * HXP.elapsed;
        }
        velocity.y = MathUtil.clamp(velocity.y, -Player.MAX_RISE_SPEED, Player.MAX_FALL_SPEED);

        if(HXP.camera.x + GameScene.GAME_WIDTH > x) {
            moveBy(
                velocity.x * HXP.elapsed,
                velocity.y * HXP.elapsed,
                ["walls"].concat(MiniEntity.semiSolids)
            );
        }

        if(velocity.x < 0) {
            sprite.flipX = true;
        }
        if(velocity.x > 0) {
            sprite.flipX = false;
        }

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
