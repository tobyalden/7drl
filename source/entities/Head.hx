package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Head extends Entity
{
    public static inline var FOLLOW_DISTANCE = 20;
    public static inline var APPEAR_SPEED = 2;
    public static inline var DISAPPEAR_SPEED = 4;

    public var sprite:Spritemap;

    public function new(x:Float, y:Float) {
        super(x, y);
        layer = -99;
        mask = new Hitbox(8, 5);
        sprite = new Spritemap("graphics/head.png", 8, 5);
        sprite.add("alive", [0]);
        sprite.add("dead", [1]);
        sprite.play("alive");
        sprite.alpha = 0;
        graphic = sprite;
        HXP.tween(
            sprite,
            {y: -10},
            0.75 + 0.5 * Random.random,
            {ease: Ease.sineInOut, tweener: this, type: TweenType.PingPong}
        );
    }

    override public function update() {
        super.update();
    }

    public function explode(numExplosions:Int = 50) {
        var directions = new Array<Vector2>();
        for(i in 0...numExplosions) {
            var angle = (2/numExplosions) * i;
            directions.push(new Vector2(Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(Math.cos(angle), -Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), -Math.sin(angle)));
        }
        var count = 0;
        for(direction in directions) {
            direction.scale(0.8 * Random.random);
            direction.normalize(
                Math.max(0.1 + 0.2 * Random.random, direction.length)
            );
            var explosion = new Particle(
                centerX, centerY, directions[count], 1, 1
            );
            explosion.layer = -99;
            scene.add(explosion);
            count++;
        }

#if desktop
        //Sys.sleep(0.02);
#end
        //scene.camera.shake(1, 4);
    }
}

