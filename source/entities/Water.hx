package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Water extends MiniEntity
{
    private var isBlessed:Bool;
    private var pulse:ColorTween;
    private var sprite:Image;

    public function new(x:Float, y:Float, width:Int, height:Int) {
        super(x, y);
        layer = -20;
        type = "water";
        mask = new Hitbox(width, height);
        sprite = Image.createRect(width, height, 0xFFFFFF);
        sprite.color = 0xADD8E6;
        sprite.alpha = 0.5;
        graphic = sprite;
        pulse = new ColorTween(TweenType.PingPong);
        addTween(pulse);
        isBlessed = false;
    }

    private function bless() {
        isBlessed = true;
        //pulse.tween(0.5, 0xADD8E6, 0xEDF7FA, 0.5, 0.5, Ease.sineInOut);
        pulse.tween(0.5, 0xEDF7FA, 0xADD8E6, 0.5, 0.5, Ease.sineInOut);
    }

    override public function update() {
        if(collide("angel", x, y) != null && !isBlessed) {
            bless();
        }
        if(isBlessed) {
            sprite.color = pulse.color;
        }
        super.update();
    }
}

