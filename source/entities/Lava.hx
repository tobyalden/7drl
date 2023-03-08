package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Lava extends MiniEntity
{
    public static inline var PULSE_TIME = 2;
    public static inline var OFFSCREEN_MARGIN = -10;

    private var tide:VarTween;
    private var sprite:Image;

    public function new(x:Float, y:Float, width:Int, height:Int) {
        super(x, y);
        layer = -20;
        type = "lava";
        mask = new Hitbox(width, height);
        sprite = Image.createRect(width, height, 0xFF0000);
        sprite.alpha = 0.5;
        graphic = sprite;
        tide = new VarTween(TweenType.PingPong);
        tide.tween(this, "y", y + height + OFFSCREEN_MARGIN, PULSE_TIME, Ease.sineInOut);
        addTween(tide, true);
    }

    override public function update() {
        super.update();
    }
}

