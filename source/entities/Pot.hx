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
    public var isCracked(default, null):Bool;
    public var interior(default, null):Scene;

    public function new(x:Float, y:Float) {
        super(x, y - 15);
        weightModifier = 1.25;
        type = "pot";
        mask = new Hitbox(15, 25);
        graphic = new ColoredRect(width, height, 0xFFFFBB);
        isCracked = false;
        interior = null;
    }

    public function createInterior() {
        interior = new GameScene("pot");
    }

    public function crack() {
        isCracked = true;
        graphic = new ColoredRect(width, height, 0xA3A378);
    }

    override public function update() {
        super.update();
    }
}
