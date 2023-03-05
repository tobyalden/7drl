package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Bed extends Item
{
    public function new(x:Float, y:Float) {
        super(x, y - 15);
        weightModifier = 1.25;
        type = "bed";
        mask = new Hitbox(25, 15);
        graphic = new ColoredRect(width, height, 0xC69593);
    }

    override public function update() {
        super.update();
    }
}
