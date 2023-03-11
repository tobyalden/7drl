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
    public static inline var FOLLOW_DISTANCE = 30;

    public var sprite:Spritemap;

    public function new(x:Float, y:Float) {
        super(x, y);
        mask = new Hitbox(15, 25);
        sprite = new Spritemap("graphics/head.png", 15, 15);
        sprite.add("alive", [0]);
        sprite.add("dead", [1]);
        sprite.play("alive");
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
}

