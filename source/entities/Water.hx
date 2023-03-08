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
    public function new(x:Float, y:Float, width:Int, height:Int) {
        super(x, y);
        layer = -20;
        type = "water";
        mask = new Hitbox(width, height);
        var sprite = Image.createRect(width, height, 0xADD8E6);
        sprite.alpha = 0.5;
        graphic = sprite;
    }
}

