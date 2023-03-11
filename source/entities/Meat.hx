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

class Meat extends Item
{
    public var isCooked(default, null):Bool;
    private var sprite:Spritemap;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "meat";
        mask = new Hitbox(20, 20);
        sprite = new Spritemap("graphics/meat.png", 20, 20);
        sprite.add("uncooked", [0]);
        sprite.add("cooked", [1]);
        sprite.play("uncooked");
        graphic = sprite;
        isCooked = false;
    }

    private function cook() {
        if(!isCooked) {
            isCooked = true;
            GameScene.sfx["cook"].play();
            sprite.play("cooked");
        }
    }

    override public function update() {
        if(collide("lava", x, y) != null) {
            cook();
        }
        super.update();
    }
}

