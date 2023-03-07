package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Kettle extends Item
{
    public function new(x:Float, y:Float) {
        super(x, y - 10);
        type = "kettle";
        mask = new Hitbox(20, 20);
        graphic = new Image("graphics/kettle.png");
    }

    override public function update() {
        super.update();
    }
}
