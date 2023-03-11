package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import entities.Bullet;
import scenes.*;

class Satan extends Enemy
{
    private var mover:MultiVarTween;
    private var fireTimer:Alarm;
    private var sprite:Spritemap;

    public function new(x:Float, y:Float) {
        super(x, y);
        mask = new Hitbox(60, 60);
        sprite = new Spritemap("graphics/satan.png", 60, 60);
        sprite.add("idle", [0, 1, 2, 3, 4, 5], 8);
        sprite.play("idle");
        sprite.centerOrigin();
        sprite.x = 30;
        sprite.y = 30;
        graphic = sprite;
        mover = HXP.tween(this, {"y": y + 70}, 1.5838, {type: TweenType.PingPong, tweener: this});
        fireTimer = HXP.alarm(2.7264, function() {
            fire();
        }, TweenType.Looping, this);
    }

    private function fire() {
        spreadShot(
            3,
            Math.PI / 7.5,
            {
                radius: 3,
                angle: -Math.PI / 2,
                speed: 125,
                color: 0xB0E3EA
            }
        );
    }

    private function spreadShot(
        numBullets:Int, spreadAngle:Float, bulletOptions:BulletOptions
    ) {
        var iterStart = Std.int(-Math.floor(numBullets / 2));
        var iterEnd = Std.int(Math.ceil(numBullets / 2));
        var angleOffset = numBullets % 2 == 0 ? spreadAngle / 2 : 0;
        var originalAngle = bulletOptions.angle;
        for(i in iterStart...iterEnd) {
            bulletOptions.angle = originalAngle + i * spreadAngle + angleOffset;
            shoot(bulletOptions);
        }
    }

    private function shoot(bulletOptions:BulletOptions) {
        var bullet = new Bullet(centerX, centerY, bulletOptions);
        scene.add(bullet);
    }

    override private function die() {
        GameScene.sfx["shatter"].play();
        GameScene.sfx["satandeath"].play();
        GameScene.sfx["music_satan"].stop();
        mover.active = false;
        fireTimer.active = false;
        collidable = false;
        HXP.tween(sprite, {"angle": 360}, 0.75, {type: TweenType.Looping, tweener: this});
        HXP.tween(sprite, {"scaleX": 10}, 10, {type: TweenType.PingPong, tweener: this});
        HXP.tween(sprite, {"scaleY": 10}, 10, {type: TweenType.PingPong, tweener: this});
        HXP.tween(sprite, {"alpha": 0}, 10, {type: TweenType.OneShot, tweener: this, complete: function() {
            HXP.alarm(3, function() {
                HXP.engine.pushScene(new Victory());
            }, this);
        }});
    }

    override public function update() {
        var sword = collide("sword", x, y);
        if(sword != null && cast(sword, Sword).isBlessed) {
            die();
        }
        super.update();
    }
}
