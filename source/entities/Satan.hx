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
    public function new(x:Float, y:Float) {
        super(x, y);
        mask = new Hitbox(60, 60);
        graphic = new ColoredRect(width, height, 0xFF0000);
        HXP.tween(this, {"y": y + 70}, 1.5838, {type: TweenType.PingPong, tweener: this});
        HXP.alarm(2.7264, function() {
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

    override public function update() {
        super.update();
    }
}
