package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class JumpingHuman extends Enemy
{
    public static inline var SPEED = 60;
    public static inline var JUMP_POWER = 300;
    public static inline var JUMP_PAUSE = 1.25;

    private var jumpTimer:Alarm;
    private var willJump:Bool;
    private var isJumpingHigh:Bool;
    private var sprite:Image;

    public function new(x:Float, y:Float) {
        super(x, y);
        mask = new Hitbox(15, 25);
        sprite = new Image("graphics/jumping_human.png");
        sprite.flipX = true;
        graphic = sprite;
        velocity = new Vector2(-SPEED, 0);
        jumpTimer = new Alarm(JUMP_PAUSE, function() {
            willJump = true;
        });
        addTween(jumpTimer);
        willJump = false;
        isJumpingHigh = true;
    }

    private function jump() {
        velocity = new Vector2(
            (centerX > getPlayer().centerX ? -1 : 1) * SPEED,
            isJumpingHigh ? -JUMP_POWER : -JUMP_POWER / 2
        );
        isJumpingHigh = !isJumpingHigh;
    }

    override public function update() {
        if(HXP.camera.x + GameScene.GAME_WIDTH > x) {
            if(isOnGround()) {
                velocity.x = 0;
                velocity.y = 0;
                if(!jumpTimer.active) {
                    jumpTimer.start();
                }
                if(willJump) {
                    jump();
                    willJump = false;
                }
            }
            else {
                velocity.y += Player.GRAVITY * HXP.elapsed;
            }
            velocity.y = MathUtil.clamp(velocity.y, -Player.MAX_RISE_SPEED, Player.MAX_FALL_SPEED);
        }

        moveBy(
            velocity.x * HXP.elapsed,
            velocity.y * HXP.elapsed,
            ["walls"].concat(MiniEntity.semiSolids)
        );

        if(velocity.x < 0) {
            sprite.flipX = true;
        }
        else if(velocity.x > 0) {
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

