package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Enemy extends MiniEntity
{
    public function new(x:Float, y:Float) {
        super(x, y - 15);
        type = "hazard";
        mask = new Hitbox(15, 25);
        graphic = new ColoredRect(width, height, 0x32a852);
    }

    override public function update() {
        super.update();
    }
}

