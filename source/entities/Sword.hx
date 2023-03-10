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

class Sword extends Item
{
    public var isBlessed(default, null):Bool;
    private var pulse:ColorTween;
    private var sprite:Image;

    public function new(x:Float, y:Float) {
        super(x, y - 5);
        type = "sword";
        mask = new Hitbox(15, 20);
        sprite = new Image("graphics/sword.png");
        graphic = sprite;
        isBlessed = false;
        pulse = new ColorTween(TweenType.PingPong);
        addTween(pulse);

        //bless(); // TODO: for testing
    }

    private function bless() {
        isBlessed = true;
        pulse.tween(0.5, 0xEDF7FA, 0xADD8E6, 0.5, 0.5, Ease.sineInOut);
    }

    override public function update() {
        var water = collide("water", x, y);
        if(water != null && cast(water, Water).isBlessed && !isBlessed) {
            bless();
        }
        if(isBlessed) {
            sprite.color = pulse.color;
        }
        super.update();
    }
}
