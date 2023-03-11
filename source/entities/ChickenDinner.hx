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

class ChickenDinner extends Item
{
    private var sprite:Image;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "chickendinner";
        mask = new Hitbox(20, 20);
        sprite = new Image("graphics/chickendinner.png");
        graphic = sprite;
    }

    override public function update() {
        super.update();
    }
}
