package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Ogre extends Enemy
{
    public function new(x:Float, y:Float) {
        super(x, y);
        mask = new Hitbox(30, 40);
        graphic = new ColoredRect(width, height, 0x32a852);
    }

    override public function update() {
        super.update();
    }
}


