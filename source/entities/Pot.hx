package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Pot extends Item
{
    //public static inline var MAX_RUN_SPEED = 100;

    //private var timeOffGround:Float;

    public function new(x:Float, y:Float) {
        super(x, y - 5);
        //weightModifier = 1.25;
        type = "pot";
        mask = new Hitbox(10, 15);
        graphic = new ColoredRect(width, height, 0xFFFFBB);
    }

    override public function update() {
        super.update();
    }
}
