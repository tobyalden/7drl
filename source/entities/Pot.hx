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

    private var sprite:Spritemap;

    public function new(x:Float, y:Float) {
        super(x, y);
        weightModifier = 1.25;
        type = "pot";
        mask = new Hitbox(12, 25);
        sprite = new Spritemap("graphics/pot.png", 12, 25);
        sprite.add("unused", [0]);
        sprite.add("crack1", [1]);
        sprite.add("crack2", [2]);
        sprite.add("crack3", [3]);
        sprite.play("unused");
        graphic = sprite;
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
