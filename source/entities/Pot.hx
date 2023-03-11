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
    private var numTimesExited:Int;

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
        numTimesExited = 0;
    }

    public function createInterior() {
        interior = new GameScene("pot");
    }

    public function crack() {
        numTimesExited += 1;
        if(numTimesExited == 3) {
            isCracked = true;
            GameScene.sfx["potbreak"].play();
        }
        else {
            GameScene.sfx["potcrack"].play();
        }
    }

    override public function update() {
        if(numTimesExited == 0) {
            sprite.play("unused");
        }
        else {
            sprite.play('crack${numTimesExited}');
        }
        super.update();
    }
}
