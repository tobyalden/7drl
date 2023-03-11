package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class FallingSpike extends MiniEntity
{
    public static inline var FALL_RANGE = 10;
    public static inline var VANISH_TIME = 1;

    private var sprite:Image;
    private var velocity:Vector2;
    private var isFalling:Bool;
    private var vanishTimer:Alarm;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "hazard";
        sprite = new Image("graphics/icicle.png");
        graphic = sprite;
        velocity = new Vector2();
        mask = new Hitbox(10, 10);
        isFalling = false;
        vanishTimer = new Alarm(VANISH_TIME, function() {
            HXP.scene.remove(this);
        });
        addTween(vanishTimer);
    }

    public function fall() {
        if(!isFalling) {
            GameScene.sfx["fall"].play();
        }
        isFalling = true;
    }

    override public function update() {
        if(
            Math.abs(centerX - getPlayer().centerX) < FALL_RANGE
            && HXP.scene.collideLine(
                "walls",
                Std.int(centerX), Std.int(centerY),
                Std.int(getPlayer().centerX), Std.int(getPlayer().centerY)
            ) == null
        ) {
            fall();
        }
        if(isFalling && !vanishTimer.active) {
            velocity.y += Player.GRAVITY * HXP.elapsed;
            velocity.y = MathUtil.clamp(
                velocity.y, -Player.MAX_FALL_SPEED, Player.MAX_FALL_SPEED
            );
        }
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
        super.update();
    }

    override public function moveCollideY(_:Entity) {
        velocity.y = 0;
        GameScene.sfx["spikeland"].play();
        if(!vanishTimer.active) {
            vanishTimer.start();
        }
        return true;
    }
}

